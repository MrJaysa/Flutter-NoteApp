import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:test_app/components/custom_keyboard/formatting_toolbar.dart';
import 'package:test_app/components/custom_quill_checkbox.dart';
import 'package:test_app/components/custom_quill_image_view.dart';

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
  late final quill.QuillController _quillController;

  final FocusNode _noteFocusNode = FocusNode();

  bool _hasContent = false;
  bool _showUndoRedo = false;

  bool _showFormattingToolbar = false;

  void _listenToKeyPressEnter(quill.DocChange change) {
    final delta = change.change;

    for (final op in delta.toList()) {
      if (op.isInsert &&
          op.data is String &&
          (op.data as String).contains('\n')) {
        final currentStyle = _quillController.getSelectionStyle();

        if (currentStyle.attributes.containsKey(quill.Attribute.checked.key)) {
          _quillController.formatSelection(quill.Attribute.unchecked);
        }
      }
    }
  }

  void _updateHasContent() {
    final hasContent =
        _titleController.text.trim().isNotEmpty ||
        !_quillController.document.isEmpty();

    if (hasContent != _hasContent) {
      setState(() {
        _hasContent = hasContent;
      });
    }

    setState(() {});
  }

  void _saveData() {
    final contentJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    debugPrint('Saving content: $contentJson');
    if (widget.id != null) {
      debugPrint(widget.id);
    } else {
      debugPrint('create new');
    }
  }

  void _deleteNote() {
    final id = widget.id;
    debugPrint('delete note $id');
  }

  quill.QuillController _initializeQuillContent(List<dynamic>? content) {
    if (content == null || content.isEmpty) {
      return quill.QuillController.basic();
    }

    final delta = List<dynamic>.from(content);

    final lastInsert = delta.last is Map ? delta.last['insert'] : null;

    if (lastInsert is String && !lastInsert.endsWith('\n')) {
      delta.add({'insert': '\n'});
    }

    return quill.QuillController(
      document: quill.Document.fromJson(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void initState() {
    super.initState();

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
      if (_showUndoRedo != _noteFocusNode.hasFocus) {
        setState(() {
          _showUndoRedo = _noteFocusNode.hasFocus;
        });
      }
      setState(() {
        _showFormattingToolbar = false;
      });
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

    if (queryResult.node != null && queryResult.node is quill.Line) {
      final quill.Line currentLineNode = queryResult.node as quill.Line;

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
        style.attributes.containsKey(quill.Attribute.checked.key) ||
        style.attributes.containsKey(quill.Attribute.unchecked.key);

    final bounds = getLineBounds();

    final (lineStart, lineEnd) = bounds;

    if (isChecklist) {
      if (lineEnd > 0) {
        _quillController.updateSelection(
          TextSelection.collapsed(offset: lineEnd),
          quill.ChangeSource.local,
        );

        _quillController.document.insert(lineEnd, '\n');

        _quillController.updateSelection(
          TextSelection.collapsed(offset: lineEnd + 1),
          quill.ChangeSource.local,
        );

        _quillController.formatSelection(
          quill.Attribute.clone(quill.Attribute.unchecked, null),
        );

        final imageIndex = _quillController.selection.baseOffset;

        _quillController.document.insert(
          imageIndex,
          quill.BlockEmbed.image(image.path),
        );

        _quillController.document.insert(imageIndex + 1, '\n');

        _quillController.updateSelection(
          TextSelection.collapsed(offset: imageIndex + 2),
          quill.ChangeSource.local,
        );
      } else {
        _quillController.formatSelection(
          quill.Attribute.clone(quill.Attribute.unchecked, null),
        );

        final imageIndex = _quillController.selection.baseOffset;

        _quillController.document.insert(
          imageIndex,
          quill.BlockEmbed.image(image.path),
        );

        _quillController.document.insert(imageIndex + 1, '\n');

        _quillController.updateSelection(
          TextSelection.collapsed(offset: imageIndex + 2),
          quill.ChangeSource.local,
        );
      }

      return;
    }

    if (lineEnd > 0) {
      _quillController.updateSelection(
        TextSelection.collapsed(offset: lineEnd),
        quill.ChangeSource.local,
      );

      _quillController.document.insert(lineEnd, '\n');

      _quillController.document.insert(
        lineEnd + 1,
        quill.BlockEmbed.image(image.path),
      );

      _quillController.document.insert(lineEnd + 2, '\n');

      _quillController.updateSelection(
        TextSelection.collapsed(offset: lineEnd + 3),
        quill.ChangeSource.local,
      );
    } else {
      _quillController.document.insert(
        lineStart,
        quill.BlockEmbed.image(image.path),
      );

      _quillController.document.insert(lineStart + 1, '\n');

      _quillController.updateSelection(
        TextSelection.collapsed(offset: lineStart + 2),
        quill.ChangeSource.local,
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
    final isChecklist =
        _quillController.getSelectionStyle().attributes.containsKey(
          quill.Attribute.unchecked.key,
        ) ||
        _quillController.getSelectionStyle().attributes.containsKey(
          quill.Attribute.checked.key,
        );

    if (_showFormattingToolbar) {
      setState(() {
        _showFormattingToolbar = false;
      });
    }
    if (isChecklist) {
      _quillController.formatSelection(
        quill.Attribute.clone(quill.Attribute.unchecked, null),
      );
    } else {
      _quillController.formatSelection(quill.Attribute.unchecked);
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
                    ? () => _quillController.undo()
                    : null,
                icon: const Icon(Icons.undo),
              ),
            if (_showUndoRedo)
              IconButton(
                onPressed: _quillController.hasRedo
                    ? () => _quillController.redo()
                    : null,
                icon: const Icon(Icons.redo),
              ),
            if (widget.id != null)
              IconButton(
                onPressed: _deleteNote,
                icon: const Icon(Icons.delete_outline_sharp),
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
                      const SizedBox(height: 36),
                      TextField(
                        controller: _titleController,
                        cursorColor: Colors.amber,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Title",
                          hintStyle: TextStyle(
                            color: Colors.white38,
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
                          ),
                          child: quill.QuillEditor.basic(
                            controller: _quillController,
                            focusNode: _noteFocusNode,
                            config: quill.QuillEditorConfig(
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
                              embedBuilders: [CustomImageEmbedBuilder()],
                              customStyles: quill.DefaultStyles(
                                placeHolder: quill.DefaultTextBlockStyle(
                                  const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 18,
                                  ),
                                  quill.HorizontalSpacing.zero,
                                  quill.VerticalSpacing.zero,
                                  quill.VerticalSpacing.zero,
                                  null,
                                ),
                                lists: quill.DefaultListBlockStyle(
                                  const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  const quill.HorizontalSpacing(0, 0),
                                  const quill.VerticalSpacing(0, 5),
                                  const quill.VerticalSpacing(0, 5),
                                  null,
                                  CustomQuillCheckboxBuilder(),
                                ),
                                paragraph: quill.DefaultTextBlockStyle(
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    height: 1.45,
                                  ),
                                  quill.HorizontalSpacing.zero,
                                  const quill.VerticalSpacing(0, 3),
                                  quill.VerticalSpacing.zero,
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
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                                      : Colors.white70
                                : Colors.white24,
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: _showUndoRedo ? _pickImage : null,
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: _showUndoRedo
                                ? Colors.white70
                                : Colors.white24,
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: _showUndoRedo ? _checkboxToggler : null,
                          icon: Icon(
                            Icons.check_box_outlined,
                            color: _showUndoRedo
                                ? Colors.white70
                                : Colors.white24,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_showFormattingToolbar && _showUndoRedo)
                    FormattingToolbar(controller: _quillController),
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
