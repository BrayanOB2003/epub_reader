import 'package:drift/native.dart';
import 'package:epub_reader/app/app.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/onboarding/onboarding_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding stays in front until the answers are saved', () {
    expect(onboardingRedirect(completed: null, location: '/library'), '/boot');
    expect(onboardingRedirect(completed: null, location: '/boot'), isNull);
    expect(
      onboardingRedirect(completed: false, location: '/library'),
      '/onboarding',
    );
    expect(
      onboardingRedirect(completed: false, location: '/onboarding'),
      isNull,
    );
    expect(
      onboardingRedirect(completed: true, location: '/onboarding'),
      '/library',
    );
    expect(onboardingRedirect(completed: true, location: '/library'), isNull);
  });

  test(
    'answers remember several motivations, one goal and one routine',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      const answers = OnboardingAnswers(
        motivations: {ReadingMotivation.readMore, ReadingMotivation.habit},
        dailyGoalMinutes: 10,
        routine: ReadingRoutine.night,
      );

      expect(answers.isComplete, isTrue);
      expect(answers.motivationsStorage, 'habit,read_more');
      expect(const OnboardingAnswers().isComplete, isFalse);

      final store = OnboardingStore(database);
      expect(await store.isComplete(), isFalse);
      await store.save(answers);
      expect(await store.isComplete(), isTrue);

      final saved = await database.select(database.readerProfiles).getSingle();
      expect(saved.motivations, 'habit,read_more');
      expect(saved.dailyGoalMinutes, 10);
      expect(saved.routine, 'night');
    },
  );

  testWidgets(
    'the first launch asks three questions and then opens the library',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
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

      expect(find.text('Crea el hábito de leer'), findsOneWidget);
      expect(
        find.text(
          'Sin cuenta. Tus libros y tu progreso se guardan en este dispositivo.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Empezar'));
      await tester.pumpAndSettle();
      expect(find.text('1 de 3'), findsOneWidget);

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('1 de 3'), findsOneWidget);

      await tester.tap(find.text('Leer más'));
      await tester.pump();
      await tester.tap(find.text('Tener un momento para mí'));
      await tester.pump();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('2 de 3'), findsOneWidget);
      await tester.tap(find.text('10 minutos'));
      await tester.pump();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('3 de 3'), findsOneWidget);
      expect(
        find.text('Más adelante podrás elegir los días y una hora.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Noche'));
      await tester.pump();
      await tester.tap(find.text('Quiero empezar a leer'));
      await tester.pumpAndSettle();

      expect(find.text('Todavía no hay libros'), findsOneWidget);
      expect(find.text('Importar'), findsOneWidget);
      expect(await OnboardingStore(database).isComplete(), isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    },
  );
}
