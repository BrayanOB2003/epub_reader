import 'dart:io';

import 'package:drift/native.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/profile/profile_page.dart';
import 'package:epub_reader/features/profile/quote_groups.dart';
import 'package:epub_reader/features/profile/quotes_page.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
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

    final saved = await repository.saveQuote(
      bookId: bookId,
      text: 'Un pasaje',
      locatorJson: '{"href":"/c1.xhtml"}',
      savedAt: savedAt,
    );
    expect(saved.created, isTrue);

    final quote = await repository.quoteById(saved.id);
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

  test('saving the same passage again keeps the first quote', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = BookRepository(
      database,
      documentsDirectory: () async => Directory.systemTemp,
    );
    final bookId = await _book(database, 'Uno');
    final otherId = await _book(database, 'Dos');

    final first = await repository.saveQuote(
      bookId: bookId,
      text: 'Un pasaje',
      locatorJson: '{"href":"/c1.xhtml"}',
      savedAt: DateTime.utc(2026, 10, 10),
    );
    final again = await repository.saveQuote(
      bookId: bookId,
      text: 'Un pasaje',
      locatorJson: '{"href":"/other.xhtml"}',
      savedAt: DateTime.utc(2026, 10, 11),
    );
    final otherBook = await repository.saveQuote(
      bookId: otherId,
      text: 'Un pasaje',
      locatorJson: '{"href":"/c1.xhtml"}',
      savedAt: DateTime.utc(2026, 10, 12),
    );

    expect(again.created, isFalse);
    expect(again.id, first.id);
    expect(otherBook.created, isTrue);
    final listed = await repository.watchQuotes().first;
    expect(listed, hasLength(2));
    expect(
      listed.singleWhere((quote) => quote.bookId == bookId).locatorJson,
      '{"href":"/c1.xhtml"}',
    );
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

  test('the newest quote leads and older ones stay grouped by book', () {
    final older = _reading(
      id: 1,
      bookId: 1,
      text: 'Vieja',
      savedAt: DateTime.utc(2026, 10, 1),
      bookTitle: 'Uno',
      author: 'Autora',
    );
    final middle = _reading(
      id: 3,
      bookId: 1,
      text: 'Media',
      savedAt: DateTime.utc(2026, 10, 3),
      bookTitle: 'Uno',
      author: 'Autora',
    );
    final newer = _reading(
      id: 2,
      bookId: 2,
      text: 'Nueva',
      savedAt: DateTime.utc(2026, 10, 8),
      bookTitle: 'Dos',
    );

    final groups = arrangeQuotes([older, newer, middle]);

    expect(groups, hasLength(2));
    expect(groups.first.bookTitle, 'Dos');
    expect(groups.first.quotes.single.text, 'Nueva');
    expect(groups.last.bookTitle, 'Uno');
    expect(groups.last.quotes.map((quote) => quote.text), ['Media', 'Vieja']);
    expect(quoteShareBody(older), 'Vieja\n\nUno\nAutora');
  });

  testWidgets('every quote shows its day under its book', (tester) async {
    final older = _reading(
      id: 1,
      bookId: 1,
      text: 'Vieja',
      savedAt: DateTime.utc(2026, 10, 1, 15),
      bookTitle: 'Uno',
      author: 'Autora',
    );
    final newer = _reading(
      id: 2,
      bookId: 2,
      text: 'Nueva',
      savedAt: DateTime.utc(2026, 10, 8, 21, 5),
      bookTitle: 'Dos',
      author: 'Otro',
    );
    await _pumpQuotes(tester, [newer, older]);

    expect(find.text('Nueva'), findsOneWidget);
    expect(find.text('Dos'), findsOneWidget);
    expect(find.text('Otro'), findsOneWidget);
    expect(find.text(scheduleDay(newer.savedAt, 'es')), findsOneWidget);
    expect(find.text('Vieja'), findsOneWidget);
    expect(find.text('Uno'), findsOneWidget);
    expect(find.text('Autora'), findsOneWidget);
    expect(find.text(scheduleDay(older.savedAt, 'es')), findsOneWidget);
    expect(find.byTooltip('Compartir texto'), findsNWidgets(2));
    expect(find.byTooltip('Crear imagen'), findsNWidgets(2));
    expect(find.byTooltip('Eliminar cita'), findsNWidgets(2));
  });

  testWidgets('confirming delete removes the quote', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = BookRepository(
      database,
      documentsDirectory: () async => Directory.systemTemp,
    );
    final bookId = await _book(database, 'Uno');
    await repository.saveQuote(
      bookId: bookId,
      text: 'Un pasaje',
      locatorJson: '{"href":"/c1.xhtml"}',
      savedAt: DateTime.utc(2026, 10, 10),
    );
    final router = GoRouter(
      initialLocation: '/quotes',
      routes: [GoRoute(path: '/quotes', builder: (_, _) => const QuotesPage())],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(database.close);
            return database;
          }),
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

    await tester.tap(find.byTooltip('Eliminar cita'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Un pasaje'), findsNothing);
    expect(find.text('Todavía no hay citas'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });

  testWidgets('an empty quotes page points at the library', (tester) async {
    await _pumpQuotes(tester, const []);

    expect(
      find.text('Selecciona un pasaje y pulsa Guardar cita.'),
      findsOneWidget,
    );
    expect(find.text('Biblioteca'), findsOneWidget);
  });

  testWidgets('profile shows how many quotes are saved', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readerProfileProvider.overrideWith((ref) => Stream.value(null)),
          savedQuotesProvider.overrideWith(
            (ref) => Stream.value([
              _reading(
                id: 1,
                bookId: 1,
                text: 'Una',
                savedAt: DateTime.utc(2026, 10, 1),
              ),
              _reading(
                id: 2,
                bookId: 1,
                text: 'Otra',
                savedAt: DateTime.utc(2026, 10, 2),
              ),
            ]),
          ),
          quoteHighlightDefaultProvider.overrideWith((ref) => 'amber'),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: scheduleTheme(Brightness.light),
          home: const ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Citas'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}

ReadingQuote _reading({
  required int id,
  required int bookId,
  required String text,
  required DateTime savedAt,
  String bookTitle = 'Uno',
  String? author,
}) {
  return ReadingQuote(
    id: id,
    bookId: bookId,
    text: text,
    locatorJson: '{"href":"/c1.xhtml"}',
    savedAt: savedAt,
    bookTitle: bookTitle,
    author: author,
  );
}

Future<void> _pumpQuotes(WidgetTester tester, List<ReadingQuote> quotes) async {
  final router = GoRouter(
    initialLocation: '/quotes',
    routes: [
      GoRoute(path: '/quotes', builder: (_, _) => const QuotesPage()),
      GoRoute(path: '/library', builder: (_, _) => const Text('biblioteca')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        savedQuotesProvider.overrideWith((ref) => Stream.value(quotes)),
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
