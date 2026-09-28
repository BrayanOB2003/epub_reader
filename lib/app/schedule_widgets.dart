import 'dart:typed_data';

import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
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

const _englishWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
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

const _englishMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String scheduleDate(DateTime day, String languageCode) {
  final local = day.toLocal();
  if (languageCode == 'en') {
    final weekday = _englishWeekdays[local.weekday - 1];
    final month = _englishMonths[local.month - 1];
    return '$weekday, $month ${local.day}';
  }
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
              scheduleDate(date!, Localizations.localeOf(context).languageCode),
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: colors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// The book as an object. The frame keeps its size when the file has no cover.
class ScheduleCover extends StatelessWidget {
  const ScheduleCover({
    required this.bytes,
    required this.width,
    required this.height,
    this.borderColor,
    this.title = '',
    this.onAir = false,
    super.key,
  });

  final Uint8List bytes;
  final double width;
  final double height;
  final Color? borderColor;
  final String title;
  final bool onAir;

  @override
  Widget build(BuildContext context) {
    if (bytes.isEmpty) {
      return ScheduleCoverPlaceholder(
        width: width,
        height: height,
        title: title,
        borderColor: borderColor,
        onAir: onAir,
      );
    }
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return _CoverFrame(
      width: width,
      height: height,
      borderColor: borderColor ?? ScheduleColors.of(context).rule,
      child: Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        cacheWidth: (width * ratio).round(),
        cacheHeight: (height * ratio).round(),
        excludeFromSemantics: true,
      ),
    );
  }
}

class ScheduleCoverPlaceholder extends StatelessWidget {
  const ScheduleCoverPlaceholder({
    required this.width,
    required this.height,
    required this.title,
    this.borderColor,
    this.onAir = false,
    super.key,
  });

  final double width;
  final double height;
  final String title;
  final Color? borderColor;
  final bool onAir;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final border = borderColor ?? colors.rule;
    final fill = onAir
        ? colors.onStation.withValues(alpha: 0.16)
        : colors.paper;
    final ink = onAir ? colors.onStation : colors.ink;
    final initial = coverInitial(title);
    return _CoverFrame(
      width: width,
      height: height,
      borderColor: border,
      child: ColoredBox(
        color: fill,
        child: initial.isEmpty
            ? null
            : ExcludeSemantics(
                child: Center(
                  child: Text(
                    initial,
                    maxLines: 1,
                    style: programTitle(ink, size: height * 0.46),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CoverFrame extends StatelessWidget {
  const _CoverFrame({
    required this.width,
    required this.height,
    required this.borderColor,
    required this.child,
  });

  final double width;
  final double height;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: borderColor)),
        child: child,
      ),
    );
  }
}

class _NetworkCover extends StatefulWidget {
  const _NetworkCover({
    required this.url,
    required this.width,
    required this.height,
    required this.title,
  });

  final String url;
  final double width;
  final double height;
  final String title;

  @override
  State<_NetworkCover> createState() => _NetworkCoverState();
}

class _NetworkCoverState extends State<_NetworkCover> {
  var _failed = false;

  @override
  void didUpdateWidget(_NetworkCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _failed = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || widget.url.isEmpty) {
      return ScheduleCoverPlaceholder(
        width: widget.width,
        height: widget.height,
        title: widget.title,
      );
    }
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return _CoverFrame(
      width: widget.width,
      height: widget.height,
      borderColor: ScheduleColors.of(context).rule,
      child: Image.network(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        cacheWidth: (widget.width * ratio).round(),
        cacheHeight: (widget.height * ratio).round(),
        excludeFromSemantics: true,
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_failed) setState(() => _failed = true);
          });
          return const SizedBox.shrink();
        },
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
    this.caption,
    this.trailing,
    this.leading,
    this.cover,
    this.coverUrl,
    this.coverWidth = 36,
    this.coverHeight = 52,
    this.onTap,
    this.onDelete,
    this.onAir = false,
    this.rule = true,
    this.titleSize = 22,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? caption;
  final String? trailing;
  final String? leading;
  final Uint8List? cover;
  final String? coverUrl;
  final double coverWidth;
  final double coverHeight;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool onAir;
  final bool rule;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final ink = onAir ? colors.onStation : colors.ink;
    final muted = onAir ? colors.onStationMuted : colors.muted;
    final coverBytes = cover;
    final hasBytes = coverBytes != null && coverBytes.isNotEmpty;
    final url = coverUrl;
    final child = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            if (hasBytes)
              ScheduleCover(
                bytes: coverBytes,
                width: coverWidth,
                height: coverHeight,
              )
            else if (url != null && url.isNotEmpty)
              _NetworkCover(
                url: url,
                width: coverWidth,
                height: coverHeight,
                title: title,
              )
            else
              ScheduleCoverPlaceholder(
                width: coverWidth,
                height: coverHeight,
                title: title,
              ),
            const SizedBox(width: 12),
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
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (caption != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      caption!,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null || onDelete != null) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trailing != null)
                    Text(
                      trailing!,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: ink),
                    ),
                  if (onDelete != null)
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        foregroundColor: muted,
                        minimumSize: const Size(44, 44),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: Text(AppLocalizations.of(context).delete),
                    ),
                ],
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

final _letter = RegExp(r'^\p{L}$', unicode: true);
final _number = RegExp(r'^\p{N}$', unicode: true);

String coverInitial(String title) {
  for (final rune in title.trim().runes) {
    final char = String.fromCharCode(rune);
    if (_letter.hasMatch(char) || _number.hasMatch(char)) {
      return char.toUpperCase();
    }
  }
  return '';
}
