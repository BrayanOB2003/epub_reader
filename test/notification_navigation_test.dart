import 'package:drift/native.dart';
import 'package:epub_reader/app/app.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/router.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/notifications/local_notifications.dart';
import 'package:epub_reader/features/notifications/notification_destination.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a notification only opens an in-app screen', () {
    expect(notificationLocation('/library'), '/library');
    expect(notificationLocation('/discover'), '/discover');
    expect(notificationLocation('/time'), '/time');
    expect(notificationLocation('/profile'), '/profile');
    expect(notificationLocation('/read/12'), '/read/12');
    expect(notificationLocation('/read/01'), '/read/1');

    expect(notificationLocation(null), isNull);
    expect(notificationLocation(''), isNull);
    expect(notificationLocation('/onboarding'), isNull);
    expect(notificationLocation('/boot'), isNull);
    expect(notificationLocation('/read/0'), isNull);
    expect(notificationLocation('/read/no'), isNull);
    expect(notificationLocation('/library?x=1'), isNull);
    expect(notificationLocation('https://example.com/library'), isNull);
    expect(notificationLocation('//example.com/library'), isNull);
  });

  test('a tap waits until onboarding is finished', () {
    expect(
      resolveNotificationTap(
        onboardingCompleted: null,
        pendingLocation: '/read/4',
        currentPath: '/boot',
      ).waiting,
      isTrue,
    );
    expect(
      resolveNotificationTap(
        onboardingCompleted: false,
        pendingLocation: '/profile',
        currentPath: '/onboarding',
      ).waiting,
      isTrue,
    );
    expect(
      resolveNotificationTap(
        onboardingCompleted: true,
        pendingLocation: '/read/4',
        currentPath: '/library',
      ).location,
      '/read/4',
    );
    expect(
      resolveNotificationTap(
        onboardingCompleted: true,
        pendingLocation: '/library',
        currentPath: '/library',
      ).opens,
      isFalse,
    );
    expect(
      resolveNotificationTap(
        onboardingCompleted: true,
        pendingLocation: null,
        currentPath: '/library',
      ).opens,
      isFalse,
    );
    expect(
      notificationLanding(editing: false, pendingLocation: '/read/4'),
      '/read/4',
    );
    expect(
      notificationLanding(editing: false, pendingLocation: null),
      '/library',
    );
    expect(
      notificationLanding(editing: true, pendingLocation: null),
      '/profile',
    );
  });

  testWidgets('a tap opens its screen once onboarding is done', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
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
    );
    addTearDown(container.dispose);
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EpubReaderApp(),
      ),
    );
    await tester.pumpAndSettle();

    container
        .read(pendingNotificationLocationProvider.notifier)
        .open('/read/4');
    await tester.pump();
    expect(find.text('Crea el hábito de leer'), findsOneWidget);
    expect(container.read(appRouterProvider).state.uri.path, '/onboarding');

    await container
        .read(onboardingControllerProvider.notifier)
        .complete(
          const OnboardingAnswers(
            motivations: {ReadingMotivation.habit},
            dailyGoalMinutes: 10,
            routine: ReadingRoutine.night,
            routineHour: 21,
          ),
        );
    await tester.pumpAndSettle();

    expect(container.read(appRouterProvider).state.uri.path, '/read/4');
    expect(
      find.text('Este libro ya no está en la biblioteca.'),
      findsOneWidget,
    );
  });

  testWidgets('a tap opens its screen from the library', (tester) async {
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
    final container = ProviderContainer(
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
    );
    addTearDown(container.dispose);
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EpubReaderApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(container.read(appRouterProvider).state.uri.path, '/library');

    container.read(pendingNotificationLocationProvider.notifier).open('/time');
    await tester.pumpAndSettle();

    expect(container.read(appRouterProvider).state.uri.path, '/time');
  });
}
