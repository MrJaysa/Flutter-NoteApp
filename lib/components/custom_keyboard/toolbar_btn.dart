import 'package:flutter/material.dart';

class ToolbarBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;

  const ToolbarBtn({
    super.key,
    required this.onTap,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        canRequestFocus: false,
        onTap: onTap,
        child: Center(child: child),
      ),
    );
  }
}
