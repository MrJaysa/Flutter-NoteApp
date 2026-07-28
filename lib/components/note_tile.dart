import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/helpers/date_formatter.dart';
import 'package:test_app/helpers/note_preview.dart';

enum NotePreviewType { checkbox, list, image, text }

class NoteCard extends StatelessWidget {
  final String id;
  final String title;
  final List<dynamic> content;
  final DateTime time;
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
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final preview = getNotePreview(title, content);

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

    debugPrint('test ${preview.image != ''}');

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          preview.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          spacing: 10,
                          children: [
                            Text(
                              formatRelativeDate(time),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    theme.colorScheme.onSecondaryFixedVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (preview.text != '')
                              Text(
                                preview.text,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSecondaryFixedVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (preview.image != '')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(preview.image ?? ""),
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
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
