import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const scheduleWeekdays = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

const scheduleMonths = [
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

String scheduleDate(DateTime day) {
  final local = day.toLocal();
  final weekday = scheduleWeekdays[local.weekday - 1];
  final month = scheduleMonths[local.month - 1];
  return '$weekday ${local.day} de $month';
}

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({required this.title, this.date, super.key});

  final String title;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: ios ? 34 : 28,
              fontWeight: FontWeight.w700,
              height: 1.05,
              color: colors.ink,
            ),
          ),
          if (date != null) ...[
            const SizedBox(height: 8),
            Text(
              scheduleDate(date!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ScheduleRule extends StatelessWidget {
  const ScheduleRule({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ScheduleColors.of(context).rule,
      child: const SizedBox(height: 1, width: double.infinity),
    );
  }
}

/// A row in the log. [onAir] paints the station band. No card.
class ScheduleListing extends StatelessWidget {
  const ScheduleListing({
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.onAir = false,
    this.rule = true,
    this.titleSize = 22,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final String? leading;
  final VoidCallback? onTap;
  final bool onAir;
  final bool rule;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final ink = onAir ? colors.onStation : colors.ink;
    final muted = onAir ? colors.onStationMuted : colors.muted;
    final child = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null)
              SizedBox(
                width: 64,
                child: Text(
                  leading!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: programTitle(ink, size: titleSize),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: muted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              Text(
                trailing!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ink,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return ColoredBox(
      color: onAir ? colors.station : colors.paper,
      child: Column(
        children: [
          if (onTap == null)
            child
          else
            Semantics(
              button: true,
              child: InkWell(onTap: onTap, child: child),
            ),
          if (rule) const ScheduleRule(),
        ],
      ),
    );
  }
}

class ScheduleAction extends StatelessWidget {
  const ScheduleAction({
    required this.label,
    required this.onPressed,
    this.onAir = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool onAir;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    final background = onAir ? colors.onStation : colors.station;
    final foreground = onAir ? colors.station : colors.onStation;
    if (ios) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: onPressed == null ? colors.rule : background,
          borderRadius: BorderRadius.zero,
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              color: onPressed == null ? colors.muted : foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: colors.rule,
          disabledForegroundColor: colors.muted,
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(label),
      ),
    );
  }
}
