import 'package:flutter/material.dart';
import 'package:test_app/components/delete_modal.dart';

Future<bool?> showDeleteDialog(BuildContext context, int selectedCount) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => DeleteDialog(selectedCount: selectedCount, type: "Note"),
  );
}
