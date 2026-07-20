import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoteCard extends StatelessWidget {
  final String id;
  final String title;
  final String content;
  final Function longPress;
  final bool checkBoxVisible;
  final bool isChecked;
  final Function onCheckedChanged;

  const NoteCard({
    super.key,
    required this.id,
    required this.title,
    required this.content,
    required this.longPress,
    required this.checkBoxVisible,
    required this.isChecked,
    required this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void handleAction() {
      if (checkBoxVisible) {
        onCheckedChanged(!isChecked);
      } else {
        context.push(
          '/add-note',
          extra: {'id': id, 'title': title, 'content': content},
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => handleAction(),
      onLongPress: () => checkBoxVisible ? null : longPress(),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryFixedVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (checkBoxVisible)
                Checkbox(
                  value: isChecked,
                  onChanged: (value) => onCheckedChanged(value),
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
