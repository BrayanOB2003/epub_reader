import 'package:flutter/material.dart';

/// The printed program log: cool paper, one station blue, hairline rules.
@immutable
class ScheduleColors extends ThemeExtension<ScheduleColors> {
  const ScheduleColors({
    required this.paper,
    required this.ink,
    required this.muted,
    required this.rule,
    required this.station,
    required this.onStation,
    required this.onStationMuted,
  });

  final Color paper;
  final Color ink;
  final Color muted;
  final Color rule;
  final Color station;
  final Color onStation;
  final Color onStationMuted;

  static const light = ScheduleColors(
    paper: Color(0xFFF4F7FB),
    ink: Color(0xFF0E1A2B),
    muted: Color(0xFF3A4C66),
    rule: Color(0xFFD5DBE3),
    station: Color(0xFF0C4DA2),
    onStation: Color(0xFFF4F7FB),
    onStationMuted: Color(0xFFD5E3F8),
  );

  static const dark = ScheduleColors(
    paper: Color(0xFF0E1A2B),
    ink: Color(0xFFF4F7FB),
    muted: Color(0xFFC5D2E6),
    rule: Color(0xFF2C3C55),
    station: Color(0xFF2F6FE0),
    onStation: Color(0xFFF4F7FB),
    onStationMuted: Color(0xFFFFFFFF),
  );

  static ScheduleColors of(BuildContext context) {
    return Theme.of(context).extension<ScheduleColors>() ?? light;
  }

  @override
  ScheduleColors copyWith({
    Color? paper,
    Color? ink,
    Color? muted,
    Color? rule,
    Color? station,
    Color? onStation,
    Color? onStationMuted,
  }) {
    return ScheduleColors(
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      rule: rule ?? this.rule,
      station: station ?? this.station,
      onStation: onStation ?? this.onStation,
      onStationMuted: onStationMuted ?? this.onStationMuted,
    );
  }

  @override
  ScheduleColors lerp(ScheduleColors? other, double t) {
    if (other == null) return this;
    return ScheduleColors(
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      station: Color.lerp(station, other.station, t)!,
      onStation: Color.lerp(onStation, other.onStation, t)!,
      onStationMuted: Color.lerp(onStationMuted, other.onStationMuted, t)!,
    );
  }
}

const programFace = 'BarlowCondensed';

TextStyle programTitle(Color color, {double size = 40}) {
  return TextStyle(
    fontFamily: programFace,
    fontWeight: FontWeight.w600,
    fontSize: size,
    height: 0.95,
    letterSpacing: size * -0.02,
    color: color,
  );
}

ThemeData scheduleTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark
      ? ScheduleColors.dark
      : ScheduleColors.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: colors.station,
    brightness: brightness,
  ).copyWith(
    primary: colors.station,
    onPrimary: colors.onStation,
    secondary: colors.station,
    onSecondary: colors.onStation,
    surface: colors.paper,
    onSurface: colors.ink,
    onSurfaceVariant: colors.muted,
    outline: colors.rule,
    outlineVariant: colors.rule,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.paper,
    dividerColor: colors.rule,
    extensions: [colors],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: colors.ink,
      displayColor: colors.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.paper,
      foregroundColor: colors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.paper,
      indicatorColor: colors.station.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.all(
        TextStyle(fontSize: 12, color: colors.ink),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? colors.station : colors.muted);
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        backgroundColor: colors.station,
        foregroundColor: colors.onStation,
        shape: const RoundedRectangleBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colors.station),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.ink,
      contentTextStyle: TextStyle(color: colors.paper),
    ),
  );
}
