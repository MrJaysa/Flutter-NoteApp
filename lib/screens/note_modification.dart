import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:test_app/components/custom_quill_checkbox.dart';

class AddNoteScreen extends StatefulWidget {
  final String? id;
  final String? title;
  final String? content;

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

  void _listenToKeyPressEnter(quill.DocChange change) {
    // We only care about user actions that insert a newline character
    final delta = change.change;

    for (final op in delta.toList()) {
      // Detect when a newline (\n) string operation is added into the editor engine
      if (op.isInsert &&
          op.data is String &&
          (op.data as String).contains('\n')) {
        // Look at the active text style map exactly where the cursor is currently sitting
        final currentStyle = _quillController.getSelectionStyle();

        // If the line we are spawning from has an active "checked" layout flag
        if (currentStyle.attributes.containsKey(quill.Attribute.checked.key)) {
          // Immediately mutate the attribute rule of the new line back to "unchecked"
          _quillController.formatSelection(quill.Attribute.unchecked);
        }
      }
    }
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
    });
  }

  quill.QuillController _initializeQuillContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return quill.QuillController.basic();
    }
    try {
      final json = jsonDecode(content);
      return quill.QuillController(
        document: quill.Document.fromJson(json),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      // Fallback if historical data string was saved as plain unformatted text
      return quill.QuillController(
        document: quill.Document()..insert(0, content),
        selection: const TextSelection.collapsed(offset: 0),
      );
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
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateHasContent);
    _titleController.dispose();
    _quillController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _saveData() {
    // Extract formatted rich text data as a JSON string to retain headings/bold styles
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

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                            placeholder: "Note something down",
                            scrollable: true,
                            autoFocus: false,
                            expands: true,
                            padding: EdgeInsets.zero,

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

            AnimatedPadding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              duration: const Duration(milliseconds: 0),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  border: Border(
                    top: BorderSide(color: Colors.white.withAlpha(13)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _showUndoRedo ? () {} : null,
                      icon: Icon(
                        Icons.text_fields,
                        color: _showUndoRedo ? Colors.white70 : Colors.white24,
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: _showUndoRedo ? () {} : null,
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: _showUndoRedo ? Colors.white70 : Colors.white24,
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: _showUndoRedo
                          ? () {
                              final isChecklist =
                                  _quillController
                                      .getSelectionStyle()
                                      .attributes
                                      .containsKey(
                                        quill.Attribute.unchecked.key,
                                      ) ||
                                  _quillController
                                      .getSelectionStyle()
                                      .attributes
                                      .containsKey(quill.Attribute.checked.key);

                              if (isChecklist) {
                                _quillController.formatSelection(
                                  quill.Attribute.clone(
                                    quill.Attribute.unchecked,
                                    null,
                                  ),
                                );
                              } else {
                                _quillController.formatSelection(
                                  quill.Attribute.unchecked,
                                );
                              }
                            }
                          : null,
                      icon: Icon(
                        Icons.check_box_outlined,
                        color: _showUndoRedo ? Colors.white70 : Colors.white24,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
