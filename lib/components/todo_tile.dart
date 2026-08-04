import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:notich/events/close_swipable_event.dart';
import 'package:notich/modals/delete_modal.dart';
import 'package:notich/models/model.dart';
import 'package:notich/models/todo_db.dart';

class TodoItemTile extends StatefulWidget {
  final String id;
  final String title;
  final DateTime? time;
  final bool isDone;
  final bool checkBoxVisible;
  final bool isChecked;
  final Function toggleDone;
  final Function? longPress;
  final Function onCheckedChanged;
  final Function onEdit;
  final bool isScreenVisible;
  final Function? reload;

  const TodoItemTile({
    super.key,
    required this.id,
    required this.title,
    this.time,
    required this.isDone,
    required this.checkBoxVisible,
    required this.isChecked,
    required this.toggleDone,
    this.longPress,
    required this.onCheckedChanged,
    required this.onEdit,
    required this.isScreenVisible,
    this.reload,
  });

  @override
  State<TodoItemTile> createState() => _TodoItemTileState();
}

class _TodoItemTileState extends State<TodoItemTile>
    with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _slidableController = SlidableController(this);

    _subscription = closeSwipeableEventBus.stream.listen((_) async {
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
        await db.collection<TodoData>().delete(int.parse(widget.id));
      });

      widget.reload?.call();
    }
  }

  Stream<void> _minuteTick() async* {
    final now = DateTime.now();

    await Future.delayed(
      Duration(minutes: 1) -
          Duration(
            seconds: now.second,
            milliseconds: now.millisecond,
            microseconds: now.microsecond,
          ),
    );

    yield null;

    yield* Stream.periodic(const Duration(minutes: 1), (_) {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.checkBoxVisible
          ? () => widget.onCheckedChanged(
              !widget.isChecked,
              widget.id,
              widget.isDone,
            )
          : null,
      onLongPress: widget.checkBoxVisible
          ? null
          : widget.longPress != null
          ? () => widget.longPress?.call(widget.id, widget.isDone)
          : null,
      child: Slidable(
        controller: _slidableController,
        enabled: !widget.checkBoxVisible,
        closeOnScroll: true,
        key: ValueKey(widget.id),
        groupTag: 'todos',
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              spacing: 8,
              children: [
                if (!widget.checkBoxVisible)
                  Transform.scale(
                    scale: 1.1,
                    child: Checkbox(
                      value: widget.isDone,
                      shape: const CircleBorder(),
                      side: BorderSide(
                        width: 1,
                        color: theme.brightness == Brightness.dark
                            ? const Color.fromARGB(255, 85, 85, 85)
                            : const Color.fromARGB(130, 158, 158, 158),
                      ),
                      onChanged: (checked) =>
                          widget.toggleDone(checked, widget.id, widget.isDone),
                      activeColor: theme.brightness == Brightness.dark
                          ? const Color.fromARGB(255, 85, 85, 85)
                          : const Color.fromARGB(130, 158, 158, 158),
                      checkColor: theme.brightness == Brightness.dark
                          ? const Color.fromARGB(255, 34, 34, 34)
                          : Colors.white,
                    ),
                  ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.checkBoxVisible
                        ? null
                        : () => widget.onEdit(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: widget.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),

                        if (widget.time != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              const Icon(
                                Icons.alarm_outlined,
                                size: 14,
                                color: Colors.blueGrey,
                              ),
                              StreamBuilder<void>(
                                stream:
                                    widget.isScreenVisible &&
                                        widget.time!.isAfter(DateTime.now())
                                    ? _minuteTick()
                                    : const Stream.empty(),
                                builder: (context, snapshot) {
                                  final now = DateTime.now();

                                  return Text(
                                    DateFormat(
                                      'MM/dd HH:mm',
                                    ).format(widget.time!),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          widget.time!.isBefore(now) &&
                                              !widget.isDone
                                          ? Colors.red
                                          : theme
                                                .colorScheme
                                                .onSecondaryFixedVariant,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.checkBoxVisible)
                  Checkbox(
                    value: widget.isChecked,
                    onChanged: (state) => widget.onCheckedChanged(
                      state,
                      widget.id,
                      widget.isDone,
                    ),
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
