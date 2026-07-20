// lib/src/components/todo_pop_menu.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TodoSortMenu extends StatefulWidget {
  final ValueChanged<String> onSortChanged;

  const TodoSortMenu({super.key, required this.onSortChanged});

  @override
  State<TodoSortMenu> createState() => _TodoSortMenuState();
}

class _TodoSortMenuState extends State<TodoSortMenu> {
  String _currentSort = 'latest';
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  GoRouterDelegate? _routerDelegate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routerDelegate?.removeListener(_onRouteChanged);
    _routerDelegate = GoRouter.of(context).routerDelegate
      ..addListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    if (_overlayEntry != null &&
        mounted &&
        GoRouterState.of(context).uri.path != '/todo') {
      _closeMenu();
    }
  }

  @override
  void dispose() {
    _routerDelegate?.removeListener(_onRouteChanged);
    _closeMenu();
    super.dispose();
  }

  void _toggleMenu() {
    _overlayEntry == null ? _openMenu() : _closeMenu();
  }

  void _openMenu() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _closeMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      if (mounted) setState(() {});
    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Size size = renderBox?.size ?? Size.zero;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeMenu,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
          Positioned(
            width: 220,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(size.width - 220, size.height + 4),
              child: Material(
                elevation: 4,
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem('latest', 'Sort by the Latest'),
                      _buildMenuItem('alert_time', 'Sort by Alert Time'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String value, String title) {
    final bool isSelected = _currentSort == value;
    return InkWell(
      onTap: () {
        setState(() => _currentSort = value);
        widget.onSortChanged(value);
        _closeMenu();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.amber, size: 18)
                  : null,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(color: isSelected ? Colors.amber : Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        icon: const Icon(Icons.sort),
        color: _overlayEntry != null ? Colors.amber : Colors.white,
        onPressed: _toggleMenu,
      ),
    );
  }
}
