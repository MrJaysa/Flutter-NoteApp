import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notich/components/reminder_modal/reminder_picker.dart';
import 'package:notich/helpers/notification.dart';
import 'package:notich/models/model.dart';
import 'package:notich/models/todo_db.dart';

class AddTodoSheet extends StatefulWidget {
  final String? title;
  final DateTime? date;
  final int? id;
  final bool? isDone;

  const AddTodoSheet({super.key, this.title, this.date, this.id, this.isDone});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  late final TextEditingController _todoController = TextEditingController(
    text: widget.title,
  );
  late DateTime? selectedDate = widget.date;
  bool canSave = false;

  Future<void> _pickDateTime() async {
    final result = await showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reminder',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => ReminderPicker(initialDate: DateTime.now()),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
    );

    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  Future<void> _saveData() async {
    final perm = await NotificationService().verifyNotificationPermission();

    final todo = TodoData(
      title: _todoController.text.trim(),
      time: selectedDate,
      updatedAt: DateTime.now(),
      completed: false,
    );

    if (widget.id != null) {
      final id = widget.id;
      final done = widget.isDone;
      todo.id = id!;
      todo.completed = done == true;
    }

    final todoId = await db.writeTxn(() async {
      return await db.collection<TodoData>().put(todo);
    });

    if (perm && await NotificationService().notificationExists(todoId)) {
      await NotificationService().plugin.cancel(id: todoId);
    }

    if (perm && selectedDate != null && selectedDate!.isAfter(DateTime.now())) {
      await NotificationService().scheduleTodoAlarm(
        id: todoId,
        title: _todoController.text.trim(),
        time: selectedDate!,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    _todoController.addListener(() {
      final value = _todoController.text.trim().isNotEmpty;
      if (value != canSave) {
        setState(() => canSave = value);
      }
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title != null ? 'Edit Todo' : 'New Todo',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _todoController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Add a To-do item',
                hintStyle: TextStyle(
                  color: const Color.fromARGB(147, 158, 158, 158),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(84, 56, 55, 55),
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: _pickDateTime,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        foregroundColor: theme.colorScheme.onSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: const Radius.circular(34),
                            right: Radius.circular(
                              selectedDate == null ? 34 : 0,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alarm_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            selectedDate == null
                                ? 'Set alerts'
                                : DateFormat(
                                    'MM/dd HH:mm',
                                  ).format(selectedDate!),
                          ),
                        ],
                      ),
                    ),
                    if (selectedDate != null)
                      FilledButton(
                        onPressed: () => setState(() => selectedDate = null),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(42, 40),
                          padding: EdgeInsets.zero,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(34),
                            ),
                          ),
                        ),
                        child: const Icon(Icons.close, size: 18),
                      ),
                  ],
                ),
                const Spacer(),
                FilledButton(
                  onPressed: canSave ? _saveData : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    foregroundColor: Colors.amber,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
