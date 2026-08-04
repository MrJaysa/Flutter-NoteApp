import 'package:flutter/material.dart';

class ReminderWheel extends StatefulWidget {
  const ReminderWheel({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onChanged,
    this.width = 120,
  });

  final List<String> items;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final double width;

  @override
  State<ReminderWheel> createState() => _ReminderWheelState();
}

class _ReminderWheelState extends State<ReminderWheel> {
  late final FixedExtentScrollController controller;

  late int _selected;

  @override
  void initState() {
    super.initState();

    _selected = widget.initialIndex;

    controller = FixedExtentScrollController(initialItem: widget.initialIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _scrollTo(int index) {
    final current = controller.selectedItem;
    final length = widget.items.length;

    final currentIndex = current % length;

    int delta = index - currentIndex;

    if (delta > length ~/ 2) {
      delta -= length;
    } else if (delta < -(length ~/ 2)) {
      delta += length;
    }

    controller.animateToItem(
      current + delta,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: 100,
        perspective: 0.00001,
        squeeze: 1,
        useMagnifier: false,
        overAndUnderCenterOpacity: 1,
        renderChildrenOutsideViewport: true,
        clipBehavior: Clip.none,
        itemExtent: 44,
        onSelectedItemChanged: (value) {
          final selected = value % widget.items.length;

          setState(() {
            _selected = selected;
          });

          widget.onChanged(selected);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(
            widget.items.length,
            (index) => _WheelItem(
              selected: _selected,
              itemCount: widget.items.length,
              index: index,
              text: widget.items[index],
              onTap: () => _scrollTo(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelItem extends StatelessWidget {
  const _WheelItem({
    required this.selected,
    required this.itemCount,
    required this.index,
    required this.text,
    required this.onTap,
  });

  final int selected;
  final int itemCount;
  final int index;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    int distance = (selected - index).abs();
    distance = distance > itemCount ~/ 2 ? itemCount - distance : distance;

    double opacity;
    double fontSize;
    FontWeight weight;

    switch (distance) {
      case 0:
        opacity = 1;
        fontSize = 24;
        weight = FontWeight.w600;
        break;
      case 1:
        opacity = .65;
        fontSize = 19;
        weight = FontWeight.w500;
        break;
      default:
        opacity = .25;
        fontSize = 16;
        weight = FontWeight.w400;
    }
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: opacity,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 120),
              style: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: fontSize,
                fontWeight: weight,
              ),
              child: Text(text, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
