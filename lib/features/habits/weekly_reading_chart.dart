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
  });

  final List<DailyReading> days;
  final int? goalSeconds;
  final DateTime today;

  @override
  State<WeeklyReadingChart> createState() => _WeeklyReadingChartState();
}

class _WeeklyReadingChartState extends State<WeeklyReadingChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final days = widget.days;
    final labels = weekdayLabels(Localizations.localeOf(context).languageCode);
    final color = theme.colorScheme;
    final peak = days.fold<int>(
      0,
      (highest, day) =>
          day.engagedSeconds > highest ? day.engagedSeconds : highest,
    );
    final goal = widget.goalSeconds;
    final scale = _chartScale(goalSeconds: goal ?? 0, peakSeconds: peak);
    final goalFraction = goal == null || goal <= 0 ? null : goal / scale;
    final lineColor = color.onSurface;
    final selected = _selected;
    final selectedDay =
        selected == null || selected < 0 || selected >= days.length
        ? null
        : days[selected];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.thisWeek, style: theme.textTheme.titleMedium),
              const Spacer(),
              if (goalFraction != null) ...[
                CustomPaint(
                  size: const Size(22, 10),
                  painter: _DashedGoalPainter(color: lineColor),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.goalLine(formatReadingDuration(goal!)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
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
                            filled: days[index].engagedSeconds > 0,
                            isToday: _sameDay(days[index].day, widget.today),
                            selected: selected == index,
                            onTap: () => setState(() => _selected = index),
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
                      painter: _DashedGoalPainter(color: lineColor),
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
                    emphasized:
                        selected == index ||
                        _sameDay(days[index].day, widget.today),
                    onTap: () => setState(() => _selected = index),
                  ),
                ),
            ],
          ),
          DayReadingReadout(
            text: selectedDay == null
                ? null
                : l10n.dayReading(
                    weekdayName(l10n, selectedDay.day.weekday),
                    formatReadingDuration(selectedDay.engagedSeconds),
                  ),
          ),
        ],
      ),
    );
  }
}

class DayReadingReadout extends StatelessWidget {
  const DayReadingReadout({super.key, required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final message = text;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSize(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel({
    required this.label,
    required this.emphasized,
    required this.onTap,
  });

  final String label;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: emphasized ? color.primary : color.onSurfaceVariant,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.fraction,
    required this.label,
    required this.filled,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final double fraction;
  final String label;
  final bool filled;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final height = fraction.clamp(0.0, 1.0);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isToday ? color.primary.withValues(alpha: 0.12) : null,
            border: selected
                ? Border.all(color: color.primary, width: 2)
                : null,
          ),
          child: filled
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: height == 0 ? 0.02 : height,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: color.primary),
                      child: const SizedBox.expand(),
                    ),
                  ),
                )
              : const SizedBox.expand(),
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
