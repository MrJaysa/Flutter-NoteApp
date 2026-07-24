import 'package:flutter/material.dart';

import 'editor_colors.dart';

class BackgroundPalette extends StatelessWidget {
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onSelected;
  final bool showBorder;

  const BackgroundPalette({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: colors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 15),
        itemBuilder: (_, index) {
          final color = colors[index];
          final selected = color == selectedColor;

          return GestureDetector(
            onTap: () => onSelected(color),
            child: Container(
              width: 35,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: selected
                    ? Border.all(color: EditorColors.panelActive, width: 1)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                "A",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
