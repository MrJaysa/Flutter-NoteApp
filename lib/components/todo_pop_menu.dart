// lib/src/components/todo_pop_menu.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notich/events/close_swipable_event.dart';

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
    closeSwipeableEventBus.emit();
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
            width: 210,
            right: 10,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(size.width - 220, size.height + 4),
              child: Material(
                elevation: 4,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            SizedBox(
              width: 30,
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.amber, size: 24)
                  : null,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight(500),
                color: isSelected ? Colors.amber : null,
              ),
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
        icon: Icon(Icons.sort, color: Theme.of(context).colorScheme.tertiary),
        color: _overlayEntry != null ? Colors.amber : Colors.white,
        onPressed: _toggleMenu,
      ),
    );
  }
}
