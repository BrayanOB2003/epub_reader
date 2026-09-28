import 'package:drift/drift.dart' hide Column;
import 'package:drift/native.dart';
import 'package:epub_reader/app/app.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
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
            routineHour: const Value(21),
            routineDays: const Value('1,2,3,4,5,6,7'),
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
    expect(find.text('Lun'), findsNWidgets(2));
    expect(find.text('Dom'), findsNWidgets(2));
    expect(find.text(formatReadingMonth(DateTime.now())), findsOneWidget);
    expect(find.text('Meta · 10 min'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Todavía no hay registros'), 200);
    expect(find.text('Todavía no hay registros'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Esta semana'), -200);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Hábito de lectura'), findsOneWidget);
    expect(find.text('Generar lecturas de ejemplo'), findsOneWidget);
    expect(find.text('Resetear onboarding'), findsNothing);

    await tester.tap(find.text('Hábito de lectura'));
    await tester.pumpAndSettle();
    expect(find.text('Crea el hábito de leer'), findsNothing);
    expect(find.text('¿Qué quieres conseguir con la lectura?'), findsOneWidget);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('2 de 3'), findsOneWidget);
    await tester.tap(find.text('30 minutos'));
    await tester.pump();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Noche'), findsOneWidget);
    expect(find.text('21:00'), findsOneWidget);
    await tester.tap(find.text('Quiero empezar a leer'));
    await tester.pumpAndSettle();
    expect(find.text('Hábito de lectura'), findsOneWidget);
    final saved = await database.select(database.readerProfiles).getSingle();
    expect(saved.dailyGoalMinutes, 30);
    expect(saved.motivations, 'habit');
    expect(saved.routine, 'night');
    expect(saved.routineHour, 21);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });

  test('cover initial skips marks and keeps a leading number', () {
    expect(coverInitial('¿Hábitos?'), 'H');
    expect(coverInitial('100 hábitos'), '1');
    expect(coverInitial('   '), '');
  });

  testWidgets('a missing cover shows the title initial', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: scheduleTheme(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              const ScheduleCoverPlaceholder(
                width: 72,
                height: 108,
                title: '¿Hábitos?',
                onAir: true,
              ),
              ScheduleListing(
                title: 'Frankenstein',
                subtitle: 'Mary Shelley',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('H'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
  });
}
