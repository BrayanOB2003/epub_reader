import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:flutter/material.dart';

const weekdayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

class WeeklyReadingChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final peak = days.fold<int>(
      0,
      (highest, day) =>
          day.engagedSeconds > highest ? day.engagedSeconds : highest,
    );
    final goal = goalSeconds;
    final scale = _chartScale(goalSeconds: goal ?? 0, peakSeconds: peak);
    final goalFraction = goal == null || goal <= 0 ? null : goal / scale;
    final lineColor = color.onSurface;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Esta semana', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (goalFraction != null) ...[
                  CustomPaint(
                    size: const Size(22, 10),
                    painter: _DashedGoalPainter(color: lineColor),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Meta · ${formatReadingDuration(goal!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 148,
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final day in days)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: _DayBar(
                              fraction: day.engagedSeconds / scale,
                              label:
                                  '${weekdayLabels[day.day.weekday - 1]}, ${formatReadingDuration(day.engagedSeconds)}',
                              filled: day.engagedSeconds > 0,
                              isToday: _sameDay(day.day, today),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (goalFraction != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 148 * goalFraction - 1,
                      height: 2,
                      child: CustomPaint(
                        painter: _DashedGoalPainter(color: lineColor),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final day in days)
                  Expanded(
                    child: Text(
                      weekdayLabels[day.day.weekday - 1],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _sameDay(day.day, today)
                            ? color.primary
                            : color.onSurfaceVariant,
                        fontWeight: _sameDay(day.day, today)
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
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
    required this.filled,
    required this.isToday,
  });

  final double fraction;
  final String label;
  final bool filled;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final height = fraction.clamp(0.0, 1.0);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: color.primary.withValues(alpha: 0.45))
              : null,
        ),
        child: filled
            ? Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: height == 0 ? 0.02 : height,
                  widthFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              )
            : const SizedBox.expand(),
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
