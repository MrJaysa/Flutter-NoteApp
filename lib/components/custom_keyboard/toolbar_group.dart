import 'package:flutter/material.dart';

import 'editor_colors.dart';

class ToolbarGroup extends StatelessWidget {
  final double height;
  final List<Widget> children;

  const ToolbarGroup({super.key, required this.height, required this.children});

  @override
  Widget build(BuildContext context) {
    List<Widget> splitChildren = [];

    for (int i = 0; i < children.length; i++) {
      splitChildren.add(Expanded(child: children[i]));

      if (i < children.length - 1) {
        splitChildren.add(
          VerticalDivider(
            color: Colors.black.withValues(alpha: 0.3),
            width: 1,
            thickness: 1,
            indent: 1,
            endIndent: 1,
          ),
        );
      }
    }

    return SizedBox(
      height: height,
      child: Material(
        color: EditorColors.panel,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(children: splitChildren),
        ),
      ),
    );
  }
}
