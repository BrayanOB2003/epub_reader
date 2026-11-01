import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Seven day letters. On a narrow phone the row scrolls so each target
/// stays at least 44 wide and 48 tall.
class ReadingDayRow extends StatelessWidget {
  const ReadingDayRow({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<ReadingWeekday> selected;
  final ValueChanged<ReadingWeekday> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 44.0;
        const gap = 6.0;
        final count = ReadingWeekday.values.length;
        final needed = count * minWidth + (count - 1) * gap;
        final scroll = constraints.maxWidth < needed;
        final row = Row(
          children: [
            for (var index = 0; index < count; index++) ...[
              if (index > 0) const SizedBox(width: gap),
              _cell(
                context,
                day: ReadingWeekday.values[index],
                expanded: !scroll,
              ),
            ],
          ],
        );
        if (!scroll) return row;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: row,
        );
      },
    );
  }

  Widget _cell(
    BuildContext context, {
    required ReadingWeekday day,
    required bool expanded,
  }) {
    final l10n = AppLocalizations.of(context);
    final letter = _DayLetter(
      letter: day.letter(l10n),
      label: day.label(l10n),
      selected: selected.contains(day),
      onTap: () => onToggle(day),
    );
    if (!expanded) return SizedBox(width: 44, child: letter);
    return Expanded(child: letter);
  }
}

class _DayLetter extends StatelessWidget {
  const _DayLetter({
    required this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final ink = selected ? typeOnStation(context) : colors.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? colors.station : colors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: scheduleRadius(context),
          side: BorderSide(color: selected ? colors.station : colors.rule),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                letter,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReadingHourWrap extends StatelessWidget {
  const ReadingHourWrap({
    required this.hours,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<int> hours;
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final hour in hours)
          _HourChip(
            label: readingHourLabel(hour),
            selected: selected == hour,
            onTap: () => onSelected(hour),
          ),
      ],
    );
  }
}

class _HourChip extends StatelessWidget {
  const _HourChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final ink = selected ? typeOnStation(context) : colors.ink;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.station : colors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: scheduleRadius(context),
          side: BorderSide(color: selected ? colors.station : colors.rule),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
