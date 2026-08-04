import 'package:flutter/material.dart';

Future<String?> showThemeDialog(
  BuildContext context, {
  required String selectedTheme,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => ThemeDialog(selectedTheme: selectedTheme),
  );
}

class ThemeDialog extends StatefulWidget {
  const ThemeDialog({super.key, required this.selectedTheme});

  final String selectedTheme;

  @override
  State<ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<ThemeDialog> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selectedTheme;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose theme'),
      contentPadding: const EdgeInsets.only(top: 8),
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      content: RadioGroup<String>(
        groupValue: selected,
        onChanged: (value) {
          setState(() {
            selected = value!;
          });
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'system',
              title: Text('System default'),
            ),
            RadioListTile<String>(value: 'light', title: Text('Light')),
            RadioListTile<String>(value: 'dark', title: Text('Dark')),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selected),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
