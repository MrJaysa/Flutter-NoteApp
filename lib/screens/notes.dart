import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:test_app/components/note_tile.dart';
import 'package:test_app/events/delete_event.dart';
import 'package:test_app/modals/delete_modal.dart';
import 'package:test_app/models/model.dart';
import 'package:test_app/models/note_db.dart';

class NoteItemData {
  final String id;
  final String? title;
  final List<dynamic> content;
  final DateTime time;

  const NoteItemData({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
  });
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<NoteItemData> _notes = [];
  final List<String> _selectedNotes = [];
  final collection = db.collection<NoteData>();

  late Query<NoteData> query = collection.where().sortByUpdatedAtDesc().build();

  bool checkState = false;

  void _longPressDetected(String id) {
    setState(() {
      checkState = true;
      _selectedNotes.add(id);
    });
    deleteEventBus.emitChecked(true);
    deleteEventBus.emitDeletable(true);
  }

  void _clearSelection() {
    setState(() {
      checkState = false;
      _selectedNotes.clear();
    });
    deleteEventBus.emitChecked(false);
  }

  void _selectionToggle(bool selected) {
    setState(() {
      if (selected) {
        _selectedNotes
          ..clear()
          ..addAll(_notes.map((e) => e.id));
        deleteEventBus.emitDeletable(true);
      } else {
        _selectedNotes.clear();
        deleteEventBus.emitDeletable(false);
      }
    });
  }

  String get appBarTitle {
    if (!checkState) return 'Notes';

    final count = _selectedNotes.length;

    if (count == 0) return 'None Selected';
    if (count == 1) return '1 Item Selected';
    return '$count Items Selected';
  }

  late StreamSubscription<bool> _subscription;
  late final StreamSubscription<List<NoteData>> _notesSubscription;

  @override
  void initState() {
    super.initState();

    _notesSubscription = query.watch(fireImmediately: true).listen((notes) {
      if (!mounted) return;

      setState(() {
        _notes = notes.map((note) {
          return NoteItemData(
            id: note.id.toString(),
            title: note.title,
            content: jsonDecode(note.contentDelta ?? ''),
            time: note.updatedAt,
          );
        }).toList();
      });
    });

    _subscription = deleteEventBus.deleteNoteClickedStream.listen((
      clicked,
    ) async {
      if (!clicked || !mounted) return;

      final navigator = Navigator.of(context);

      final confirmed = await showDeleteDialog(
        navigator.context,
        _selectedNotes.length,
      );

      deleteEventBus.emitDeleteNoteClicked(false);

      if (confirmed == true) {
        setState(() {
          _notes.removeWhere((note) => _selectedNotes.contains(note.id));
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
    _notesSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = _notes.isEmpty;
    final bool showSearch = _notes.length > 6;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.amber),
    );
    return Scaffold(
      body: CustomScrollView(
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
                      tag: 'note',
                      child: Material(
                        type: MaterialType.transparency,
                        child: SizedBox(
                          height: 35,
                          child: InkWell(
                            onTap: checkState
                                ? null
                                : () => context.push(
                                    '/search',
                                    extra: {"type": "note"},
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
                            _selectedNotes.length == _notes.length &&
                            _notes.isNotEmpty,
                        onChanged: (value) => _selectionToggle(value ?? false),
                        activeColor: Colors.amber,
                        checkColor: Colors.white,
                      ),
                    ]
                  : [
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings),
                      ),
                    ],
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
                            _selectedNotes.length == _notes.length &&
                            _notes.isNotEmpty,
                        onChanged: (value) => _selectionToggle(value ?? false),
                        activeColor: Colors.amber,
                        checkColor: Colors.white,
                      ),
                    ]
                  : [
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings),
                      ),
                    ],
            ),

          if (isEmpty)
            SliverFillRemaining(
              hasScrollBody: true,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.description_outlined,
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
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 112),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final note = _notes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: NoteCard(
                      key: ValueKey(note.id),
                      id: note.id,
                      title: note.title ?? '',
                      content: note.content,
                      time: note.time,
                      longPress: () => _longPressDetected(note.id),
                      checkBoxVisible: checkState,
                      isChecked: _selectedNotes.contains(note.id),
                      onCheckedChanged: (bool checked) {
                        setState(() {
                          if (checked) {
                            _selectedNotes.add(note.id);
                          } else {
                            _selectedNotes.remove(note.id);
                          }
                        });

                        deleteEventBus.emitDeletable(_selectedNotes.isNotEmpty);
                      },
                    ),
                  );
                }, childCount: _notes.length),
              ),
            ),
        ],
      ),

      floatingActionButton: !checkState
          ? FloatingActionButton(
              onPressed: () => context.push('/add-note'),
              heroTag: 'notes_fab',
              backgroundColor: const Color(0xFF2B2A2A),
              foregroundColor: Colors.amber,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
