// lib/components/reminder_picker/reminder_footer.dart

import 'package:flutter/material.dart';

class ReminderFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const ReminderFooter({
    super.key,
    required this.onCancel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onCancel,
                    child: const Center(
                      child: Text("Cancel", style: TextStyle(fontSize: 17)),
                    ),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                  color: const Color.fromARGB(81, 105, 104, 104),
                  // color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: InkWell(
                    onTap: onDone,
                    child: const Center(
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
