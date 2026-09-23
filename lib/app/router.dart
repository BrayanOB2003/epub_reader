import 'package:epub_reader/features/library/home_page.dart';
import 'package:epub_reader/features/reader/reader_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
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
