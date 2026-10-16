import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/features/habits/weekly_reading_chart.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ReadingCalendar extends StatefulWidget {
  const ReadingCalendar({
    super.key,
    required this.sessions,
    required this.plans,
    required this.today,
    this.selectedDate,
    this.onDaySelected,
  });

  final List<ReadingSession> sessions;

  /// Goal in effect on each day. A later change does not recolor earlier days.
  final List<MonthPlanVersion> plans;
  final DateTime today;

  /// When set, this day is selected if it belongs to the visible month.
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDaySelected;

  @override
  State<ReadingCalendar> createState() => _ReadingCalendarState();
}

class _ReadingCalendarState extends State<ReadingCalendar> {
  late DateTime _month;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = widget.today.toLocal();
    _month = DateTime(today.year, today.month);
  }

  bool get _canGoForward {
    final today = widget.today.toLocal();
    return _month.isBefore(DateTime(today.year, today.month));
  }

  void _shift(int months) {
    setState(() => _month = DateTime(_month.year, _month.month + months));
  }

  DateTime? get _activeSelection => widget.selectedDate ?? _selectedDate;

  void _choose(DateTime day) {
    widget.onDaySelected?.call(day);
    if (widget.selectedDate != null) return;
    setState(() => _selectedDate = day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final month = readingMonth(
      sessions: widget.sessions,
      month: _month,
      goalOn: (day) {
        final plan = monthPlanOn(day, widget.plans);
        if (plan == null || plan.dailyGoalMinutes <= 0) return null;
        return plan.dailyGoalMinutes * 60;
      },
    );
    final cells = <ReadingCalendarDay?>[
      for (var index = 0; index < month.leadingBlanks; index++) null,
      ...month.days,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final labels = weekdayLabels(languageCode);
    final selected = _selectedDay(month, _activeSelection);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.previousMonth,
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  formatReadingMonth(_month, languageCode: languageCode),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.nextMonth,
                onPressed: _canGoForward ? () => _shift(1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final label in labels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < cells.length; index += 7) ...[
            Row(
              children: [
                for (final day in cells.sublist(index, index + 7))
                  Expanded(
                    child: day == null
                        ? const SizedBox(height: 48)
                        : _DayCell(
                            day: day,
                            isToday: _sameDay(day.day, widget.today),
                            selected:
                                _activeSelection != null &&
                                _sameDay(day.day, _activeSelection!),
                            label: _dayLabel(day, l10n, languageCode),
                            onTap: () => _choose(day.day),
                          ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (selected != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DayProgramReadout(
                day: l10n.calendarDate(
                  selected.day.day,
                  readingMonthName(selected.day, languageCode),
                ),
                duration: formatReadingDuration(selected.engagedSeconds),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final ReadingCalendarDay day;
  final bool isToday;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final background = switch (day.mark) {
      ReadingDayMark.met => color.primary,
      ReadingDayMark.partial => color.primary.withValues(alpha: 0.28),
      ReadingDayMark.none => Colors.transparent,
    };
    final foreground = day.mark == ReadingDayMark.met
        ? color.onPrimary
        : color.onSurface;
    final borderColor = selected
        ? (day.mark == ReadingDayMark.met ? color.onPrimary : color.primary)
        : day.mark == ReadingDayMark.met
        ? color.onPrimary
        : day.mark == ReadingDayMark.none
        ? color.outline
        : color.primary;

    return Semantics(
      button: true,
      selected: selected,
      container: true,
      label: isToday ? '$label, ${AppLocalizations.of(context).today}' : label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: background,
                        border: Border.all(color: borderColor),
                      ),
                    ),
                  ),
                  Text(
                    '${day.day.day}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: foreground,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (isToday)
                    Positioned(
                      bottom: 3,
                      child: ColoredBox(
                        color: day.mark == ReadingDayMark.met
                            ? color.onPrimary
                            : color.primary,
                        child: const SizedBox(width: 10, height: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _dayLabel(
  ReadingCalendarDay day,
  AppLocalizations l10n,
  String languageCode,
) {
  final state = switch (day.mark) {
    ReadingDayMark.met => l10n.goalMet,
    ReadingDayMark.partial => l10n.partialReading,
    ReadingDayMark.none => l10n.noReading,
  };
  return l10n.calendarDay(
    day.day.day,
    readingMonthName(day.day, languageCode),
    formatReadingDuration(day.engagedSeconds),
    state,
  );
}

ReadingCalendarDay? _selectedDay(ReadingMonth month, DateTime? selected) {
  if (selected == null) return null;
  for (final day in month.days) {
    if (_sameDay(day.day, selected)) return day;
  }
  return null;
}

bool _sameDay(DateTime day, DateTime today) {
  final current = today.toLocal();
  return day.year == current.year &&
      day.month == current.month &&
      day.day == current.day;
}
