import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BookReadingBlock extends StatelessWidget {
  const BookReadingBlock({
    required this.report,
    required this.onRead,
    this.logRow = false,
    super.key,
  });

  final BookReadingReport report;
  final VoidCallback onRead;

  /// The time screen's book: cover, title, author, and one duration.
  final bool logRow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final book = report.book;
    final pace = report.pace;
    final remaining = pace.remainingMinutes;
    final perTen = pace.minutesPerTenPercent;
    final horizon = pace.horizon;
    final lines = <_MetricLine>[
      if (remaining != null)
        _MetricLine(
          l10n.bookTimeLeft(formatReadingDuration(remaining * 60)),
          prominent: true,
        ),
      if (perTen != null)
        _MetricLine(l10n.bookPacePerTen(formatReadingDuration(perTen * 60))),
      if (horizon != null) _MetricLine(readingHorizonLabel(l10n, horizon)),
      if (report.sessions > 0)
        _MetricLine(
          report.sessions == 1
              ? l10n.bookSession
              : l10n.bookSessions(report.sessions),
        ),
      if (report.quotes > 0)
        _MetricLine(
          report.quotes == 1 ? l10n.bookQuote : l10n.bookQuotes(report.quotes),
        ),
    ];
    final author = book.author?.trim();
    final prominent = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: colors.ink);
    final quiet = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: colors.muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScheduleRule(),
        ScheduleListing(
          title: _shownTitle(book.title, l10n),
          subtitle: author == null || author.isEmpty ? null : author,
          cover: book.coverBytes,
          progress: book.progress,
          trailing: formatReadingDuration(report.engagedSeconds),
          programTrailing: logRow,
          onTap: onRead,
          rule: false,
        ),
        if (!logRow && lines.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(68, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < lines.length; index++)
                  Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 4),
                    child: Text(
                      lines[index].text,
                      style: lines[index].prominent ? prominent : quiet,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MetricLine {
  const _MetricLine(this.text, {this.prominent = false});

  final String text;
  final bool prominent;
}

String _shownTitle(String title, AppLocalizations l10n) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? l10n.untitled : trimmed;
}

String readingHorizonLabel(AppLocalizations l10n, ReadingHorizon horizon) {
  final count = horizon.count;
  return switch (horizon.kind) {
    ReadingHorizonKind.underAWeek => l10n.bookUnderAWeek,
    ReadingHorizonKind.weeks =>
      count == 1 ? l10n.bookWeekLeft : l10n.bookWeeksLeft(count!),
    ReadingHorizonKind.sittings =>
      count == 1 ? l10n.bookSittingLeft : l10n.bookSittingsLeft(count!),
  };
}
