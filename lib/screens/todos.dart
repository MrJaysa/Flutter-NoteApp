import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/components/add_todo_sheet.dart';
import 'package:test_app/components/delete_modal.dart';
import 'package:test_app/components/todo_pop_menu.dart';
import 'package:test_app/components/todo_tile.dart';
import 'package:test_app/events/delete_event.dart';

class TodoItemData {
  final String id;
  final String title;
  final DateTime time;

  const TodoItemData({
    required this.id,
    required this.title,
    required this.time,
  });
}

class SelectedTodos {
  final List<String> completed;
  final List<String> pending;

  SelectedTodos({List<String>? completed, List<String>? pending})
    : completed = completed ?? [],
      pending = pending ?? [];
}

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  bool completedExpanded = false;
  bool checkState = false;

  final List<TodoItemData> _pendingTodos = [
    TodoItemData(id: '1', title: "Testing_1", time: DateTime.now()),
    TodoItemData(id: '2', title: "Testing_2", time: DateTime.now()),
    TodoItemData(id: '3', title: "Testing_3", time: DateTime.now()),
    TodoItemData(id: '4', title: "Testing_4", time: DateTime.now()),
  ];

  final List<TodoItemData> _doneTodos = [
    TodoItemData(id: '5', title: "Testing_5", time: DateTime.now()),
    TodoItemData(id: '6', title: "Testing_6", time: DateTime.now()),
    TodoItemData(id: '7', title: "Testing_7", time: DateTime.now()),
    TodoItemData(id: '8', title: "Testing_8", time: DateTime.now()),
  ];

  final SelectedTodos _selectedTodos = SelectedTodos();

  void toggleDone(bool state, String id, bool isDone) {
    setState(() {
      if (!isDone) {
        final index = _pendingTodos.indexWhere((todo) => todo.id == id);
        if (index == -1) return;

        final todo = _pendingTodos.removeAt(index);
        _doneTodos.insert(0, todo); // Prepend
      } else {
        final index = _doneTodos.indexWhere((todo) => todo.id == id);
        if (index == -1) return;

        final todo = _doneTodos.removeAt(index);
        _pendingTodos.insert(0, todo); // Prepend
      }
    });
  }

  void _longPressDetected(String id, bool isDone) {
    setState(() {
      checkState = true;
      if (isDone) {
        _selectedTodos.completed.add(id);
      } else {
        _selectedTodos.pending.add(id);
      }
    });
    deleteEventBus.emitChecked(true);
    deleteEventBus.emitDeletable(true);
  }

  void checkToggle(bool checked, String id, bool isDone) {
    setState(() {
      if (checked) {
        if (isDone) {
          _selectedTodos.completed.add(id);
        } else {
          _selectedTodos.pending.add(id);
        }
      } else {
        if (isDone) {
          _selectedTodos.completed.remove(id);
        } else {
          _selectedTodos.pending.remove(id);
        }
      }
    });
    deleteEventBus.emitDeletable(
      _selectedTodos.completed.isNotEmpty || _selectedTodos.pending.isNotEmpty,
    );
  }

  void _selectionToggle(bool selected) {
    setState(() {
      if (selected) {
        _selectedTodos.pending
          ..clear()
          ..addAll(_pendingTodos.map((e) => e.id));
        _selectedTodos.completed
          ..clear()
          ..addAll(_doneTodos.map((e) => e.id));
        deleteEventBus.emitDeletable(true);
      } else {
        _selectedTodos.completed.clear();
        _selectedTodos.pending.clear();
        deleteEventBus.emitDeletable(false);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      checkState = false;
      _selectedTodos.completed.clear();
      _selectedTodos.pending.clear();
    });
    deleteEventBus.emitChecked(false);
  }

  String get appBarTitle {
    if (!checkState) return 'To-do';

    final count =
        _selectedTodos.pending.length + _selectedTodos.completed.length;

    if (count == 0) return 'None Selected';
    if (count == 1) return '1 Item Selected';
    return '$count Items Selected';
  }

  Future<bool?> showDeleteDialog(BuildContext context, int selectedCount) {
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DeleteDialog(selectedCount: selectedCount, type: "Todo"),
    );
  }

  void _showTodoDialog({String? text, DateTime? date}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddTodoSheet(title: text, date: date),
    );
  }

  // ignore: unused_field
  late StreamSubscription<bool> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = deleteEventBus.deleteTodoClickedStream.listen((
      clicked,
    ) async {
      if (!clicked || !mounted) return;

      final navigator = Navigator.of(context);

      final confirmed = await showDeleteDialog(
        navigator.context,
        (_selectedTodos.completed.length + _selectedTodos.pending.length),
      );

      deleteEventBus.emitDeleteTodoClicked(false);

      if (confirmed == true) {
        setState(() {
          if (_selectedTodos.pending.isNotEmpty) {
            _pendingTodos.removeWhere(
              (note) => _selectedTodos.pending.contains(note.id),
            );
          }
          if (_selectedTodos.completed.isNotEmpty) {
            _doneTodos.removeWhere(
              (note) => _selectedTodos.completed.contains(note.id),
            );
          }
        });
        _clearSelection();
      }
    });

    _subscription = deleteEventBus.backBtnClickedStream.listen((clicked) {
      if (!clicked || !mounted) return;
      _clearSelection();
      deleteEventBus.emitClose(false);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPendingNotEmpty = _pendingTodos.isNotEmpty;
    final bool isDoneNotEmpty = _doneTodos.isNotEmpty;
    final bool isPendingEmpty = _pendingTodos.isEmpty;
    final bool isDoneEmpty = _doneTodos.isEmpty;
    final bool showSearch = (_pendingTodos.length + _doneTodos.length) > 5;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (showSearch)
            SliverAppBar.medium(
              expandedHeight: 180,
              collapsedHeight: 140,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                collapseMode: CollapseMode.parallax,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appBarTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Hero(
                      tag: 'todo',
                      child: Material(
                        type: MaterialType.transparency,
                        child: SizedBox(
                          height: 35,
                          child: InkWell(
                            onTap: checkState
                                ? null
                                : () => context.push(
                                    '/search',
                                    extra: {"type": "todo"},
                                  ),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 35,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                color: checkState
                                    ? const Color.fromARGB(
                                        58,
                                        52,
                                        51,
                                        51,
                                      ).withValues(alpha: 0.15)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 16,
                                    color: checkState
                                        ? const Color.fromARGB(255, 54, 53, 53)
                                        : const Color.fromARGB(
                                            255,
                                            106,
                                            104,
                                            104,
                                          ),
                                  ),

                                  const SizedBox(width: 3),

                                  Text(
                                    'Search',
                                    style: TextStyle(
                                      color: checkState
                                          ? const Color.fromARGB(
                                              255,
                                              43,
                                              43,
                                              43,
                                            )
                                          : Colors.white38,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              backgroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.scrolledUnder)) {
                  return Colors.black;
                }
                return Colors.transparent;
              }),

              foregroundColor: Colors.white,

              actions: checkState
                  ? [
                      IconButton(
                        onPressed: _clearSelection,
                        icon: const Icon(Icons.close),
                      ),
                      Checkbox(
                        value:
                            (_selectedTodos.completed.length +
                                    _selectedTodos.pending.length) ==
                                (_pendingTodos.length + _doneTodos.length) &&
                            (_pendingTodos.isNotEmpty || _doneTodos.isNotEmpty),
                        onChanged: (value) => _selectionToggle(value ?? false),
                        activeColor: Colors.amber,
                        checkColor: Colors.white,
                      ),
                    ]
                  : [TodoSortMenu(onSortChanged: (String newSortRule) {})],
            )
          else
            SliverAppBar.medium(
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  appBarTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                titlePadding: EdgeInsetsDirectional.only(start: 16, bottom: 16),
                collapseMode: CollapseMode.parallax,
              ),
              backgroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.scrolledUnder)) {
                  return Colors.black;
                }
                return Colors.transparent;
              }),
              foregroundColor: Colors.white,
              actions: checkState
                  ? [
                      IconButton(
                        onPressed: _clearSelection,
                        icon: const Icon(Icons.close),
                      ),
                      Checkbox(
                        value:
                            (_selectedTodos.completed.length +
                                    _selectedTodos.pending.length) ==
                                (_pendingTodos.length + _doneTodos.length) &&
                            (_pendingTodos.isNotEmpty || _doneTodos.isNotEmpty),
                        onChanged: (value) => _selectionToggle(value ?? false),
                        activeColor: Colors.amber,
                        checkColor: Colors.white,
                      ),
                    ]
                  : [TodoSortMenu(onSortChanged: (String newSortRule) {})],
            ),

          if (isPendingEmpty && isDoneEmpty)
            SliverFillRemaining(
              hasScrollBody: true,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 80,
                      color: Colors.white30,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'None',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (isPendingNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text('Not Completed'),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final todo = _pendingTodos[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TodoItemTile(
                      key: ValueKey(todo.id),
                      id: todo.id,
                      title: todo.title,
                      time: todo.time,
                      isDone: false,
                      checkBoxVisible: checkState,
                      toggleDone: toggleDone,
                      longPress: _longPressDetected,
                      onCheckedChanged: checkToggle,
                      onEdit: () =>
                          _showTodoDialog(text: todo.title, date: todo.time),
                      isChecked: _selectedTodos.pending.contains(todo.id),
                    ),
                  );
                }, childCount: _pendingTodos.length),
              ),
            ],

            if (isDoneNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          completedExpanded = !completedExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: completedExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.expand_more),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (completedExpanded)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final todo = _doneTodos[index];

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: TodoItemTile(
                        key: ValueKey(todo.id),
                        id: todo.id,
                        title: todo.title,
                        time: todo.time,
                        isDone: true,
                        checkBoxVisible: checkState,
                        toggleDone: toggleDone,
                        longPress: _longPressDetected,
                        onCheckedChanged: checkToggle,
                        onEdit: () =>
                            _showTodoDialog(text: todo.title, date: todo.time),
                        isChecked: _selectedTodos.completed.contains(todo.id),
                      ),
                    );
                  }, childCount: _doneTodos.length),
                ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 112)),
          ],
        ],
      ),

      floatingActionButton: !checkState
          ? FloatingActionButton(
              onPressed: _showTodoDialog,
              backgroundColor: const Color(0xFF2B2A2A),
              foregroundColor: Colors.amber,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
