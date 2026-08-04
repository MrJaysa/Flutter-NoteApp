import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show
        Attribute,
        BlockEmbed,
        ChangeSource,
        DefaultListBlockStyle,
        DefaultStyles,
        DefaultTextBlockStyle,
        DocChange,
        Document,
        HorizontalSpacing,
        Line,
        QuillController,
        QuillEditor,
        QuillEditorConfig,
        VerticalSpacing;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notich/components/custom_keyboard/formatting_toolbar.dart';
import 'package:notich/components/custom_quill_image_view.dart';
import 'package:notich/events/close_swipable_event.dart';
import 'package:notich/helpers/note_preview.dart';
import 'package:notich/modals/delete_modal.dart';
import 'package:notich/models/model.dart';
import 'package:notich/models/note_db.dart';

class AddNoteScreen extends StatefulWidget {
  final String? id;
  final String? title;
  final List<dynamic>? content;

  const AddNoteScreen({super.key, this.id, this.title, this.content});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  late final QuillController _quillController;

  final FocusNode _noteFocusNode = FocusNode();

  bool _hasContent = false;
  bool _showUndoRedo = false;
  String? _noteId;

  Timer? _saveTimer;

  bool _showFormattingToolbar = false;
  bool _toolbarLoaded = false;

  void _updateHasContent() {
    final plainContent = _quillController.document.toPlainText().trim();

    final preview = getNotePreview(
      _titleController.text.trim(),
      _quillController.document.toDelta().toJson(),
    );

    final searchText = _titleController.text.isNotEmpty
        ? "${_titleController.text} $plainContent"
        : "$plainContent ${preview.title}";

    final hasContent =
        (_titleController.text.trim().isNotEmpty ||
            !_quillController.document.isEmpty()) &&
        searchText.isNotEmpty;

    _hasContent = hasContent;
    _saveTimer?.cancel();

    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!_hasContent) {
        if (_noteId != null) {
          await db.writeTxn(() async {
            await db.collection<NoteData>().delete(int.parse(_noteId!));
          });

          _noteId = null;
        }

        return;
      }

