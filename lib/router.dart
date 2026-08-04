import 'package:notich/layouts/main_layout.dart';
import 'package:notich/screens/note_modification.dart';
import 'package:notich/screens/notes.dart';
import 'package:notich/screens/search.dart';
import 'package:notich/screens/settings.dart';
import 'package:notich/screens/todos.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/notes',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainTabLayout(navigationShell: navigationShell),

      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              builder: (context, state) => const NotesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/todos',
              builder: (context, state) => const TodosScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/add-note',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return AddNoteScreen(
          id: extra?['id'],
          title: extra?['title'],
          content: extra?['content'],
        );
      },
    ),

    GoRoute(
      path: '/search',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        final type = extra?['type'] ?? 'note';
        return SearchScreen(type: type);
      },
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
