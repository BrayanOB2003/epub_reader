import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/habits/month_reading_card.dart';
import 'package:epub_reader/features/habits/month_reading_page.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a closed month wins over the month in progress', () {
    final report = _report(
      now: DateTime(2026, 11, 2, 12),
      sessions: [
        _session(id: 1, at: DateTime(2026, 10, 10, 21), seconds: 10 * 60),
        _session(id: 2, at: DateTime(2026, 11, 1, 21), seconds: 10 * 60),
      ],
    );

    expect(report?.month, DateTime(2026, 10));
    expect(report?.closed, isTrue);
    expect(report?.engagedSeconds, 10 * 60);
  });

  test('the month in progress has days and minutes, not an archetype', () {
    final report = _report(
      now: DateTime(2026, 10, 15, 12),
      plan: _plan(),
      sessions: [
        for (var day = 1; day <= 10; day++)
          _session(id: day, at: DateTime(2026, 10, day, 21), seconds: 10 * 60),
      ],
    );

    expect(report?.closed, isFalse);
    expect(report?.archetype, isNull);
    expect(report?.minuteDeltaSeconds, isNull);
    expect(report?.metDays, 10);
    expect(report?.plannedDays, 15);
    expect(report?.engagedSeconds, 10 * 60 * 10);
  });

  test('no reading means no review', () {
    expect(_report(sessions: const []), isNull);
  });

  test('minutes compare with the previous month when both have reading', () {
    final more = _report(
      sessions: [
        _session(id: 1, at: DateTime(2026, 9, 3, 21), seconds: 2 * 3600),
        _session(id: 2, at: DateTime(2026, 10, 3, 21), seconds: 4 * 3600),
      ],
    );
    expect(more?.minuteDeltaSeconds, 2 * 3600);
    expect(more?.comparedMonth, DateTime(2026, 9));

    final less = _report(
      sessions: [
        _session(id: 1, at: DateTime(2026, 9, 3, 21), seconds: 3 * 3600),
        _session(id: 2, at: DateTime(2026, 10, 3, 21), seconds: 3600),
      ],
    );
    expect(less?.minuteDeltaSeconds, -2 * 3600);

    final same = _report(
      sessions: [
        _session(id: 1, at: DateTime(2026, 9, 3, 21), seconds: 3600),
        _session(id: 2, at: DateTime(2026, 10, 3, 21), seconds: 3600),
      ],
    );
    expect(same?.minuteDeltaSeconds, isNull);
  });

  test('methodical wins when the hour is kept, even in the afternoon', () {
    final report = _report(
      plan: _plan(hour: 15),
      sessions: [
        for (var day = 1; day <= 8; day++)
          _session(
            id: day,
            at: DateTime(2026, 10, day, 15, 10),
            seconds: 10 * 60,
          ),
      ],
    );

    expect(report?.archetype?.kind, MonthArchetype.methodical);
    final evidence = report?.archetype?.evidence as MethodicalEvidence;
    expect(evidence.onTime, 8);
    expect(evidence.sessions, 8);
    expect(evidence.hour, 15);
  });

  test('seven of ten readings near the hour is methodical', () {
    final report = _report(
      plan: _plan(hour: 15),
      sessions: [
        for (var day = 1; day <= 10; day++)
          _session(
            id: day,
            at: DateTime(2026, 10, day, day <= 7 ? 15 : 20),
            seconds: 10 * 60,
          ),
      ],
    );

    expect(report?.archetype?.kind, MonthArchetype.methodical);
  });

  test('the ant is short days on the chosen weekdays', () {
    expect(DateTime(2026, 10, 4).weekday, DateTime.sunday);
    final report = _report(
      plan: _plan(hour: 8, weekdays: {ReadingWeekday.sunday}),
      sessions: [
        for (final day in [4, 11, 18, 25]) ...[
          _session(id: day, at: DateTime(2026, 10, day, 20), seconds: 5 * 60),
          _session(
            id: day + 100,
            at: DateTime(2026, 10, day, 21),
            seconds: 5 * 60,
          ),
        ],
      ],
    );

    expect(report?.metDays, 4);
    expect(report?.plannedDays, 4);
    expect(report?.archetype?.kind, MonthArchetype.ant);
  });

  test('a long day above the goal is the marathoner', () {
    final report = _report(
      plan: _plan(hour: 8, goal: 10),
      sessions: [
        for (var day = 1; day <= 8; day++)
          _session(id: day, at: DateTime(2026, 10, day, 20), seconds: 30 * 60),
      ],
    );

    expect(report?.archetype?.kind, MonthArchetype.marathoner);
    final evidence = report?.archetype?.evidence as MarathonerEvidence;
    expect(evidence.averageSeconds, 30 * 60);
  });

  test('night includes 21:00 and 1:00', () {
    final report = _report(
      plan: _plan(hour: 15),
      sessions: [
        for (var day = 1; day <= 4; day++)
          _session(id: day, at: DateTime(2026, 10, day, 21), seconds: 10 * 60),
        for (var day = 5; day <= 8; day++)
          _session(id: day, at: DateTime(2026, 10, day, 1), seconds: 10 * 60),
      ],
    );

    expect(report?.archetype?.kind, MonthArchetype.nightOwl);
    expect((report?.archetype?.evidence as BandEvidence).percent, 100);
  });

  test('10:00 is morning and 15:00 is afternoon', () {
    final morning = _report(
      plan: _plan(hour: 21),
      sessions: [
        for (var day = 1; day <= 8; day++)
          _session(id: day, at: DateTime(2026, 10, day, 10), seconds: 10 * 60),
      ],
    );
    expect(morning?.archetype?.kind, MonthArchetype.earlyRiser);

    final afternoon = _report(
      plan: _plan(hour: 21),
      sessions: [
        for (var day = 1; day <= 8; day++)
          _session(id: day, at: DateTime(2026, 10, day, 15), seconds: 10 * 60),
      ],
    );
    expect(afternoon?.archetype?.kind, MonthArchetype.afternoon);
  });

  test('a day split across bands, or read at 4:00, is nomad', () {
    final split = _report(
      plan: _plan(hour: 8),
      sessions: [
        for (var day = 1; day <= 9; day++)
          _session(
            id: day,
            at: DateTime(2026, 10, day, [8, 15, 21][(day - 1) % 3]),
            seconds: 10 * 60,
          ),
      ],
    );
    expect(split?.archetype?.kind, MonthArchetype.nomad);

    final four = _report(
      plan: _plan(hour: 15),
      sessions: [
        for (var day = 1; day <= 8; day++)
          _session(id: day, at: DateTime(2026, 10, day, 4), seconds: 10 * 60),
      ],
    );
    expect(four?.archetype?.kind, MonthArchetype.nomad);
  });

  test('quotes in a third of the readings beat the hour', () {
    final sessions = [
      for (var day = 1; day <= 8; day++)
        _session(id: day, at: DateTime(2026, 10, day, 21), seconds: 10 * 60),
    ];
    final hunter = _report(
      plan: _plan(hour: 8),
      sessions: sessions,
      quotes: [
        for (final session in sessions)
          MonthQuoteInput(
            id: session.id,
            bookId: 1,
            savedAt: session.startedAt.add(const Duration(minutes: 1)),
            text: 'Idea ${session.id}',
            bookTitle: 'Uno',
          ),
      ],
    );
    expect(hunter?.archetype?.kind, MonthArchetype.ideaHunter);

    final piled = _report(
      plan: _plan(hour: 8),
      sessions: sessions,
      quotes: [
        for (var index = 0; index < 8; index++)
          MonthQuoteInput(
            id: index,
            bookId: 1,
            savedAt: sessions.first.startedAt.add(Duration(minutes: index)),
            text: 'Idea $index',
            bookTitle: 'Uno',
          ),
      ],
    );
    expect(piled?.archetype?.kind, MonthArchetype.nightOwl);
  });

  test('fewer than eight readings has no archetype', () {
    final report = _report(
      plan: _plan(hour: 15),
      sessions: [
        for (var day = 1; day <= 7; day++)
          _session(id: day, at: DateTime(2026, 10, day, 21), seconds: 10 * 60),
      ],
    );

    expect(report?.archetype, isNull);
    expect(report?.engagedSeconds, 7 * 10 * 60);
  });

  test('a later plan save still counts the short days of the month', () {
    final report = _report(
      now: DateTime(2026, 10, 13, 12),
      plan: _plan(hour: 14, goal: 10),
      sessions: [
        for (var day = 1; day <= 30; day++)
          _session(
            id: day,
            at: DateTime(2026, 9, day, 21),
            seconds: day == 3 || day == 22 ? 9 * 60 : 10 * 60,
          ),
      ],
    );

    expect(report?.month, DateTime(2026, 9));
    expect(report?.metDays, 28);
    expect(report?.plannedDays, 30);
  });

  test('a finished book has no horizon and an open one keeps the weeks', () {
    final now = DateTime(2026, 11, 2, 18);
    final sessions = [
      _session(id: 1, at: DateTime(2026, 10, 20, 20), seconds: 20 * 60),
      _session(id: 2, at: DateTime(2026, 10, 24, 20), seconds: 20 * 60),
      _session(id: 3, at: DateTime(2026, 10, 28, 20), seconds: 20 * 60),
    ];
    final finished = _report(
      now: now,
      sessions: sessions,
      books: [_book(id: 1, title: 'Cerrado', progress: 1)],
    );
    expect(finished?.books.single.finished, isTrue);
    expect(finished?.books.single.horizon, isNull);

    final open = _report(
      now: now,
      sessions: sessions,
      books: [_book(id: 1, title: 'Abierto', progress: 0.5)],
    );
    expect(open?.books.single.finished, isFalse);
    expect(open?.books.single.horizon?.kind, ReadingHorizonKind.weeks);
    expect(open?.books.single.horizon?.count, 2);
  });

  test('the review keeps the three most-read books', () {
    final report = _report(
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          at: DateTime(2026, 10, 2, 21),
          seconds: 10 * 60,
        ),
        _session(
          id: 2,
          bookId: 2,
          at: DateTime(2026, 10, 3, 21),
          seconds: 40 * 60,
        ),
        _session(
          id: 3,
          bookId: 3,
          at: DateTime(2026, 10, 4, 21),
          seconds: 5 * 60,
        ),
        _session(
          id: 4,
          bookId: 4,
          at: DateTime(2026, 10, 5, 21),
          seconds: 30 * 60,
        ),
      ],
      books: [
        _book(id: 1, title: 'Corto', progress: 0.2),
        _book(id: 2, title: 'Largo', progress: 0.2),
        _book(id: 3, title: 'Breve', progress: 0.2),
        _book(id: 4, title: 'Medio', progress: 0.2),
      ],
    );

    expect(
      report?.books.map((book) => book.title).toList(),
      ['Largo', 'Medio', 'Corto'],
    );
  });

  test('the latest quote of the month is kept', () {
    final report = _report(
      sessions: [
        _session(id: 1, at: DateTime(2026, 10, 2, 21), seconds: 10 * 60),
      ],
      quotes: [
        MonthQuoteInput(
          id: 1,
          bookId: 1,
          savedAt: DateTime(2026, 10, 2, 21, 5),
          text: 'Primera',
          bookTitle: 'Uno',
        ),
        MonthQuoteInput(
          id: 2,
          bookId: 1,
          savedAt: DateTime(2026, 10, 8, 21, 5),
          text: 'Última',
          bookTitle: 'Dos',
        ),
      ],
    );

    expect(report?.quote?.passage, 'Última');
    expect(report?.quote?.bookTitle, 'Dos');
  });

  testWidgets('the review shows the month, the horizon, and share', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        MonthReadingView(
          report: MonthReadingReport(
            month: DateTime(2026, 10),
            closed: true,
            engagedSeconds: 4 * 3600,
            metDays: 11,
            plannedDays: 18,
            minuteDeltaSeconds: 2 * 3600,
            comparedMonth: DateTime(2026, 9),
            books: const [
              MonthBookLine(
                bookId: 1,
                title: 'Los días del faro',
                engagedSeconds: 40 * 60,
                progress: 0.4,
                finished: false,
                horizon: ReadingHorizon.weeks(3),
              ),
            ],
            archetype: const MonthArchetypeReport(
              kind: MonthArchetype.methodical,
              evidence: MethodicalEvidence(onTime: 9, sessions: 12, hour: 15),
            ),
            quote: const MonthQuoteLine(
              passage: 'La calma llega tarde.',
              bookTitle: 'Los días del faro',
            ),
          ),
          onRead: (_) {},
          onShare: (_, _) {},
        ),
      ),
    );

    expect(find.text('Octubre'), findsOneWidget);
    expect(
      find.text('En octubre cumpliste 11 de 18 días de tu plan.'),
      findsOneWidget,
    );
    expect(find.text('4 h'), findsOneWidget);
    expect(find.text('2 h más que en septiembre'), findsOneWidget);
    expect(find.text('Los días del faro'), findsWidgets);
    expect(find.text('40 min'), findsOneWidget);
    expect(find.text('A este ritmo, unas 3 semanas'), findsOneWidget);
    expect(find.textContaining('noviembre'), findsNothing);
    expect(find.text('Lector metódico'), findsOneWidget);
    expect(find.text('La constancia ya forma parte de ti.'), findsOneWidget);
    expect(
      find.text('9 de 12 lecturas empezaron cerca de las 15:00.'),
      findsOneWidget,
    );
    expect(find.text('La calma llega tarde.'), findsOneWidget);
    expect(find.text('Compartir'), findsOneWidget);
  });

  testWidgets('an open month omits the archetype', (tester) async {
    await tester.pumpWidget(
      _app(
        MonthReadingView(
          report: MonthReadingReport(
            month: DateTime(2026, 10),
            closed: false,
            engagedSeconds: 20 * 60,
            metDays: 2,
            plannedDays: 4,
            books: const [],
          ),
          onRead: (_) {},
          onShare: (_, _) {},
        ),
      ),
    );

    expect(
      find.text('En octubre cumpliste 2 de 4 días de tu plan.'),
      findsOneWidget,
    );
    expect(find.text('Lector metódico'), findsNothing);
    expect(find.text('Compartir'), findsOneWidget);
  });

  testWidgets('without a month the review says when it appears', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(MonthReadingView(report: null, onRead: (_) {}, onShare: (_, _) {})),
    );

    expect(find.text('Resumen del mes'), findsOneWidget);
    expect(
      find.text('El resumen aparece al cerrar un mes con lectura.'),
      findsOneWidget,
    );
    expect(find.text('Compartir'), findsNothing);
  });

  testWidgets('the shared card is a png', (tester) async {
    final bytes = await tester.runAsync(
      () => renderMonthCard(
        const MonthCardCopy(
          month: 'Octubre',
          headline: 'En octubre cumpliste 11 de 18 días de tu plan.',
          minutes: '4 h',
          archetype: 'Lector metódico',
        ),
      ),
    );

    expect(bytes!.sublist(0, 4), [137, 80, 78, 71]);
  });
}

