// lib/src/core/controllers/menu_controller.dart
import 'package:flutter/material.dart';

class DropdownMenuController extends ChangeNotifier {
  final GlobalKey<PopupMenuButtonState<String>> todoMenuKey =
      GlobalKey<PopupMenuButtonState<String>>();

  void dismissMenu() {
    if (todoMenuKey.currentState != null &&
        todoMenuKey.currentContext != null) {
      Navigator.of(
        todoMenuKey.currentContext!,
      ).popUntil((route) => route.isFirst);
    }
  }
}

class MenuProvider extends InheritedNotifier<DropdownMenuController> {
  const MenuProvider({
    super.key,
    required DropdownMenuController super.notifier,
    required super.child,
  });

  static DropdownMenuController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<MenuProvider>();
    return provider?.notifier ?? DropdownMenuController();
  }
}
