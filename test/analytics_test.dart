import 'package:drift/native.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/analytics/app_analytics.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('screen names drop the book id', () {
    expect(analyticsScreenName(const RouteSettings(name: 'read')), 'read');
    expect(analyticsScreenName(const RouteSettings(name: '/read/12')), 'read');
    expect(
      analyticsScreenName(const RouteSettings(name: '/library')),
      'library',
    );
    expect(analyticsScreenName(const RouteSettings(name: '')), isNull);
  });

  test('a notification reader route carries only the source', () {
    expect(
      routeOpenedFromNotification('/read/4'),
      '/read/4?origen=notification',
    );
    expect(routeOpenedFromNotification('/library'), '/library');
    expect(notificationOpenDestination('/read/4'), 'read');
    expect(notificationOpenDestination('/time'), 'time');
    expect(readingRoute(3, readingSourceCatalog), '/read/3?origen=catalog');
    expect(readingSessionSource('nope'), readingSourceLibrary);
  });

  test('the first saved habit logs tutorial_complete once', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final analytics = _RecordingAnalytics();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWith((ref) => database),
        appAnalyticsProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    const answers = OnboardingAnswers(
      motivations: {ReadingMotivation.readMore, ReadingMotivation.habit},
      dailyGoalMinutes: 10,
      routine: ReadingRoutine.night,
      routineHour: 21,
    );
    await container.read(onboardingControllerProvider.future);
    final controller = container.read(onboardingControllerProvider.notifier);
    await controller.complete(answers);
    await controller.complete(answers);

    expect(analytics.names, [tutorialCompleteEvent]);
    expect(analytics.parameters.single['goal_minutes'], 10);
    expect(analytics.parameters.single['routine'], 'night');
    expect(analytics.parameters.single['weekday_count'], 7);
    expect(analytics.parameters.single['motivations'], 'habit,read_more');
  });
}

class _RecordingAnalytics implements AppAnalytics {
  final names = <String>[];
  final parameters = <Map<String, Object>>[];

  void _keep(String name, [Map<String, Object>? values]) {
    names.add(name);
    parameters.add(values ?? const {});
  }

  @override
  Future<void> logTutorialBegin() async => _keep(tutorialBeginEvent);

  @override
  Future<void> logTutorialComplete({
    required int goalMinutes,
    required String routine,
    required int weekdayCount,
    required String motivations,
  }) async {
    _keep(tutorialCompleteEvent, {
      'goal_minutes': goalMinutes,
      'routine': routine,
      'weekday_count': weekdayCount,
      'motivations': motivations,
    });
  }

  @override
  Future<void> logNotificationPermission(String result) async {
    _keep(notificationPermissionEvent, {'result': result});
  }

  @override
  Future<void> logBookAdded({
    required String source,
    required String result,
    String? catalogBookId,
  }) async {
    final values = <String, Object>{'source': source, 'result': result};
    if (catalogBookId != null) values['catalog_book_id'] = catalogBookId;
    _keep(bookAddedEvent, values);
  }

  @override
  Future<void> logReadingSession({
    required int engagedSeconds,
    required bool advanced,
    required String source,
  }) async {
    _keep(readingSessionEvent, {
      'engaged_seconds': engagedSeconds,
      'source': source,
    });
  }

  @override
  Future<void> logDailyGoalReached() async => _keep(dailyGoalReachedEvent);

  @override
  Future<void> logFocusModeSet({required bool enabled}) async {
    _keep(focusModeSetEvent, {'enabled': enabled});
  }

  @override
  Future<void> logNotificationOpen(String destination) async {
    _keep(notificationOpenEvent, {'destination': destination});
  }

  @override
  Future<void> recordUnexpected(String reason, StackTrace stack) async {
    _keep(reason);
  }
}
