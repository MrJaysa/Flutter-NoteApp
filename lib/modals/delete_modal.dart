import 'package:flutter/material.dart';
import 'package:notich/components/delete_modal.dart';

Future<bool?> showDeleteDialog(
  BuildContext context,
  int selectedCount,
  String type,
) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => DeleteDialog(selectedCount: selectedCount, type: type),
  );
}
