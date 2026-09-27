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
    final database = AppDatabase(NativeDatabase.memory());
    await database
        .into(database.readerProfiles)
        .insert(
          ReaderProfilesCompanion.insert(
            motivations: 'habit',
            dailyGoalMinutes: 10,
            routine: 'night',
            completedAt: DateTime.utc(2026, 9, 26),
          ),
        );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
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

    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.text('Lun'), findsOneWidget);
    expect(find.text('Dom'), findsOneWidget);
    expect(find.text('Meta · 10 min'), findsOneWidget);
    expect(find.text('Todavía no hay registros'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Meta de lectura diaria'), findsOneWidget);
    expect(find.text('Generar lecturas de ejemplo'), findsOneWidget);
    expect(find.text('Resetear onboarding'), findsOneWidget);

    await tester.tap(find.text('Meta de lectura diaria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 minutos'));
    await tester.pumpAndSettle();
    final saved = await database.select(database.readerProfiles).getSingle();
    expect(saved.dailyGoalMinutes, 30);
    expect(saved.routine, 'night');

    await tester.tap(find.text('Resetear onboarding'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resetear'));
    await tester.pumpAndSettle();
    expect(find.text('Crea el hábito de leer'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
