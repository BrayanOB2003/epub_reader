import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/notifications/local_notifications.dart';
import 'package:epub_reader/features/notifications/notification_prompt.dart';
import 'package:epub_reader/features/notifications/reading_notifications.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final readingNotificationSchedulerProvider =
    Provider<ReadingNotificationScheduler>((ref) {
      return ReadingNotificationScheduler(
        ref.watch(localNotificationsProvider),
      );
    });

class ReadingNotificationScheduler {
  ReadingNotificationScheduler(this._notifications);

  final LocalNotifications _notifications;
  int? _todaySeconds;
  String? _goalAnnouncedOn;
  Future<void> _tail = Future<void>.value();

  Future<void> apply({
    required AppLocalizations l10n,
    required ReaderProfile? profile,
    required List<Book> books,
    required List<ReadingSession> sessions,
    required bool? permissionGranted,
    DateTime? now,
  }) {
    final run = _tail.then(
      (_) => _apply(
        l10n: l10n,
        profile: profile,
        books: books,
        sessions: sessions,
        permissionGranted: permissionGranted,
        now: now,
      ),
    );
    _tail = run.catchError((_) {});
    return run;
  }

  Future<void> _apply({
    required AppLocalizations l10n,
    required ReaderProfile? profile,
    required List<Book> books,
    required List<ReadingSession> sessions,
    required bool? permissionGranted,
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final recorded = [
      for (final session in sessions)
        NotificationSession(
          bookId: session.bookId,
          startedAt: session.startedAt,
          endedAt: session.endedAt,
          engagedSeconds: session.engagedSeconds,
        ),
    ];
    final goal = profile?.dailyGoalMinutes;
    if (goal != null && permissionGranted == true) {
      await _announceGoal(
        l10n: l10n,
        goalMinutes: goal,
        sessions: recorded,
        now: moment,
      );
    }

    if (permissionGranted == null) return;
    for (var offset = 0; offset < readingNotificationHorizon; offset++) {
      await _notifications.cancel(readingScheduleIdStart + offset);
    }
    final hour = profile?.routineHour;
    if (permissionGranted != true || profile == null || hour == null) return;
    final plan = planReadingNotifications(
      now: moment,
      goalMinutes: profile.dailyGoalMinutes,
      hour: hour,
      weekdays: notificationWeekdays(profile.routineDays),
      sessions: recorded,
      books: [
        for (final book in books)
          NotificationBook(
            id: book.id,
            title: book.title,
            progress: book.progress,
            locatorJson: book.locatorJson,
          ),
      ],
    );
    for (final item in plan) {
      final when = item.at;
      if (when == null || !when.isAfter(DateTime.now())) continue;
      await _notifications.schedule(
        message: readingNotificationMessage(item, l10n),
        when: when,
      );
    }
  }

  Future<void> _announceGoal({
    required AppLocalizations l10n,
    required int goalMinutes,
    required List<NotificationSession> sessions,
    required DateTime now,
  }) async {
    final after = readingSecondsOnDay(sessions, now);
    final before = _todaySeconds;
    _todaySeconds = after;
    final day = notificationPromptDay(now);
    if (_goalAnnouncedOn == day) return;
    if (!readingGoalCrossed(
      beforeSeconds: before,
      afterSeconds: after,
      goalMinutes: goalMinutes,
    )) {
      return;
    }
    final shown = await _notifications.show(
      readingNotificationMessage(goalMetNotification(goalMinutes), l10n),
    );
    if (shown) _goalAnnouncedOn = day;
  }
}
