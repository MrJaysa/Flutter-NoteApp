import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:notich/components/add_todo_sheet.dart';
import 'package:notich/components/todo_pop_menu.dart';
import 'package:notich/components/todo_tile.dart';
import 'package:notich/events/close_swipable_event.dart';
import 'package:notich/events/delete_event.dart';
import 'package:notich/helpers/notification.dart';
import 'package:notich/modals/delete_modal.dart' show showDeleteDialog;
import 'package:notich/models/model.dart';
import 'package:notich/models/todo_db.dart';

class TodoItemData {
  final String id;
  final String title;
  final DateTime? time;
  final bool? completed;

  const TodoItemData({
    required this.id,
    required this.title,
    this.completed,
    this.time,
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
  List<TodoItemData> _pendingTodos = [];
  List<TodoItemData> _doneTodos = [];
  final SelectedTodos _selectedTodos = SelectedTodos();
  final collection = db.collection<TodoData>();
  bool _sortNewestFirst = true;

  Query<TodoData> _buildQuery({required bool state}) {
    return _sortNewestFirst
        ? collection
              .filter()
              .completedEqualTo(state)
              .sortByUpdatedAtDesc()
              .build()
        : collection.filter().completedEqualTo(state).sortByTimeDesc().build();
  }

  late Query<TodoData> _pendingTodosQuery = _buildQuery(state: false);
  late Query<TodoData> _doneTodosQuery = _buildQuery(state: true);

  bool completedExpanded = false;
  bool checkState = false;

  String get appBarTitle {
    if (!checkState) return 'To-do';

    final count =
        _selectedTodos.pending.length + _selectedTodos.completed.length;

    if (count == 0) return 'None Selected';
    if (count == 1) return '1 Item Selected';
    return '$count Items Selected';
  }

  void _sortControl(String newSortRule) {
    _sortNewestFirst = newSortRule == 'latest';

    _pendingSubscription.cancel();
    _doneSubscription.cancel();

    _pendingTodosQuery = _buildQuery(state: false);
    _doneTodosQuery = _buildQuery(state: true);

    _startWatching();
  }

  void _toggleDone(bool state, String id, bool isDone) async {
    if (!isDone) {
      if (await NotificationService().notificationExists(int.parse(id))) {
        await NotificationService().plugin.cancel(id: int.parse(id));
      }
    }

    await db.writeTxn(() async {
      final todo = await collection.get(int.parse(id));

      if (todo!.time != null) {
        if (isDone && todo.time!.isAfter(DateTime.now())) {
          final perm = await NotificationService()
              .verifyNotificationPermission();
          if (perm && await NotificationService().notificationExists(todo.id)) {
            await NotificationService().plugin.cancel(id: todo.id);
          }

          if (perm && todo.time != null && todo.time!.isAfter(DateTime.now())) {
            await NotificationService().scheduleTodoAlarm(
              id: todo.id,
              title: todo.title!,
              time: todo.time!,
            );
          }
        }
      }

      todo.completed = !isDone;
      todo.updatedAt = DateTime.now();

      await collection.put(todo);
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

  void _checkToggle(bool checked, String id, bool isDone) {
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
    setState(() {});
  }

  void _clearSelection() {
    setState(() {
      checkState = false;
      _selectedTodos.completed.clear();
      _selectedTodos.pending.clear();
    });
    deleteEventBus.emitChecked(false);
  }

  void _showTodoDialog({String? text, DateTime? date, int? id, bool? isDone}) {
    closeSwipeableEventBus.emit();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          AddTodoSheet(title: text, date: date, id: id, isDone: isDone),
    );
  }

  late StreamSubscription<bool> _subscription;
  late StreamSubscription<List<TodoData>> _pendingSubscription;
  late StreamSubscription<List<TodoData>> _doneSubscription;

  void _startWatching() {
    _pendingSubscription = _pendingTodosQuery
        .watch(fireImmediately: true)
        .listen((todos) {
          setState(() {
            _pendingTodos = todos.map((todo) {
              return TodoItemData(
                id: todo.id.toString(),
                title: todo.title ??= '',
                time: todo.time,
                completed: todo.completed,
              );
            }).toList();
          });
        });

    _doneSubscription = _doneTodosQuery.watch(fireImmediately: true).listen((
      todos,
    ) {
      setState(() {
        _doneTodos = todos.map((todo) {
          return TodoItemData(
            id: todo.id.toString(),
            title: todo.title ??= '',
            time: todo.time,
            completed: todo.completed,
          );
        }).toList();
      });
    });
  }

  GoRouterDelegate? _routerDelegate;
  bool _isScreenVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routerDelegate?.removeListener(_onRouteChanged);
    _routerDelegate = GoRouter.of(context).routerDelegate
      ..addListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    if (!mounted) return;

    final bool currentlyOnTodos =
        GoRouterState.of(context).uri.path == '/todos';

    if (_isScreenVisible != currentlyOnTodos) {
      setState(() {
        _isScreenVisible = currentlyOnTodos;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _startWatching();

    _subscription = deleteEventBus.deleteTodoClickedStream.listen((
      clicked,
    ) async {
      if (!clicked || !mounted) return;

      final navigator = Navigator.of(context);

      final confirmed = await showDeleteDialog(
        navigator.context,
        (_selectedTodos.completed.length + _selectedTodos.pending.length),
        "Todo",
      );

      deleteEventBus.emitDeleteTodoClicked(false);

      if (confirmed == true) {
        final combined = [
          ..._selectedTodos.completed,
          ..._selectedTodos.pending,
        ];
        await db.writeTxn(() async {
          await collection.deleteAll(combined.map(int.parse).toList());
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
    _pendingSubscription.cancel();
    _doneSubscription.cancel();
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
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.medium(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            expandedHeight: showSearch ? 180 : null,
            collapsedHeight: showSearch ? 140 : null,
            foregroundColor: Colors.white,
            backgroundColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.scrolledUnder)) {
                return theme.colorScheme.primaryContainer;
              }
              return Colors.transparent;
            }),
            actions: checkState
                ? [
                    IconButton(
                      onPressed: _clearSelection,
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.tertiary,
                      ),
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
                : [TodoSortMenu(onSortChanged: _sortControl)],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appBarTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (showSearch) ...[
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
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
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
                                spacing: 3,
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
                                          : theme.colorScheme.tertiary,
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
                ],
              ),
            ),
          ),

          if (isPendingEmpty && isDoneEmpty)
            SliverFillRemaining(
              hasScrollBody: true,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 80,
                      color: theme.colorScheme.onSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'None',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.colorScheme.onSecondary,
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
                      toggleDone: _toggleDone,
                      longPress: _longPressDetected,
                      onCheckedChanged: _checkToggle,
                      onEdit: () => _showTodoDialog(
                        text: todo.title,
                        date: todo.time,
                        id: int.parse(todo.id),
                        isDone: todo.completed,
                      ),
                      isChecked: _selectedTodos.pending.contains(todo.id),
                      isScreenVisible: _isScreenVisible,
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
                        toggleDone: _toggleDone,
                        longPress: _longPressDetected,
                        onCheckedChanged: _checkToggle,
                        onEdit: () => _showTodoDialog(
                          text: todo.title,
                          date: todo.time,
                          id: int.parse(todo.id),
                          isDone: todo.completed,
                        ),
                        isChecked: _selectedTodos.completed.contains(todo.id),
                        isScreenVisible: _isScreenVisible,
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
              backgroundColor: theme.colorScheme.secondaryContainer,
              elevation: 5,
              foregroundColor: Colors.amber,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
