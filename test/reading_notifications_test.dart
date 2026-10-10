import 'package:epub_reader/features/notifications/reading_notifications.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('es'));
  const week = {1, 2, 3, 4, 5, 6, 7};
  final now = DateTime(2026, 10, 10, 18);

  test('the routine reminder uses the chosen hour and goal', () {
    final plan = planReadingNotifications(
      now: now,
      goalMinutes: 20,
      hour: 21,
      weekdays: week,
      sessions: const [],
      books: const [],
    );

    expect(plan.first.kind, ReadingNotificationKind.routine);
    expect(plan.first.at, DateTime(2026, 10, 10, 21));
    expect(plan.first.location, '/library');
    expect(
      readingNotificationMessage(plan.first, l10n).body,
      'Son las 21:00. Hoy tu meta es 20 min.',
    );
    expect(plan, hasLength(readingNotificationHorizon));
  });

  test('a partial day says how many minutes are left', () {
    final plan = planReadingNotifications(
      now: now,
      goalMinutes: 20,
      hour: 21,
      weekdays: week,
      sessions: [
        NotificationSession(
          bookId: 4,
          startedAt: DateTime(2026, 10, 10, 12),
          endedAt: DateTime(2026, 10, 10, 12, 12),
          engagedSeconds: 12 * 60,
        ),
      ],
      books: const [NotificationBook(id: 4, title: 'Moby Dick', progress: 0.4)],
    );

    expect(plan.first.kind, ReadingNotificationKind.goalRemaining);
    expect(plan.first.location, '/read/4');
    expect(
      readingNotificationMessage(plan.first, l10n).body,
      'Te faltan 8 min para cerrar el día.',
    );
    expect(plan[1].kind, ReadingNotificationKind.routine);
  });

  test('meeting the goal announces once and skips tonight', () {
    final before = [
      NotificationSession(
        bookId: 1,
        startedAt: now,
        endedAt: now,
        engagedSeconds: 19 * 60,
      ),
    ];
    final after = [
      NotificationSession(
        bookId: 1,
        startedAt: now,
        endedAt: now,
        engagedSeconds: 20 * 60,
      ),
    ];
    expect(
      dailyGoalJustMet(before: before, after: after, goalMinutes: 20, now: now),
      isTrue,
    );
    expect(
      dailyGoalJustMet(before: after, after: after, goalMinutes: 20, now: now),
      isFalse,
    );
    expect(
      sessionCrossedReadingGoal(
        sessions: after,
        sessionStartedAt: now,
        sessionSeconds: 20 * 60,
        goalMinutes: 20,
        now: now,
      ),
      isTrue,
    );
    expect(
      sessionCrossedReadingGoal(
        sessions: [
          NotificationSession(
            bookId: 1,
            startedAt: now,
            endedAt: now,
            engagedSeconds: 25 * 60,
          ),
        ],
        sessionStartedAt: now,
        sessionSeconds: 5 * 60,
        goalMinutes: 20,
        now: now,
      ),
      isFalse,
    );
    expect(
      readingNotificationMessage(goalMetNotification(20), l10n).body,
      'Cerraste el día. 20 min.',
    );

    final plan = planReadingNotifications(
      now: now,
      goalMinutes: 20,
      hour: 21,
      weekdays: week,
      sessions: after,
      books: const [],
    );
    expect(plan.first.at, DateTime(2026, 10, 11, 21));
    expect(plan.first.kind, ReadingNotificationKind.routine);
  });

  test('a book left for several days opens on its chapter', () {
    final plan = planReadingNotifications(
      now: now,
      goalMinutes: 20,
      hour: 21,
      weekdays: week,
      sessions: [
        NotificationSession(
          bookId: 4,
          startedAt: DateTime(2026, 10, 6, 21),
          endedAt: DateTime(2026, 10, 6, 21, 20),
          engagedSeconds: 10 * 60,
        ),
      ],
      books: const [
        NotificationBook(
          id: 4,
          title: 'Moby Dick',
          progress: 0.4,
          locatorJson: '{"title":"El naufragio","locations":{"position":4}}',
        ),
      ],
    );

    expect(plan.first.kind, ReadingNotificationKind.resume);
    expect(plan.first.location, '/read/4');
    expect(
      readingNotificationMessage(plan.first, l10n).body,
      'Sigues en el capítulo 4 de Moby Dick.',
    );
    expect(plan[1].kind, ReadingNotificationKind.routine);
  });

  test('a streak about to break asks for today', () {
    final plan = planReadingNotifications(
      now: now,
      goalMinutes: 20,
      hour: 21,
      weekdays: week,
      sessions: [
        for (var day = 5; day <= 9; day++)
          NotificationSession(
            bookId: 1,
            startedAt: DateTime(2026, 10, day, 21),
            endedAt: DateTime(2026, 10, day, 21, 10),
            engagedSeconds: 10 * 60,
          ),
      ],
      books: const [NotificationBook(id: 1, title: 'Diario', progress: 0.2)],
    );

    expect(plan.first.kind, ReadingNotificationKind.streak);
    expect(plan.first.location, '/time');
    expect(
      readingNotificationMessage(plan.first, l10n).body,
      'Llevas 5 días. Hoy también cuenta.',
    );
  });

  test('a passed hour waits until the next reading day', () {
    final evening = DateTime(2026, 10, 10, 22);
    final plan = planReadingNotifications(
      now: evening,
      goalMinutes: 10,
      hour: 21,
      weekdays: {evening.weekday},
      sessions: const [],
      books: const [],
    );
    final nextWeek = evening.add(const Duration(days: 7));

    expect(
      plan.first.at,
      DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 21),
    );
    expect(plan, hasLength(2));
  });
}
