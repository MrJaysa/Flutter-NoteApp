import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notich/helpers/notification.dart';

import 'reminder_footer.dart';
import 'reminder_header.dart';
import 'reminder_wheel.dart';

class ReminderPicker extends StatefulWidget {
  final DateTime initialDate;

  const ReminderPicker({super.key, required this.initialDate});

  @override
  State<ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  late final List<DateTime> _days;

  late int _dayIndex;
  late int _hour;
  late int _minute;

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  Future<void> initializeLocalNotification() async {
    await NotificationService().requestionNotificationPermission();
  }

  @override
  void initState() {
    super.initState();
    initializeLocalNotification();

    final today = DateTime.now();

    final startOfYear = DateTime(today.year, 1, 1);
    final startOfNextYear = DateTime(today.year + 1, 1, 1);

    final daysInYear = startOfNextYear.difference(startOfYear).inDays;

    _days = List.generate(
      daysInYear,
      (i) => startOfYear.add(Duration(days: i)),
    );

    _dayIndex = _days.indexWhere(
      (e) =>
          e.year == widget.initialDate.year &&
          e.month == widget.initialDate.month &&
          e.day == widget.initialDate.day,
    );

    if (_dayIndex < 0) {
      _dayIndex = 0;
    }

    _hour = widget.initialDate.hour;
    _minute = widget.initialDate.minute;
  }

  DateTime get selectedDate => DateTime(
    _days[_dayIndex].year,
    _days[_dayIndex].month,
    _days[_dayIndex].day,
    _hour,
    _minute,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            borderRadius: BorderRadius.circular(30),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 360,
              child: Column(
                children: [
                  ReminderHeader(date: selectedDate),

                  Expanded(
                    child: ClipRect(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 6,
                          children: [
                            ReminderWheel(
                              width: 150,
                              items: _days
                                  .map((e) => DateFormat("MMM d").format(e))
                                  .toList(),
                              initialIndex: _dayIndex,
                              onChanged: (value) {
                                setState(() {
                                  _dayIndex = value;
                                });
                              },
                            ),
                            ReminderWheel(
                              width: 60,
                              items: List.generate(
                                24,
                                (i) => i.toString().padLeft(2, '0'),
                              ),
                              initialIndex: _hour,
                              onChanged: (value) {
                                setState(() {
                                  _hour = value;
                                });
                              },
                            ),
                            ReminderWheel(
                              width: 60,
                              items: List.generate(
                                60,
                                (i) => i.toString().padLeft(2, '0'),
                              ),
                              initialIndex: _minute,
                              onChanged: (value) {
                                setState(() {
                                  _minute = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  ReminderFooter(
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onDone: () {
                      Navigator.pop(context, selectedDate);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
