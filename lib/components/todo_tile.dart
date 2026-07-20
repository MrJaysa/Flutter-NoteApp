import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoItemTile extends StatelessWidget {
  final String id;
  final String title;
  final DateTime time;
  final bool isDone;
  final bool checkBoxVisible;
  final bool isChecked;
  final Function toggleDone;
  final Function longPress;
  final Function onCheckedChanged;

  const TodoItemTile({
    super.key,
    required this.id,
    required this.title,
    required this.time,
    required this.isDone,
    required this.checkBoxVisible,
    required this.isChecked,
    required this.toggleDone,
    required this.longPress,
    required this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          checkBoxVisible ? onCheckedChanged(!isChecked, id, isDone) : null,
      onLongPress: () => checkBoxVisible ? null : longPress(id, isDone),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Row(
            children: [
              if (!checkBoxVisible)
                Checkbox(
                  value: isDone,
                  shape: const CircleBorder(),
                  onChanged: (checked) => toggleDone(checked, id, isDone),
                  activeColor: const Color.fromARGB(255, 85, 85, 85),
                  checkColor: const Color.fromARGB(255, 34, 34, 34),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow
                          .ellipsis, // Clean fallback if text exceeds 3 lines
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alarm_outlined,
                          size: 14,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MM/dd HH:mm').format(time),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryFixedVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (checkBoxVisible)
                Checkbox(
                  value: isChecked,
                  onChanged: (state) => onCheckedChanged(state, id, isDone),
                  activeColor: Colors.amber,
                  checkColor: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
