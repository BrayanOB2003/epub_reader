import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AppAnalytics {
  Future<void> logTutorialBegin();

  Future<void> logTutorialComplete({
    required int goalMinutes,
    required String routine,
    required int weekdayCount,
    required String motivations,
  });

  Future<void> logNotificationPermission(String result);

  Future<void> logBookAdded({
    required String source,
    required String result,
    String? catalogBookId,
  });

  Future<void> logReadingSession({
    required int engagedSeconds,
    required bool advanced,
    required String source,
  });

  Future<void> logDailyGoalReached();

  Future<void> logFocusModeSet({required bool enabled});

  Future<void> logNotificationOpen(String destination);

  /// A failure that was not a normal product result. The reason is a short
  /// code, never a file path or the text of a book.
  Future<void> recordUnexpected(String reason, StackTrace stack);
}

final class NoopAppAnalytics implements AppAnalytics {
  const NoopAppAnalytics();

  @override
  Future<void> logTutorialBegin() async {}

  @override
  Future<void> logTutorialComplete({
    required int goalMinutes,
    required String routine,
    required int weekdayCount,
    required String motivations,
  }) async {}

  @override
  Future<void> logNotificationPermission(String result) async {}

  @override
  Future<void> logBookAdded({
    required String source,
    required String result,
    String? catalogBookId,
  }) async {}

  @override
  Future<void> logReadingSession({
    required int engagedSeconds,
    required bool advanced,
    required String source,
  }) async {}

  @override
  Future<void> logDailyGoalReached() async {}

  @override
  Future<void> logFocusModeSet({required bool enabled}) async {}

  @override
  Future<void> logNotificationOpen(String destination) async {}

  @override
  Future<void> recordUnexpected(String reason, StackTrace stack) async {}
}

bool get firebaseReady {
  try {
    return Firebase.apps.isNotEmpty;
  } catch (_) {
    return false;
  }
}

final appAnalyticsProvider = Provider<AppAnalytics>((ref) {
  if (!firebaseReady) return const NoopAppAnalytics();
  return FirebaseAppAnalytics(
    analytics: FirebaseAnalytics.instance,
    crashlytics: FirebaseCrashlytics.instance,
  );
});

final class FirebaseAppAnalytics implements AppAnalytics {
  FirebaseAppAnalytics({required this.analytics, required this.crashlytics});

  final FirebaseAnalytics analytics;
  final FirebaseCrashlytics crashlytics;

  @override
  Future<void> logTutorialBegin() {
    return _log(tutorialBeginEvent);
  }

  @override
  Future<void> logTutorialComplete({
    required int goalMinutes,
    required String routine,
    required int weekdayCount,
    required String motivations,
  }) {
    return _log(tutorialCompleteEvent, {
      'goal_minutes': goalMinutes,
      'routine': routine,
      'weekday_count': weekdayCount,
      'motivations': motivations,
    });
  }

  @override
  Future<void> logNotificationPermission(String result) {
    return _log(notificationPermissionEvent, {'result': result});
  }

  @override
  Future<void> logBookAdded({
    required String source,
    required String result,
    String? catalogBookId,
  }) {
    final parameters = <String, Object>{'source': source, 'result': result};
    final id = _catalogBookId(source, catalogBookId);
    if (id != null) parameters['catalog_book_id'] = id;
    return _log(bookAddedEvent, parameters);
  }

  @override
  Future<void> logReadingSession({
    required int engagedSeconds,
    required bool advanced,
    required String source,
  }) {
    return _log(readingSessionEvent, {
      'engaged_seconds': engagedSeconds,
      'advanced': advanced ? 'true' : 'false',
      'source': readingSessionSource(source),
    });
  }

  @override
  Future<void> logDailyGoalReached() {
    return _log(dailyGoalReachedEvent);
  }

  @override
  Future<void> logFocusModeSet({required bool enabled}) {
    return _log(focusModeSetEvent, {'enabled': enabled ? 'true' : 'false'});
  }

  @override
  Future<void> logNotificationOpen(String destination) {
    return _log(notificationOpenEvent, {'destination': destination});
  }

  @override
  Future<void> recordUnexpected(String reason, StackTrace stack) async {
    try {
      await crashlytics.recordError(
        StateError(reason),
        stack,
        reason: reason,
        fatal: false,
      );
    } catch (_) {}
  }

  Future<void> _log(String name, [Map<String, Object>? parameters]) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (error, stack) {
      await recordUnexpected('analytics_log_failed', stack);
    }
  }
}

String? _catalogBookId(String source, String? id) {
  if (source != bookSourceCatalog || id == null) return null;
  final trimmed = id.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length <= 100) return trimmed;
  return trimmed.substring(0, 100);
}
