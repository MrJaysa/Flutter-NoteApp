import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:notich/components/note_tile.dart';
import 'package:notich/enums/note_item.dart';
import 'package:notich/events/close_swipable_event.dart';
import 'package:notich/events/delete_event.dart';
import 'package:notich/modals/delete_modal.dart';
import 'package:notich/models/model.dart';
import 'package:notich/models/note_db.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<NoteItemData> _notes = [];
  final List<String> _selectedNotes = [];
  final collection = db.collection<NoteData>();

  late final Query<NoteData> _query = collection
      .where()
      .sortByUpdatedAtDesc()
      .build();

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

    _notesSubscription = _query.watch(fireImmediately: true).listen((notes) {
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
        "Note",
      );

      deleteEventBus.emitDeleteNoteClicked(false);

      if (confirmed == true) {
        await db.writeTxn(() async {
          await collection.deleteAll(_selectedNotes.map(int.parse).toList());
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
                          _selectedNotes.length == _notes.length &&
                          _notes.isNotEmpty,
                      onChanged: (value) => _selectionToggle(value ?? false),
                      activeColor: Colors.amber,
                      checkColor: Colors.white,
                    ),
                  ]
                : [
                    IconButton(
                      onPressed: () => {
                        closeSwipeableEventBus.emit(),
                        context.push('/settings'),
                      },
                      icon: Icon(
                        Icons.settings,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
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
                                    : theme.colorScheme.surfaceContainer,
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

          if (isEmpty)
            SliverFillRemaining(
              hasScrollBody: true,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
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
