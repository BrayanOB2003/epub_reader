import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/book_reading_block.dart';
import 'package:epub_reader/features/habits/book_readings_page.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every book with sessions is listed, newest first', () {
    final now = DateTime(2026, 10, 13, 18);
    final reports = bookReadingReports(
      books: [
        _book(id: 1, title: 'Uno', progress: 0.5),
        _book(id: 2, title: 'Dos', progress: 0.2),
      ],
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: DateTime(2026, 10, 12, 20),
          seconds: 20 * 60,
        ),
        _session(
          id: 2,
          bookId: 9,
          startedAt: DateTime(2026, 10, 13, 9),
          seconds: 40 * 60,
        ),
        _session(
          id: 3,
          bookId: 2,
          startedAt: DateTime(2026, 10, 13, 12),
          seconds: 10 * 60,
        ),
      ],
      now: now,
    );

    expect(reports.map((report) => report.book.title), ['Dos', 'Uno']);
    expect(reports.first.engagedSeconds, 10 * 60);
    expect(reports.first.sessions, 1);
    expect(reports.last.engagedSeconds, 20 * 60);
    expect(reports.last.sessions, 1);
    expect(reports.first.quotes, 0);
  });

  test('quotes stay with the book they were taken from', () {
    final reports = bookReadingReports(
      books: [
        _book(id: 1, title: 'Uno', progress: 0.5),
        _book(id: 2, title: 'Dos', progress: 0.2),
      ],
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: DateTime(2026, 10, 10, 20),
          seconds: 20 * 60,
        ),
        _session(
          id: 2,
          bookId: 1,
          startedAt: DateTime(2026, 10, 12, 20),
          seconds: 15 * 60,
        ),
        _session(
          id: 3,
          bookId: 2,
          startedAt: DateTime(2026, 10, 13, 12),
          seconds: 10 * 60,
        ),
      ],
      quoteBookIds: const [1, 9, 1, 1],
      now: DateTime(2026, 10, 13, 18),
    );

    final uno = reports.firstWhere((report) => report.book.id == 1);
    final dos = reports.firstWhere((report) => report.book.id == 2);
    expect(uno.sessions, 2);
    expect(uno.quotes, 3);
    expect(dos.sessions, 1);
    expect(dos.quotes, 0);
  });

  test('the current book is the latest session still in the library', () {
    final now = DateTime(2026, 10, 13, 18);
    final report = currentBookReading(
      books: [
        _book(id: 1, title: 'Uno', progress: 0.5),
        _book(id: 2, title: 'Dos', progress: 0.2),
      ],
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: DateTime(2026, 10, 12, 20),
          seconds: 20 * 60,
        ),
        _session(
          id: 2,
          bookId: 9,
          startedAt: DateTime(2026, 10, 13, 9),
          seconds: 40 * 60,
        ),
        _session(
          id: 3,
          bookId: 2,
          startedAt: DateTime(2026, 10, 13, 12),
          seconds: 10 * 60,
        ),
      ],
      now: now,
    );

    expect(report?.book.title, 'Dos');
    expect(report?.engagedSeconds, 10 * 60);
    expect(report?.pace.horizon, isNull);
  });

  test('pace is minutes per 10 percent and weeks of recent reading', () {
    final now = DateTime(2026, 10, 13, 18);
    final pace = bookReadingPace(
      engagedSeconds: 60 * 60,
      progress: 0.5,
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: DateTime(2026, 10, 1, 20),
          seconds: 20 * 60,
        ),
        _session(
          id: 2,
          bookId: 1,
          startedAt: DateTime(2026, 10, 6, 20),
          seconds: 20 * 60,
        ),
        _session(
          id: 3,
          bookId: 1,
          startedAt: DateTime(2026, 10, 10, 20),
          seconds: 20 * 60,
        ),
      ],
      now: now,
    );

    expect(pace.remainingMinutes, 60);
    expect(pace.minutesPerTenPercent, 10);
    expect(pace.horizon?.kind, ReadingHorizonKind.weeks);
    expect(pace.horizon?.count, 2);
  });

  test('a short span is counted in sittings, not weeks', () {
    final pace = bookReadingPace(
      engagedSeconds: 45 * 60,
      progress: 0.25,
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: DateTime(2026, 10, 11, 20),
          seconds: 15 * 60,
        ),
        _session(
          id: 2,
          bookId: 1,
          startedAt: DateTime(2026, 10, 12, 20),
          seconds: 15 * 60,
        ),
        _session(
          id: 3,
          bookId: 1,
          startedAt: DateTime(2026, 10, 13, 20),
          seconds: 15 * 60,
        ),
      ],
      now: DateTime(2026, 10, 13, 21),
    );

    expect(pace.remainingMinutes, 135);
    expect(pace.horizon?.kind, ReadingHorizonKind.sittings);
    expect(pace.horizon?.count, 9);
  });

  test('a week of light reading stays under a week', () {
    final pace = bookReadingPace(
      engagedSeconds: 60 * 60,
      progress: 0.95,
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: DateTime(2026, 10, 1, 20),
          seconds: 20 * 60,
        ),
        _session(
          id: 2,
          bookId: 1,
          startedAt: DateTime(2026, 10, 7, 20),
          seconds: 20 * 60,
        ),
        _session(
          id: 3,
          bookId: 1,
          startedAt: DateTime(2026, 10, 13, 20),
          seconds: 20 * 60,
        ),
      ],
      now: DateTime(2026, 10, 13, 21),
    );

    expect(pace.horizon?.kind, ReadingHorizonKind.underAWeek);
    expect(pace.horizon?.count, isNull);
  });

  test('one day of sessions has no horizon', () {
    final day = DateTime(2026, 10, 13, 20);
    final pace = bookReadingPace(
      engagedSeconds: 60 * 60,
      progress: 0.5,
      sessions: [
        _session(id: 1, bookId: 1, startedAt: day, seconds: 20 * 60),
        _session(
          id: 2,
          bookId: 1,
          startedAt: day.add(const Duration(hours: 1)),
          seconds: 20 * 60,
        ),
        _session(
          id: 3,
          bookId: 1,
          startedAt: day.add(const Duration(hours: 2)),
          seconds: 20 * 60,
        ),
      ],
      now: DateTime(2026, 10, 13, 23),
    );

    expect(pace.remainingMinutes, 60);
    expect(pace.minutesPerTenPercent, 10);
    expect(pace.horizon, isNull);
  });

  test('a short visit shows only the time already read', () {
    final pace = bookReadingPace(
      engagedSeconds: 90,
      progress: 0.5,
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: DateTime(2026, 10, 13, 20),
          seconds: 90,
        ),
      ],
      now: DateTime(2026, 10, 13, 21),
    );

    expect(pace.remainingMinutes, isNull);
    expect(pace.minutesPerTenPercent, isNull);
    expect(pace.horizon, isNull);
  });

  testWidgets('the book list shows every book that has sessions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        BookReadingList(
          reports: [
            BookReadingReport(
              book: _book(id: 1, title: 'Dos', progress: 0.2),
              engagedSeconds: 10 * 60,
              sessions: 1,
              pace: const BookReadingPace(),
            ),
            BookReadingReport(
              book: _book(id: 2, title: 'Uno', progress: 0.5),
              engagedSeconds: 20 * 60,
              sessions: 4,
              quotes: 2,
              pace: const BookReadingPace(
                remainingMinutes: 40,
                minutesPerTenPercent: 10,
              ),
            ),
          ],
          onRead: (_) {},
        ),
      ),
    );

    expect(find.text('Por libro'), findsOneWidget);
    expect(find.text('Dos'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('Uno'), findsOneWidget);
    expect(find.text('20 min'), findsOneWidget);
    expect(find.text('Faltan ~40 min'), findsNothing);
    expect(find.textContaining('sesión'), findsNothing);

    await tester.tap(find.text('Uno'));
    await tester.pumpAndSettle();

    expect(find.text('Faltan ~40 min'), findsOneWidget);
    expect(find.text('~10 min por cada 10 %'), findsOneWidget);
    expect(find.text('4 sesiones · 2 citas'), findsOneWidget);
    expect(find.text('1 sesión'), findsNothing);
  });

  testWidgets('tapping a book opens its pace in a dialog', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    var opened = false;
    await tester.pumpWidget(
      _app(
        BookReadingBlock(
          report: BookReadingReport(
            book: _book(
              id: 1,
              title: 'Los días del faro',
              author: 'Marina Soler',
              progress: 0.4,
            ),
            engagedSeconds: 3 * 3600 + 45 * 60,
            sessions: 6,
            quotes: 1,
            pace: const BookReadingPace(
              remainingMinutes: 75,
              minutesPerTenPercent: 10,
              horizon: ReadingHorizon.weeks(3),
            ),
          ),
          onRead: () => opened = true,
        ),
      ),
    );

    expect(find.text('Los días del faro'), findsOneWidget);
    expect(find.text('Marina Soler'), findsOneWidget);
    expect(find.text('3 h 45 min'), findsOneWidget);
    expect(find.text('Faltan ~1 h 15 min'), findsNothing);

    await tester.tap(find.text('Los días del faro'));
    await tester.pumpAndSettle();

    expect(find.text('Faltan ~1 h 15 min'), findsOneWidget);
    expect(find.text('~10 min por cada 10 %'), findsOneWidget);
    expect(find.text('A este ritmo, unas 3 semanas'), findsOneWidget);
    expect(find.text('6 sesiones · 1 cita'), findsOneWidget);
    expect(find.byType(ScheduleRule), findsOneWidget);

    final dialog = find.byType(AlertDialog);
    expect(
      tester.widget<AlertDialog>(dialog).backgroundColor,
      ScheduleColors.light.paper,
    );
    final cover = tester.getRect(
      find.descendant(
        of: dialog,
        matching: find.byType(ScheduleCoverPlaceholder),
      ),
    );
    final figure = tester.getRect(
      find.descendant(
        of: dialog,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == '3 h 45 min' &&
              widget.style?.fontSize == 28,
        ),
      ),
    );
    final title = tester.getTopLeft(
      find.descendant(of: dialog, matching: find.text('Los días del faro')),
    );
    final left = tester.getRect(
      find.descendant(of: dialog, matching: find.text('Faltan ~1 h 15 min')),
    );
    final pace = tester.getRect(
      find.descendant(of: dialog, matching: find.text('~10 min por cada 10 %')),
    );
    final horizon = tester.getRect(
      find.descendant(
        of: dialog,
        matching: find.text('A este ritmo, unas 3 semanas'),
      ),
    );
    expect(figure.left, closeTo(cover.left, 1));
    expect(figure.left, lessThan(title.dx));
    expect(figure.top, greaterThan(cover.bottom));
    expect(left.top - figure.bottom, greaterThan(4));
    expect(left.top - figure.bottom, lessThan(16));
    expect(pace.top - left.bottom, greaterThan(left.top - figure.bottom));
    expect(horizon.top - pace.bottom, greaterThan(4));
    expect(horizon.top - pace.bottom, lessThan(16));

    await tester.tap(find.text('Leer'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    expect(find.text('Faltan ~1 h 15 min'), findsNothing);
  });

  testWidgets('without a pace the dialog shows the session and no quotes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        BookReadingBlock(
          report: BookReadingReport(
            book: _book(id: 1, title: 'Uno', progress: 0.01),
            engagedSeconds: 90,
            sessions: 1,
            pace: const BookReadingPace(),
          ),
          onRead: () {},
        ),
      ),
    );

    expect(find.text('Uno'), findsOneWidget);
    expect(find.text('1 min 30 s'), findsOneWidget);
    expect(find.text('1 sesión'), findsNothing);

    await tester.tap(find.text('Uno'));
    await tester.pumpAndSettle();

    expect(find.text('1 sesión'), findsOneWidget);
    expect(find.byType(ScheduleRule), findsOneWidget);
    final dialog = find.byType(AlertDialog);
    final cover = tester.getTopLeft(
      find.descendant(
        of: dialog,
        matching: find.byType(ScheduleCoverPlaceholder),
      ),
    );
    final figure = tester.getTopLeft(
      find.descendant(
        of: dialog,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == '1 min 30 s' &&
              widget.style?.fontSize == 28,
        ),
      ),
    );
    final sessions = tester.getTopLeft(
      find.descendant(of: dialog, matching: find.text('1 sesión')),
    );
    expect(figure.dx, closeTo(cover.dx, 1));
    expect(sessions.dy, greaterThan(figure.dy + 28));
    expect(find.textContaining('cita'), findsNothing);
    expect(find.textContaining('Faltan'), findsNothing);
    expect(find.textContaining('ritmo'), findsNothing);
  });
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

Book _book({
  required int id,
  required String title,
  double progress = 0,
  String? author,
}) {
  return Book(
    id: id,
    title: title,
    author: author,
    filePath: 'book.epub',
    progress: progress,
    darkMode: false,
    scrollMode: false,
    fontSize: 1,
    addedAt: DateTime.utc(2026, 1, 1),
  );
}

ReadingSession _session({
  required int id,
  required int bookId,
  required DateTime startedAt,
  required int seconds,
}) {
  return ReadingSession(
    id: id,
    bookId: bookId,
    startedAt: startedAt,
    endedAt: startedAt.add(Duration(seconds: seconds)),
    engagedSeconds: seconds,
    sample: false,
  );
}
