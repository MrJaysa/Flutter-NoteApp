import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:test_app/components/custom_keyboard/background_palette.dart';
import 'package:test_app/components/custom_keyboard/color_palette.dart';
import 'package:test_app/components/custom_keyboard/editor_colors.dart';
import 'package:test_app/components/custom_keyboard/toolbar_btn.dart';
import 'package:test_app/components/custom_keyboard/toolbar_group.dart';

class FormattingToolbar extends StatefulWidget {
  final quill.QuillController controller;

  const FormattingToolbar({super.key, required this.controller});

  @override
  State<FormattingToolbar> createState() => _FormattingToolbarState();
}

class _FormattingToolbarState extends State<FormattingToolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: EditorColors.background,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToolbarGroup(
            height: 56,
            children: [
              ToolbarBtn(
                onTap: () => {},
                backgroundColor: Colors.transparent,
                child: const Text(
                  "H1",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
                ),
              ),
              ToolbarBtn(
                onTap: () => {},
                backgroundColor: Colors.transparent,
                child: const Text(
                  "H2",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
              ToolbarBtn(
                onTap: () => {},
                backgroundColor: Colors.transparent,
                child: const Text(
                  "H3",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
                ),
              ),
              ToolbarBtn(
                onTap: () => {},
                backgroundColor: Colors.transparent,
                child: const Text(
                  "H4",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                ),
              ),
              ToolbarBtn(
                onTap: () => {},
                backgroundColor: EditorColors.panelActive,
                child: const Text(
                  "body",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: ToolbarGroup(
                  height: 52,
                  children: [
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_bold),
                    ),
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_italic),
                    ),
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_underline),
                    ),
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_strikethrough),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ToolbarGroup(
                  height: 52,
                  children: [
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_indent_increase),
                    ),
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: Transform.flip(
                        flipX: true,
                        child: const Icon(Icons.format_indent_increase),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: ToolbarGroup(
                  height: 52,
                  children: [
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_list_numbered),
                    ),
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_list_bulleted),
                    ),
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.checklist),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 3,
                child: ToolbarGroup(
                  height: 52,
                  children: [
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: EditorColors.panelActive,
                      child: const Icon(Icons.format_align_left),
                    ),
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_align_center),
                    ),
                    ToolbarBtn(
                      onTap: () => {},
                      backgroundColor: Colors.transparent,
                      child: const Icon(Icons.format_align_right),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: EditorColors.panel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ColorPalette(
                    colors: EditorColors.textColors,
                    selectedColor: Colors.white,
                    onSelected: (_) => {},
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: EditorColors.panel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: BackgroundPalette(
                    colors: EditorColors.backgroundColors,
                    selectedColor: Color(0xFF6D4C41),
                    onSelected: (_) => {},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
