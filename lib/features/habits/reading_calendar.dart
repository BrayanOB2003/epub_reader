import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/features/habits/weekly_reading_chart.dart';
import 'package:flutter/material.dart';

class ReadingCalendar extends StatefulWidget {
  const ReadingCalendar({
    super.key,
    required this.sessions,
    required this.goalSeconds,
    required this.today,
  });

  final List<ReadingSession> sessions;
  final int? goalSeconds;
  final DateTime today;

  @override
  State<ReadingCalendar> createState() => _ReadingCalendarState();
}

class _ReadingCalendarState extends State<ReadingCalendar> {
  late DateTime _month;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final month = readingMonth(
      sessions: widget.sessions,
      month: _month,
      goalSeconds: widget.goalSeconds,
    );
    final cells = <ReadingCalendarDay?>[
      for (var index = 0; index < month.leadingBlanks; index++) null,
      ...month.days,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mes anterior',
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    formatReadingMonth(_month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Mes siguiente',
                  onPressed: _canGoForward ? () => _shift(1) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final label in weekdayLabels)
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
                          ? const SizedBox(height: 40)
                          : _DayCell(
                              day: day,
                              isToday: _sameDay(day.day, widget.today),
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday});

  final ReadingCalendarDay day;
  final bool isToday;

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
    final borderColor = day.mark == ReadingDayMark.met
        ? color.onPrimary
        : color.primary;

    return Semantics(
      container: true,
      label: _dayLabel(day),
      excludeSemantics: true,
      child: SizedBox(
        height: 40,
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: isToday
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
            ),
            child: Text(
              '${day.day.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _dayLabel(ReadingCalendarDay day) {
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  final date = '${day.day.day} de ${months[day.day.month - 1]}';
  final state = switch (day.mark) {
    ReadingDayMark.met => 'meta cumplida',
    ReadingDayMark.partial => 'leído sin cumplir la meta',
    ReadingDayMark.none => 'sin lectura',
  };
  return '$date, $state';
}

bool _sameDay(DateTime day, DateTime today) {
  final current = today.toLocal();
  return day.year == current.year &&
      day.month == current.month &&
      day.day == current.day;
}
