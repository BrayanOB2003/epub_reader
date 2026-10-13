import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BookReadingBlock extends StatelessWidget {
  const BookReadingBlock({
    required this.report,
    required this.onRead,
    super.key,
  });

  final BookReadingReport report;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final book = report.book;
    final pace = report.pace;
    final remaining = pace.remainingMinutes;
    final perTen = pace.minutesPerTenPercent;
    final horizon = pace.horizon;
    final hasLines = remaining != null || perTen != null || horizon != null;
    final author = book.author?.trim();

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
          onTap: onRead,
          rule: false,
        ),
        if (hasLines)
          Padding(
            padding: const EdgeInsets.fromLTRB(68, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (remaining != null)
                  Text(
                    l10n.bookTimeLeft(formatReadingDuration(remaining * 60)),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colors.ink),
                  ),
                if (perTen != null)
                  Padding(
                    padding: EdgeInsets.only(top: remaining == null ? 0 : 4),
                    child: Text(
                      l10n.bookPacePerTen(formatReadingDuration(perTen * 60)),
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: colors.muted),
                    ),
                  ),
                if (horizon != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: remaining == null && perTen == null ? 0 : 4,
                    ),
                    child: Text(
                      readingHorizonLabel(l10n, horizon),
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: colors.muted),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
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
