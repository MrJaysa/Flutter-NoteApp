// lib/components/reminder_picker/reminder_header.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderHeader extends StatelessWidget {
  final DateTime date;

  const ReminderHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          DateFormat("EEEE, MMMM d, yyyy 'at' h:mm a").format(date),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
