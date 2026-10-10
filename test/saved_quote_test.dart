import 'dart:io';

import 'package:drift/native.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/profile/quotes_page.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('a saved quote stays with its book and leaves with it', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = BookRepository(
      database,
      documentsDirectory: () async => Directory.systemTemp,
    );
    final bookId = await _book(database, 'Uno');
    final savedAt = DateTime.utc(2026, 10, 10, 3);

    final quoteId = await repository.saveQuote(
      bookId: bookId,
      text: 'Un pasaje',
      locatorJson: '{"href":"/c1.xhtml"}',
      savedAt: savedAt,
    );

    final quote = await repository.quoteById(quoteId);
    expect(quote?.bookId, bookId);
    expect(quote?.passage, 'Un pasaje');
    expect(quote?.locatorJson, '{"href":"/c1.xhtml"}');

    final listed = await repository.watchQuotes().first;
    expect(listed, hasLength(1));
    expect(listed.single.bookTitle, 'Uno');
    expect(listed.single.savedAt.toUtc(), savedAt);

    final book = await repository.getBook(bookId);
    await repository.delete(book!);
    expect(await database.select(database.savedQuotes).get(), isEmpty);
  });

  testWidgets('tapping a saved quote opens that passage', (tester) async {
    final router = GoRouter(
      initialLocation: '/quotes',
      routes: [
        GoRoute(path: '/quotes', builder: (_, _) => const QuotesPage()),
        GoRoute(
          path: '/read/:bookId',
          builder: (_, state) => Text(state.uri.toString()),
        ),
      ],
    );
    addTearDown(router.dispose);
    final quote = ReadingQuote(
      id: 3,
      bookId: 7,
      text: 'Un pasaje',
      locatorJson: '{"href":"/c1.xhtml"}',
      savedAt: DateTime.utc(2026, 10, 10),
      bookTitle: 'Uno',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedQuotesProvider.overrideWith((ref) => Stream.value([quote])),
        ],
        child: MaterialApp.router(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: scheduleTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Un pasaje'));
    await tester.pumpAndSettle();
    expect(find.textContaining('cita=3'), findsOneWidget);
    expect(find.textContaining('/read/7'), findsOneWidget);
  });
}

Future<int> _book(AppDatabase database, String title) {
  return database
      .into(database.books)
      .insert(
        BooksCompanion.insert(
          title: title,
          filePath: 'books/$title.epub',
          addedAt: DateTime.utc(2026, 10, 10),
        ),
      );
}
