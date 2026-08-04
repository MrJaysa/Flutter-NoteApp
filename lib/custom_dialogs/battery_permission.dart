import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BatteryOptimizationHelper {
  static Future<void> requestDisableOptimization(BuildContext context) async {
    bool isOptimizedExempt =
        await Permission.ignoreBatteryOptimizations.isGranted;

    if (isOptimizedExempt) {
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enable Reliable Alarms'),
          content: const Text(
            'This app requires background execution to fire your todo reminders accurately when closed. '
            'Please select "Allow" or "Don\'t Optimize" on the next screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await Permission.ignoreBatteryOptimizations.request();
              },
              child: const Text('PROCEED'),
            ),
          ],
        );
      },
    );
  }
}
