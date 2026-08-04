import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:notich/events/close_swipable_event.dart';
import 'package:notich/helpers/date_formatter.dart';
import 'package:notich/helpers/note_preview.dart';
import 'package:notich/modals/delete_modal.dart';
import 'package:notich/models/model.dart';
import 'package:notich/models/note_db.dart';

enum NotePreviewType { checkbox, list, image, text }

class NoteCard extends StatefulWidget {
  final String id;
  final String title;
  final List<dynamic> content;
  final DateTime time;
  final Function longPress;
  final bool checkBoxVisible;
  final bool isChecked;
  final Function onCheckedChanged;
  final Function? reload;

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
    this.reload,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _slidableController = SlidableController(this);

    _subscription = closeSwipeableEventBus.stream.listen((_) {
      if (!mounted) return;

      if (_slidableController.ratio != 0) {
        _slidableController.close();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _deleteNote() async {
    if (!mounted) return;

    final confirmed = await showDeleteDialog(context, 1, "Note");

    if (confirmed == true) {
      await db.writeTxn(() async {
        await db.collection<NoteData>().delete(int.parse(widget.id));
      });

      widget.reload?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final preview = getNotePreview(widget.title, widget.content);

    void handleAction() {
      if (widget.checkBoxVisible) {
        widget.onCheckedChanged(!widget.isChecked);
      } else {
        context.push(
          '/add-note',
          extra: {
            'id': widget.id,
            'title': widget.title,
            'content': widget.content,
          },
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleAction,
      onLongPress: widget.checkBoxVisible ? null : () => widget.longPress(),
      child: Slidable(
        controller: _slidableController,
        enabled: !widget.checkBoxVisible,
        closeOnScroll: true,
        key: ValueKey(widget.id),
        groupTag: 'notes',

        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (_) {
                _deleteNote();
              },
              backgroundColor: Colors.transparent,
              child: Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),

        child: Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                                formatRelativeDate(widget.time),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSecondaryFixedVariant,
                                ),
                              ),

                              if (preview.text != '')
                                Text(
                                  preview.text,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme
                                        .colorScheme
                                        .onSecondaryFixedVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ],
                      ),

                      if (preview.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(preview.image!),
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                          ),
                        ),
                    ],
                  ),
                ),

                if (widget.checkBoxVisible)
                  Checkbox(
                    value: widget.isChecked,
                    onChanged: (value) => widget.onCheckedChanged(value),
                    activeColor: Colors.amber,
                    checkColor: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