MonthReadingReport? _report({
  required List<ReadingSession> sessions,
  DateTime? now,
  MonthPlan? plan,
  List<Book> books = const [],
  List<MonthQuoteInput> quotes = const [],
}) {
  return monthReadingReport(
    sessions: sessions,
    books: books,
    quotes: quotes,
    plan: plan,
    now: now ?? DateTime(2026, 11, 2, 12),
  );
}

MonthPlan _plan({
  int goal = 10,
  int? hour = 15,
  Set<ReadingWeekday> weekdays = defaultReadingWeekdays,
}) {
  return MonthPlan(
    dailyGoalMinutes: goal,
    routineHour: hour,
    weekdays: weekdays,
  );
}

ReadingSession _session({
  required int id,
  required DateTime at,
  required int seconds,
  int bookId = 1,
}) {
  return ReadingSession(
    id: id,
    bookId: bookId,
    startedAt: at,
    endedAt: at.add(Duration(seconds: seconds)),
    engagedSeconds: seconds,
  );
}

Book _book({required int id, required String title, required double progress}) {
  return Book(
    id: id,
    title: title,
    filePath: 'book.epub',
    progress: progress,
    darkMode: false,
    scrollMode: false,
    fontSize: 1,
    addedAt: DateTime(2026, 1, 1),
  );
}

Widget _app(Widget child) {
  return MaterialApp(
    theme: scheduleTheme(Brightness.light),
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
