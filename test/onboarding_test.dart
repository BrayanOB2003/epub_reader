import 'package:drift/native.dart';
import 'package:epub_reader/app/app.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
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
    expect(
      onboardingRedirect(
        completed: true,
        location: '/onboarding',
        editing: true,
      ),
      isNull,
    );
    expect(onboardingRedirect(completed: true, location: '/library'), isNull);
    expect(
      onboardingRedirect(
        completed: true,
        location: '/library',
        notificationsPrompted: false,
      ),
      '/notifications',
    );
    expect(
      onboardingRedirect(
        completed: true,
        location: '/notifications',
        notificationsPrompted: false,
      ),
      isNull,
    );
    expect(
      onboardingRedirect(completed: true, location: '/notifications'),
      '/library',
    );
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
        routineHour: 21,
      );

      expect(answers.isComplete, isTrue);
      expect(
        const OnboardingAnswers(
          motivations: {ReadingMotivation.readMore},
          dailyGoalMinutes: 10,
          routine: ReadingRoutine.night,
          routineHour: 7,
        ).isComplete,
        isFalse,
      );
      expect(answers.withRoutine(ReadingRoutine.morning).routineHour, isNull);
      expect(answers.weekdays, defaultReadingWeekdays);
      expect(answers.weekdaysStorage, '1,2,3,4,5,6,7');
      final restored = OnboardingAnswers.fromStored(
        motivations: answers.motivationsStorage,
        dailyGoalMinutes: 10,
        routine: 'night',
        routineHour: 21,
        routineDays: '1,2,3,4,5,6,7',
      );
      expect(restored.isComplete, isTrue);
      expect(restored.motivations, answers.motivations);
      expect(restored.routine, ReadingRoutine.night);
      expect(answers.copyWith(weekdays: const {}).isComplete, isFalse);
      expect(answers.motivationsStorage, 'habit,read_more');
      expect(const OnboardingAnswers().isComplete, isFalse);

      final store = ReaderProfileStore(database);
      expect(await store.exists(), isFalse);
      await store.save(
        motivations: answers.motivationsStorage,
        dailyGoalMinutes: answers.dailyGoalMinutes!,
        routine: answers.routine!.id,
        routineHour: answers.routineHour!,
        routineDays: answers.weekdaysStorage,
      );
      expect(await store.exists(), isTrue);

      final saved = await database.select(database.readerProfiles).getSingle();
      expect(saved.motivations, 'habit,read_more');
      expect(saved.dailyGoalMinutes, 10);
      expect(saved.routine, 'night');
      expect(saved.routineHour, 21);
      expect(saved.routineDays, '1,2,3,4,5,6,7');
      expect(saved.notificationsPrompted, isFalse);

      await store.markNotificationsPrompted();
      final prompted = await database
          .select(database.readerProfiles)
          .getSingle();
      expect(prompted.notificationsPrompted, isTrue);

      await store.save(
        motivations: answers.motivationsStorage,
        dailyGoalMinutes: answers.dailyGoalMinutes!,
        routine: answers.routine!.id,
        routineHour: answers.routineHour!,
        routineDays: answers.weekdaysStorage,
      );
      final kept = await database.select(database.readerProfiles).getSingle();
      expect(kept.notificationsPrompted, isTrue);

      await store.clear();
      expect(await store.exists(), isFalse);

      await store.save(
        motivations: answers.motivationsStorage,
        dailyGoalMinutes: 20,
        routine: answers.routine!.id,
        routineHour: answers.routineHour!,
        routineDays: answers.weekdaysStorage,
      );
      final updated = await database
          .select(database.readerProfiles)
          .getSingle();
      expect(updated.dailyGoalMinutes, 20);
      expect(updated.motivations, 'habit,read_more');
      expect(updated.routine, 'night');
      expect(updated.routineHour, 21);
      expect(updated.notificationsPrompted, isFalse);
    },
  );

  testWidgets(
    'the first launch asks three questions and then opens the library',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      tester.platformDispatcher.localesTestValue = const [Locale('es')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
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
      expect(find.text('¿Qué días?'), findsNothing);
      await tester.tap(find.text('Noche'));
      await tester.pump();
      expect(find.text('¿Qué días?'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.text('07:00'), findsNothing);
      expect(find.text('21:00'), findsOneWidget);
      await tester.tap(find.text('Quiero empezar a leer'));
      await tester.pumpAndSettle();
      expect(find.text('3 de 3'), findsOneWidget);

      await tester.tap(find.text('21:00'));
      await tester.pump();
      await tester.tap(find.text('Quiero empezar a leer'));
      await tester.pumpAndSettle();

      expect(find.text('Te aviso a tu hora'), findsOneWidget);
      expect(
        find.text(
          'Cuando llega el momento que elegiste, Liora puede recordarte que leas.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Ahora no'));
      await tester.pumpAndSettle();

      expect(find.text('Todavía no hay libros'), findsOneWidget);
      expect(find.text('Importar'), findsOneWidget);
      final saved = await database.select(database.readerProfiles).getSingle();
      expect(saved.routineDays, '1,2,3,4,5,6,7');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    },
  );
}
