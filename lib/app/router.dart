import 'package:epub_reader/app/app_shell.dart';
import 'package:epub_reader/features/discover/discover_page.dart';
import 'package:epub_reader/features/library/home_page.dart';
import 'package:epub_reader/features/reader/reader_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/library',
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/library'),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/discover', builder: (context, state) => const DiscoverPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/library', builder: (context, state) => const HomePage())],
        ),
      ],
    ),
    GoRoute(
      path: '/read/:bookId',
      builder: (context, state) {
        final bookId = int.tryParse(state.pathParameters['bookId'] ?? '');
        if (bookId == null) {
          return const Scaffold(body: Center(child: Text('Libro no válido.')));
        }
        return ReaderPage(bookId: bookId);
      },
    ),
  ],
);
