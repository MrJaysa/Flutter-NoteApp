import 'package:flutter/material.dart';

import 'editor_colors.dart';

class ToolbarGroup extends StatelessWidget {
  final double height;
  final List<Widget> children;

  const ToolbarGroup({super.key, required this.height, required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: EditorColors.panel,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: children.map((child) => Expanded(child: child)).toList(),
          ),
        ),
      ),
    );
  }
}
