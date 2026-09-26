import 'package:drift/native.dart';
import 'package:epub_reader/app/app.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/library/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shows an empty library', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            final database = AppDatabase(NativeDatabase.memory());
            ref.onDispose(database.close);
            return database;
          }),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Todavía no hay libros'), findsOneWidget);
    expect(find.text('Importar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });

  testWidgets('navbar switches between discovery and library', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            final database = AppDatabase(NativeDatabase.memory());
            ref.onDispose(database.close);
            return database;
          }),
          catalogProvider.overrideWithBuild((ref, notifier) {
            return const Catalog(
              generatedAt: null,
              urlsExpireAt: null,
              books: [],
            );
          }),
        ],
        child: const EpubReaderApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca'), findsWidgets);
    expect(find.text('Descubrimiento'), findsOneWidget);
    expect(find.text('Todavía no hay libros'), findsOneWidget);

    await tester.tap(find.text('Descubrimiento'));
    await tester.pumpAndSettle();

    expect(find.text('El catálogo está vacío'), findsOneWidget);

    await tester.tap(find.text('Tiempo'));
    await tester.pumpAndSettle();

    expect(find.text('Todavía no hay registros'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
