import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

List<String> weekdayLabels(String languageCode) {
  if (languageCode == 'en') {
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }
  return const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
}

String weekdayName(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.monday,
    DateTime.tuesday => l10n.tuesday,
    DateTime.wednesday => l10n.wednesday,
    DateTime.thursday => l10n.thursday,
    DateTime.friday => l10n.friday,
    DateTime.saturday => l10n.saturday,
    _ => l10n.sunday,
  };
}

class WeeklyReadingChart extends StatefulWidget {
  const WeeklyReadingChart({
    super.key,
    required this.days,
    required this.goalSeconds,
    required this.today,
    this.selectedDay,
    this.onDaySelected,
  });

  final List<DailyReading> days;
  final int? goalSeconds;
  final DateTime today;

  /// When set, the chart highlights this day if it falls in [days].
  final DateTime? selectedDay;
  final ValueChanged<DateTime>? onDaySelected;

  @override
  State<WeeklyReadingChart> createState() => _WeeklyReadingChartState();
}

class _WeeklyReadingChartState extends State<WeeklyReadingChart> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = _todayIndex(widget.days, widget.today);
  }

  void _select(int index) {
    final day = widget.days[index].day;
    widget.onDaySelected?.call(day);
    if (widget.selectedDay != null) return;
    if (_selected == index) return;
    setState(() => _selected = index);
  }

  int? _resolvedIndex() {
    final external = widget.selectedDay;
    if (external == null) return _selected;
    for (var index = 0; index < widget.days.length; index++) {
      if (_sameDay(widget.days[index].day, external)) return index;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final days = widget.days;
    final labels = weekdayLabels(Localizations.localeOf(context).languageCode);
    final peak = days.fold<int>(
      0,
      (highest, day) =>
          day.engagedSeconds > highest ? day.engagedSeconds : highest,
    );
    final goal = widget.goalSeconds;
    final scale = _chartScale(goalSeconds: goal ?? 0, peakSeconds: peak);
    final goalFraction = goal == null || goal <= 0 ? null : goal / scale;
    final selected = _resolvedIndex();
    final selectedDay =
        selected == null || selected < 0 || selected >= days.length
        ? null
        : days[selected];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.thisWeek, style: theme.textTheme.titleMedium),
              const Spacer(),
              if (goalFraction != null)
                Text(
                  l10n.goalLine(formatReadingDuration(goal!)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < days.length; index++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: _DayBar(
                            fraction: days[index].engagedSeconds / scale,
                            label: l10n.dayReading(
                              weekdayName(l10n, days[index].day.weekday),
                              formatReadingDuration(days[index].engagedSeconds),
                            ),
                            fill: _barFill(
                              seconds: days[index].engagedSeconds,
                              goalSeconds: goal,
                              station: colors.station,
                            ),
                            selected: selected == index,
                            onTap: () => _select(index),
                          ),
                        ),
                      ),
                  ],
                ),
                if (goalFraction != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 96 * goalFraction - 1,
                    height: 2,
                    child: CustomPaint(
                      painter: _DashedGoalPainter(color: colors.ink),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              for (var index = 0; index < days.length; index++)
                Expanded(
                  child: _WeekdayLabel(
                    label: labels[days[index].day.weekday - 1],
                    isToday: _sameDay(days[index].day, widget.today),
                    selected: selected == index,
                    onTap: () => _select(index),
                  ),
                ),
            ],
          ),
          if (selectedDay != null)
            DayProgramReadout(
              day: weekdayName(l10n, selectedDay.day.weekday),
              duration: formatReadingDuration(selectedDay.engagedSeconds),
            ),
        ],
      ),
    );
  }
}

class DayProgramReadout extends StatelessWidget {
  const DayProgramReadout({
    super.key,
    required this.day,
    required this.duration,
  });

  final String day;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    final figure = programTitle(
      context,
      colors.station,
      size: 22,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return Semantics(
      liveRegion: true,
      label: l10n.dayReading(day, duration),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(day, style: programTitle(context, colors.ink, size: 22)),
            const SizedBox(width: 8),
            Text(duration, style: figure),
          ],
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel({
    required this.label,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final emphasized = isToday || selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected
                    ? colors.station
                    : (isToday ? colors.ink : colors.muted),
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            ColoredBox(
              color: isToday ? colors.station : Colors.transparent,
              child: const SizedBox(width: 10, height: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.fraction,
    required this.label,
    required this.fill,
    required this.selected,
    required this.onTap,
  });

  final double fraction;
  final String label;
  final Color? fill;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final height = fraction.clamp(0.0, 1.0);
    final color = fill;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: color == null
            ? const SizedBox.expand()
            : Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: height == 0 ? 0.02 : height,
                  widthFactor: 1,
                  child: ColoredBox(
                    color: color,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
      ),
    );
  }
}

class _DashedGoalPainter extends CustomPainter {
  const _DashedGoalPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dash = 5.0;
    const gap = 4.0;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedGoalPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// A met day is solid station. Reading under the goal is station at 28%.
/// An empty day, including today, stays paper. Today is marked on its label.
Color? _barFill({
  required int seconds,
  required int? goalSeconds,
  required Color station,
}) {
  if (seconds <= 0) return null;
  final met = goalSeconds != null && goalSeconds > 0 && seconds >= goalSeconds;
  if (met) return station;
  return station.withValues(alpha: 0.28);
}

int? _todayIndex(List<DailyReading> days, DateTime today) {
  for (var index = 0; index < days.length; index++) {
    if (_sameDay(days[index].day, today)) return index;
  }
  return null;
}

double _chartScale({required int goalSeconds, required int peakSeconds}) {
  final top = goalSeconds > peakSeconds ? goalSeconds : peakSeconds;
  if (top <= 0) return 1;
  return top * 1.15;
}

bool _sameDay(DateTime day, DateTime today) {
  final current = today.toLocal();
  return day.year == current.year &&
      day.month == current.month &&
      day.day == current.day;
}
