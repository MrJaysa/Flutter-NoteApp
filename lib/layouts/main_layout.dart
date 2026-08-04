import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:notich/events/close_swipable_event.dart';
import 'package:notich/events/delete_event.dart';

class MainTabLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainTabLayout({super.key, required this.navigationShell});

  @override
  State<MainTabLayout> createState() => _MainTabLayoutState();
}

class _MainTabLayoutState extends State<MainTabLayout> {
  bool deleteItems = false;
  bool deletable = true;

  late StreamSubscription<DeleteEventState> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = deleteEventBus.stream.listen((state) {
      if (mounted) {
        setState(() {
          deleteItems = state.isChecked;
          deletable = state.isDeletable;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !deleteItems,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && deleteItems) {
          deleteEventBus.emitClose(true);
        }
      },
      child: SlidableAutoCloseBehavior(
        child: Scaffold(
          body: widget.navigationShell,

          bottomNavigationBar: deleteItems
              ? NavigationBar(
                  indicatorColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  destinations: [
                    const NavigationDestination(
                      icon: SizedBox.shrink(),
                      label: '',
                    ),
                    NavigationDestination(
                      icon: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 28, top: 18),
                          child: IconButton(
                            onPressed: () {
                              if (widget.navigationShell.currentIndex == 0) {
                                deleteEventBus.emitDeleteNoteClicked(true);
                              } else {
                                deleteEventBus.emitDeleteTodoClicked(true);
                              }
                            },
                            icon: Icon(
                              Icons.delete,
                              size: 24,
                              color: deletable ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      label: '',
                    ),
                  ],
                )
              : NavigationBarTheme(
                  data: NavigationBarThemeData(
                    indicatorColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    surfaceTintColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
                    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                      (states) => IconThemeData(
                        color: states.contains(WidgetState.selected)
                            ? Colors.amber
                            : theme.colorScheme.outline,
                      ),
                    ),

                    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                      (states) => TextStyle(
                        color: states.contains(WidgetState.selected)
                            ? Colors.amber
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ),

                  child: NavigationBar(
                    selectedIndex: widget.navigationShell.currentIndex,

                    onDestinationSelected: (index) {
                      if (widget.navigationShell.currentIndex == index) {
                        return;
                      }
                      closeSwipeableEventBus.emit();
                      Future.delayed(const Duration(milliseconds: 165), () {
                        widget.navigationShell.goBranch(index);
                      });
                    },

                    animationDuration: Duration.zero,

                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.description_outlined),
                        selectedIcon: Icon(Icons.description),
                        label: 'Notes',
                      ),

                      NavigationDestination(
                        icon: Icon(Icons.check_circle_outline_rounded),
                        selectedIcon: Icon(Icons.check_circle_rounded),
                        label: 'To-Dos',
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
