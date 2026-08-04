import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final int selectedCount;
  final String type;

  const DeleteDialog({
    super.key,
    required this.selectedCount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final typeTitle = '$type${selectedCount == 1 ? "" : "s"}';
    final title = selectedCount == 1
        ? 'Delete $type?'
        : 'Delete $selectedCount $typeTitle?';

    final description = selectedCount == 1
        ? 'This ${type.toLowerCase()} will be permanently deleted. This action cannot be undone.'
        : 'These ${typeTitle.toLowerCase()} will be permanently deleted. This action cannot be undone.';

    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              description,
              style: TextStyle(
                color: theme.colorScheme.onSecondary,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: theme.colorScheme.onTertiary),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
