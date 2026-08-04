import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:notich/components/add_todo_sheet.dart';
import 'package:notich/components/note_tile.dart';
import 'package:notich/components/todo_tile.dart';
import 'package:notich/events/close_swipable_event.dart';
import 'package:notich/helpers/notification.dart';
import 'package:notich/models/model.dart';
import 'package:notich/models/note_db.dart';
import 'package:notich/models/todo_db.dart';

class SearchScreen extends StatefulWidget {
  final String type;
  const SearchScreen({super.key, required this.type});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchBar = TextEditingController();
  List<Object> _items = [];
  bool _isEmpty = false;
  final _noteSearch = db.collection<NoteData>();
  final _todoSearch = db.collection<TodoData>();

  void _toggleDone(bool state, String id, bool isDone) async {
    if (!isDone) {
      if (await NotificationService().notificationExists(int.parse(id))) {
        await NotificationService().plugin.cancel(id: int.parse(id));
      }
    }

    await db.writeTxn(() async {
      final todo = await _todoSearch.get(int.parse(id));

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

      await _todoSearch.put(todo);
    });

    setState(() {
      final item = (_items as List<TodoData>).firstWhere(
        (e) => e.id == int.parse(id),
      );

      item.completed = !isDone;
    });
  }

  void _showTodoDialog({String? text, DateTime? date, int? id, bool? isDone}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          AddTodoSheet(title: text, date: date, id: id, isDone: isDone),
    ).then((_) {
      search(_searchBar.text.trim());
    });
  }

  Future<void> search(String query) async {
    if (widget.type == 'note') {
      _items = query.trim().isNotEmpty
          ? await _noteSearch
                .where()
                .contentWordsElementEqualTo(query.toLowerCase())
                .or()
                .contentWordsElementStartsWith(query.toLowerCase())
                .sortByUpdatedAtDesc()
                .findAll()
          : [];
    } else {
      _items = await _todoSearch
          .where()
          .titleWordsElementEqualTo(query.toLowerCase())
          .or()
          .titleWordsElementStartsWith(query.toLowerCase())
          .sortByUpdatedAtDesc()
          .findAll();
    }

    if (_items.isNotEmpty) {
      setState(() {
        _isEmpty = false;
      });
    }

    if (_items.isNotEmpty && _searchBar.text.isEmpty) {
      setState(() {
        _isEmpty = false;
        _items = [];
      });
    }

    if (_items.isEmpty) {
      setState(() {
        _isEmpty = true;
      });
    }
  }

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    closeSwipeableEventBus.emit();

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        toolbarHeight: 68,

        title: Hero(
          tag: widget.type,
          child: Material(
            type: MaterialType.transparency,
            child: SearchBar(
              controller: _searchBar,
              backgroundColor: WidgetStateProperty.all(
                theme.brightness == Brightness.light
                    ? const Color.fromARGB(255, 238, 238, 238)
                    : null,
              ),
              onChanged: search,
              focusNode: _focusNode,
              autoFocus: false,
              hintText: 'Search',
              elevation: WidgetStateProperty.all(1),
              hintStyle: WidgetStateProperty.all(
                TextStyle(
                  color: const Color.fromARGB(201, 128, 128, 128),
                  fontWeight: FontWeight.w400,
                ),
              ),
              leading: const Icon(
                Icons.search,
                color: Color.fromARGB(255, 106, 104, 104),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 50),
              trailing: _searchBar.text.isEmpty
                  ? null
                  : [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.tertiary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchBar.clear();
                          search('');
                          setState(() {});
                        },
                      ),
                    ],
            ),
          ),
        ),
      ),
      body: _searchBar.text.isNotEmpty && _isEmpty && _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.find_in_page, size: 80, color: Colors.white30),
                  SizedBox(height: 12),
                  Text(
                    'No Search Results',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                if (widget.type == 'note') {
                  final item = _items[index] as NoteData;

                  return NoteCard(
                    key: ValueKey(item.id),
                    id: item.id.toString(),
                    title: item.title ?? '',
                    content: jsonDecode(item.contentDelta ?? ''),
                    time: item.updatedAt,
                    longPress: () => {},
                    checkBoxVisible: false,
                    isChecked: false,
                    onCheckedChanged: () {},
                    reload: () => search(_searchBar.text.trim()),
                  );
                } else {
                  final item = _items[index] as TodoData;

                  return TodoItemTile(
                    key: ValueKey(item.id.toString()),
                    id: item.id.toString(),
                    title: item.title!,
                    time: item.time,
                    isDone: item.completed,
                    checkBoxVisible: false,
                    toggleDone: _toggleDone,
                    longPress: null,
                    onCheckedChanged: () => {},
                    onEdit: () => _showTodoDialog(
                      text: item.title,
                      date: item.time,
                      id: item.id,
                      isDone: item.completed,
                    ),
                    isChecked: false,
                    isScreenVisible: false,
                    reload: () => search(_searchBar.text.trim()),
                  );
                }
              },
            ),
    );
  }
}
