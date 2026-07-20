// lib/src/components/add_todo_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_app/components/reminder_modal/reminder_picker.dart';

class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final TextEditingController _todoController = TextEditingController();
  DateTime? selectedDate;
  bool canSave = false;

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

  Future<void> _pickDateTime() async {
    final result = await showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reminder',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) =>
          ReminderPicker(initialDate: selectedDate ?? DateTime.now()),
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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Wrap the entire layout inside a native SafeArea
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          // 2. Adjusts automatically for the typing keyboard height
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'New Todo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _todoController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a To-do item',
                hintStyle: TextStyle(color: theme.colorScheme.onInverseSurface),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 56, 55, 55),
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