      await _saveData();
    });
    setState(() {});
  }

  void _listenToKeyPressEnter(DocChange change) {
    for (final op in change.change.toList()) {
      if (!op.isInsert || op.data is! String) continue;

      if (!(op.data as String).contains('\n')) continue;

      final selection = _quillController.selection;

      final previousLine = _quillController.document.queryChild(
        selection.baseOffset - 1,
      );

      if (!previousLine.node!.style.attributes.containsKey(
        Attribute.checked.key,
      )) {
        return;
      }

      if (previousLine.node!.style.attributes[Attribute.list.key]?.value ==
              'ordered' ||
          previousLine.node!.style.attributes[Attribute.list.key]?.value ==
              'bullet') {
        continue;
      }

      final currentLine = _quillController.document.queryChild(
        selection.baseOffset,
      );

      if (currentLine.node!.style.attributes.containsKey(
        Attribute.checked.key,
      )) {
        _quillController.formatText(
          selection.baseOffset,
          0,
          Attribute.unchecked,
        );
      }
    }
  }

  Future<void> _saveData() async {
    final contentJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    final plainContent = _quillController.document.toPlainText().trim();

    final preview = getNotePreview(
      _titleController.text.trim(),
      _quillController.document.toDelta().toJson(),
    );

    final searchText = _titleController.text.isNotEmpty
        ? "${_titleController.text} $plainContent"
        : "$plainContent ${preview.title}";

    if (searchText.isNotEmpty) {
      final note = NoteData(
        title: _titleController.text.trim(),
        contentDelta: contentJson,
        contentText: searchText.trim(),
        updatedAt: DateTime.now(),
      );

      if (_noteId != null) {
        final id = int.tryParse(_noteId!);

        if (id != null) {
          note.id = id;
        }
      }

      final saveId = await db.writeTxn(() async {
        return await db.collection<NoteData>().put(note);
      });

      _noteId ??= "$saveId";
    }
  }

  Future<void> _deleteNote() async {
    if (!mounted) return;

    final confirmed = await showDeleteDialog(context, 1, "Note");

    if (confirmed == true) {
      await db.writeTxn(() async {
        await db.collection<NoteData>().delete(int.parse(_noteId!));
      });
      if (mounted) {
        context.pop();
      }
    }
  }

  QuillController _initializeQuillContent(List<dynamic>? content) {
    if (content == null || content.isEmpty) {
      return QuillController.basic();
    }

    final delta = List<dynamic>.from(content);

    final lastInsert = delta.last is Map ? delta.last['insert'] : null;

    if (lastInsert is String && !lastInsert.endsWith('\n')) {
      delta.add({'insert': '\n'});
    }

    return QuillController(
      document: Document.fromJson(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void initState() {
    super.initState();

    closeSwipeableEventBus.emit();

    _noteId = widget.id;

    if (widget.title != null) {
      _titleController.text = widget.title!;
    }

    _quillController = _initializeQuillContent(widget.content);

    _hasContent =
        _titleController.text.trim().isNotEmpty ||
        !_quillController.document.isEmpty();

    _titleController.addListener(_updateHasContent);
    _quillController.document.changes.listen((_) => _updateHasContent());
    _quillController.document.changes.listen(_listenToKeyPressEnter);

    _noteFocusNode.addListener(() {
      bool needsRebuild = false;

      if (_showFormattingToolbar) {
        _showFormattingToolbar = false;
        needsRebuild = true;
      }

      if (_showUndoRedo != _noteFocusNode.hasFocus) {
        _showUndoRedo = _noteFocusNode.hasFocus;

        if (!_toolbarLoaded) {
          _toolbarLoaded = true;
        }

        needsRebuild = true;
      }

      if (needsRebuild) {
        setState(() {});
      }
    });
  }

  void _editorTapped() {
    if (_showFormattingToolbar) {
      setState(() {
        _showFormattingToolbar = false;
      });
    }
  }

  (int, int) getLineBounds() {
    final currentOffset = _quillController.selection.baseOffset;
    if (currentOffset < 0) return (0, 0);

    final queryResult = _quillController.document.queryChild(currentOffset);

    if (queryResult.node != null && queryResult.node is Line) {
      final Line currentLineNode = queryResult.node as Line;

      final int lineStart = currentLineNode.documentOffset;
      final int lineEnd = lineStart + currentLineNode.length - 1;

      return (lineStart, lineEnd);
    }

    return (0, 0);
  }

  Future<void> _pickImage() async {
    if (_showFormattingToolbar) {
      setState(() {
        _showFormattingToolbar = false;
      });
    }

    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final style = _quillController.getSelectionStyle();

    final isChecklist =
        style.attributes.containsKey(Attribute.checked.key) ||
        style.attributes.containsKey(Attribute.unchecked.key);

    final bounds = getLineBounds();

    final (lineStart, lineEnd) = bounds;

    if (isChecklist) {
      if (lineEnd > 0) {
        _quillController.updateSelection(
          TextSelection.collapsed(offset: lineEnd),
          ChangeSource.local,
        );

        _quillController.document.insert(lineEnd, '\n');

        _quillController.updateSelection(
          TextSelection.collapsed(offset: lineEnd + 1),
          ChangeSource.local,
        );

        _quillController.formatSelection(
          Attribute.clone(Attribute.unchecked, null),
        );

        final imageIndex = _quillController.selection.baseOffset;

        _quillController.document.insert(
          imageIndex,
          BlockEmbed.image(image.path),
        );

        _quillController.document.insert(imageIndex + 1, '\n');

        _quillController.updateSelection(
          TextSelection.collapsed(offset: imageIndex + 2),
          ChangeSource.local,
        );
      } else {
        _quillController.formatSelection(
          Attribute.clone(Attribute.unchecked, null),
        );

        final imageIndex = _quillController.selection.baseOffset;

        _quillController.document.insert(
          imageIndex,
          BlockEmbed.image(image.path),
        );

        _quillController.document.insert(imageIndex + 1, '\n');

        _quillController.updateSelection(
          TextSelection.collapsed(offset: imageIndex + 2),
          ChangeSource.local,
        );
      }

      return;
    }

    if (lineEnd > 0) {
      _quillController.updateSelection(
        TextSelection.collapsed(offset: lineEnd),
        ChangeSource.local,
      );

      _quillController.document.insert(lineEnd, '\n');

      _quillController.document.insert(
        lineEnd + 1,
        BlockEmbed.image(image.path),
      );

      _quillController.document.insert(lineEnd + 2, '\n');

      _quillController.updateSelection(
        TextSelection.collapsed(offset: lineEnd + 3),
        ChangeSource.local,
      );
    } else {
      _quillController.document.insert(lineStart, BlockEmbed.image(image.path));

      _quillController.document.insert(lineStart + 1, '\n');

      _quillController.updateSelection(
        TextSelection.collapsed(offset: lineStart + 2),
        ChangeSource.local,
      );
    }
  }

  void _showFormattingTool() async {
    setState(() {
      _showFormattingToolbar = !_showFormattingToolbar;
    });
    if (!_showFormattingToolbar) {
      await SystemChannels.textInput.invokeMethod('TextInput.show');
    } else {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  void _checkboxToggler() {
    final isChecklist = _quillController
        .getSelectionStyle()
        .attributes
        .containsKey(Attribute.unchecked.key);

    if (isChecklist) {
      _quillController.formatSelection(
        Attribute.clone(Attribute.unchecked, null),
      );
    } else {
      _quillController.formatSelection(Attribute.unchecked);
    }

    if (_showFormattingToolbar) {
      setState(() {
        _showFormattingToolbar = false;
      });
    }
  }

  void _checkFormattingToolbar() {
    if (_showFormattingToolbar) {
      setState(() {
        _showFormattingToolbar = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateHasContent);
    _titleController.dispose();
    _quillController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_showFormattingToolbar,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _showFormattingToolbar) {
          setState(() {
            _showFormattingToolbar = false;
          });
          await SystemChannels.textInput.invokeMethod('TextInput.show');
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: !_showFormattingToolbar,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: const Text(
            "Notes",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          actions: [
            if (_showUndoRedo)
              IconButton(
                onPressed: _quillController.hasUndo
                    ? () {
                        _quillController.undo();
                        _checkFormattingToolbar();
                      }
                    : null,
                icon: Icon(Icons.undo, color: theme.colorScheme.tertiary),
              ),
            if (_showUndoRedo)
              IconButton(
                onPressed: _quillController.hasRedo
                    ? () {
                        _quillController.redo();
                        _checkFormattingToolbar();
                      }
                    : null,
                icon: Icon(Icons.redo, color: theme.colorScheme.tertiary),
              ),
            if (widget.id != null)
              IconButton(
                onPressed: _deleteNote,
                icon: Icon(
                  Icons.delete_outline_sharp,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            if (_hasContent)
              IconButton(onPressed: _saveData, icon: const Icon(Icons.check)),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        cursorColor: Colors.amber,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Title",
                          hintStyle: TextStyle(
                            color: theme.colorScheme.tertiary,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: const TextSelectionThemeData(
                              cursorColor: Colors.amber,
                              selectionColor: Color(0x66FFC107),
                              selectionHandleColor: Colors.amber,
                            ),
                            checkboxTheme: CheckboxThemeData(
                              fillColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                return states.contains(WidgetState.selected)
                                    ? Colors.amber
                                    : Colors.transparent;
                              }),
                              checkColor: WidgetStateProperty.all(Colors.white),
                            ),
                          ),
                          child: QuillEditor.basic(
                            controller: _quillController,
                            focusNode: _noteFocusNode,
                            config: QuillEditorConfig(
                              onTapDown: (details, getPosition) {
                                _editorTapped();
                                return false;
                              },
                              placeholder: "Note something down",
                              scrollable: true,
                              autoFocus: false,
                              expands: true,
                              padding: EdgeInsets.only(
                                left: 0,
                                right: 0,
                                bottom: 20,
                              ),
                              embedBuilders: [
                                CustomImageEmbedBuilder(
                                  controller: _quillController,
                                ),
                              ],
                              // ignore: experimental_member_use
                              customLeadingBlockBuilder: (node, config) {
                                final listAttr =
                                    node.style.attributes[Attribute.list.key];

                                if (listAttr != null) {
                                  if (listAttr.value == Attribute.ul.value) {
                                    return Container(
                                      width: config.width,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(
                                        right: 15.0,
                                        top: 4,
                                      ),
                                      child: const Icon(
                                        Icons.fiber_manual_record,
                                        size: 7.0,
                                      ),
                                    );
                                  }

                                  if (listAttr.value == Attribute.ol.value) {
                                    int olCount = 1;
                                    final currentIndent =
                                        node
                                            .style
                                            .attributes[Attribute.indent.key]
                                            ?.value ??
                                        0;

                                    var previousNode = node.previous;
                                    while (previousNode != null) {
                                      final prevListAttr = previousNode
                                          .style
                                          .attributes[Attribute.list.key];
                                      final prevIndent =
                                          previousNode
                                              .style
                                              .attributes[Attribute.indent.key]
                                              ?.value ??
                                          0;

                                      if (prevIndent != currentIndent) {
                                        break;
                                      }

                                      if (prevListAttr != null &&
                                          prevListAttr.value ==
                                              Attribute.ol.value) {
                                        olCount++;
                                      } else if (prevListAttr != null &&
                                          prevListAttr.value ==
                                              Attribute.ul.value) {
                                      } else {
                                        break;
                                      }
                                      previousNode = previousNode.previous;
                                    }

                                    return Container(
                                      width: config.width,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(
                                        right: 10.0,
                                        top: 3,
                                      ),
                                      child: Text(
                                        '$olCount.',
                                        style: config.style,
                                      ),
                                    );
                                  }
                                }
                                return null;
                              },

                              customStyleBuilder: (Attribute attribute) {
                                if (attribute.value == 'checked') {
                                  return TextStyle(
                                    color: const Color.fromARGB(
                                      122,
                                      164,
                                      164,
                                      164,
                                    ),
                                  );
                                }
                                return const TextStyle();
                              },
                              customStyles: DefaultStyles(
                                placeHolder: DefaultTextBlockStyle(
                                  TextStyle(
                                    fontSize: 18,
                                    height: 1.45,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                  HorizontalSpacing.zero,
                                  const VerticalSpacing(4, 5),
                                  const VerticalSpacing(4, 5),
                                  null,
                                ),
                                indent: DefaultTextBlockStyle(
                                  const TextStyle(fontSize: 18, height: 1.45),
                                  HorizontalSpacing.zero,
                                  const VerticalSpacing(4, 5),
                                  const VerticalSpacing(4, 5),
                                  null,
                                ),
                                lists: DefaultListBlockStyle(
                                  TextStyle(
                                    fontSize: 18,
                                    height: 1.45,
                                    color: theme.colorScheme.onTertiary,
                                  ),
                                  HorizontalSpacing.zero,
                                  const VerticalSpacing(4, 5),
                                  const VerticalSpacing(4, 5),
                                  null,
                                  null,
                                ),
                                paragraph: DefaultTextBlockStyle(
                                  const TextStyle(fontSize: 18, height: 1.45),
                                  HorizontalSpacing.zero,
                                  const VerticalSpacing(4, 5),
                                  const VerticalSpacing(4, 5),
                                  null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      border: Border(
                        top: BorderSide(color: Colors.white.withAlpha(13)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _showUndoRedo ? _showFormattingTool : null,
                          icon: Icon(
                            Icons.text_fields,
                            color: _showUndoRedo
                                ? _showFormattingToolbar
                                      ? Colors.amber
                                      : theme.colorScheme.onSecondary
                                : theme.brightness == Brightness.light
                                ? const Color.fromARGB(92, 158, 158, 158)
                                : Colors.white24,
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: _showUndoRedo ? _pickImage : null,
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: _showUndoRedo
                                ? theme.colorScheme.onSecondary
                                : theme.brightness == Brightness.light
                                ? const Color.fromARGB(92, 158, 158, 158)
                                : Colors.white24,
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: _showUndoRedo ? _checkboxToggler : null,
                          icon: Icon(
                            Icons.check_box_outlined,
                            color: _showUndoRedo
                                ? theme.colorScheme.onSecondary
                                : theme.brightness == Brightness.light
                                ? const Color.fromARGB(92, 158, 158, 158)
                                : Colors.white24,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_toolbarLoaded)
                    Offstage(
                      offstage: !(_showFormattingToolbar && _showUndoRedo),
                      child: _toolbarLoaded
                          ? FormattingToolbar(controller: _quillController)
                          : SizedBox.shrink(),
                    ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).padding.bottom,
          color: _showFormattingToolbar
              ? Color(0xFF262626)
              : Theme.of(context).colorScheme.surfaceContainerLow,
        ),
      ),
    );
  }
}
