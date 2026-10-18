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

/// Type that sits on the station band. Night station needs white to clear
/// 4.5:1; the paper tone used in the day falls short on the night band.
Color typeOnStation(BuildContext context) {
  final colors = ScheduleColors.of(context);
  if (Theme.of(context).brightness == Brightness.dark) {
    return colors.onStationMuted;
  }
  return colors.onStation;
}

const programFace = 'BarlowCondensed';

/// The five appearances. [programa] is the printed log the app shipped with.
enum AppThemeId {
  programa,
  libro,
  cuaderno,
  periodico,
  ficha;

  static AppThemeId byId(String? raw) {
    final name = raw?.trim();
    for (final id in values) {
      if (id.name == name) return id;
    }
    return programa;
  }
}

/// The interface face. Program titles stay on the appearance.
enum AppFontId {
  sistema,
  sourceSans,
  libreFranklin,
  sourceSerif,
  newsreader;

  static AppFontId byId(String? raw) {
    final name = raw?.trim();
    for (final id in values) {
      if (id.name == name) return id;
    }
    return sistema;
  }

  /// Null keeps the platform face.
  String? get family {
    return switch (this) {
      AppFontId.sistema => null,
      AppFontId.sourceSans => 'SourceSans3',
      AppFontId.libreFranklin => 'LibreFranklin',
      AppFontId.sourceSerif => 'SourceSerif4',
      AppFontId.newsreader => 'Newsreader',
    };
  }

  /// The face of this row. Sistema stays on the platform face.
  String previewFamily(TargetPlatform platform) {
    final chosen = family;
    if (chosen != null) return chosen;
    return switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 'CupertinoSystemText',
      _ => 'Roboto',
    };
  }
}

/// Title face, scale, and the radius of controls and covers.
///
/// Bands stay edge to edge. [radius] is only for buttons, choices, the minute
/// field, and cover frames.
@immutable
class ScheduleLook extends ThemeExtension<ScheduleLook> {
  const ScheduleLook({
    required this.titleFamily,
    required this.titleWeight,
    required this.titleScale,
    required this.titleHeight,
    required this.titleTracking,
    required this.radius,
  });

  /// Null uses the platform face.
  final String? titleFamily;
  final FontWeight titleWeight;
  final double titleScale;
  final double titleHeight;
  final double titleTracking;
  final double radius;

  static const programa = ScheduleLook(
    titleFamily: programFace,
    titleWeight: FontWeight.w600,
    titleScale: 1,
    titleHeight: 0.95,
    titleTracking: -0.02,
    radius: 0,
  );

  static const libro = ScheduleLook(
    titleFamily: 'SourceSerif4',
    titleWeight: FontWeight.w600,
    titleScale: 0.92,
    titleHeight: 1.15,
    titleTracking: 0,
    radius: 0,
  );

  static const cuaderno = ScheduleLook(
    titleFamily: null,
    titleWeight: FontWeight.w600,
    titleScale: 0.9,
    titleHeight: 1.15,
    titleTracking: 0,
    radius: 8,
  );

  static const periodico = programa;

  static const ficha = ScheduleLook(
    titleFamily: 'RobotoSlab',
    titleWeight: FontWeight.w600,
    titleScale: 0.86,
    titleHeight: 1.15,
    titleTracking: 0,
    radius: 0,
  );

  static ScheduleLook of(BuildContext context) {
    return Theme.of(context).extension<ScheduleLook>() ?? programa;
  }

  static ScheduleLook forTheme(AppThemeId id) {
    return switch (id) {
      AppThemeId.programa => programa,
      AppThemeId.libro => libro,
      AppThemeId.cuaderno => cuaderno,
      AppThemeId.periodico => periodico,
      AppThemeId.ficha => ficha,
    };
  }

  @override
  ScheduleLook copyWith({
    String? titleFamily,
    FontWeight? titleWeight,
    double? titleScale,
    double? titleHeight,
    double? titleTracking,
    double? radius,
  }) {
    return ScheduleLook(
      titleFamily: titleFamily ?? this.titleFamily,
      titleWeight: titleWeight ?? this.titleWeight,
      titleScale: titleScale ?? this.titleScale,
      titleHeight: titleHeight ?? this.titleHeight,
      titleTracking: titleTracking ?? this.titleTracking,
      radius: radius ?? this.radius,
    );
  }

  @override
  ScheduleLook lerp(ScheduleLook? other, double t) {
    if (other == null) return this;
    if (t < 0.5) return this;
    return other;
  }
}

const _libroLight = ScheduleColors(
  paper: Color(0xFFF6F1E8),
  ink: Color(0xFF2C2416),
  muted: Color(0xFF6B5E4E),
  rule: Color(0xFFE4D9C8),
  station: Color(0xFF8C3D2F),
  onStation: Color(0xFFF6F1E8),
  onStationMuted: Color(0xFFF3D2C6),
);

const _libroDark = ScheduleColors(
  paper: Color(0xFF1C1712),
  ink: Color(0xFFF6F1E8),
  muted: Color(0xFFC9B8A6),
  rule: Color(0xFF3C322A),
  station: Color(0xFFAA5644),
  onStation: Color(0xFFF6F1E8),
  onStationMuted: Color(0xFFFFF4EE),
);

const _cuadernoLight = ScheduleColors(
  paper: Color(0xFFF4F5F1),
  ink: Color(0xFF1C1F1A),
  muted: Color(0xFF5C6158),
  rule: Color(0xFFD9DDD4),
  station: Color(0xFF234E43),
  onStation: Color(0xFFF4F5F1),
  onStationMuted: Color(0xFFD5E4DC),
);

const _cuadernoDark = ScheduleColors(
  paper: Color(0xFF141614),
  ink: Color(0xFFF4F5F1),
  muted: Color(0xFFC5CBC0),
  rule: Color(0xFF2E3530),
  station: Color(0xFF3C7A68),
  onStation: Color(0xFFF4F5F1),
  onStationMuted: Color(0xFFEAF6F0),
);

const _periodicoLight = ScheduleColors(
  paper: Color(0xFFEFECE4),
  ink: Color(0xFF1A1814),
  muted: Color(0xFF5E584E),
  rule: Color(0xFFD2CDC2),
  station: Color(0xFF8F1D2C),
  onStation: Color(0xFFF7F4EC),
  onStationMuted: Color(0xFFF6D4D8),
);

const _periodicoDark = ScheduleColors(
  paper: Color(0xFF141311),
  ink: Color(0xFFF3F0E8),
  muted: Color(0xFFC8C2B6),
  rule: Color(0xFF3A342C),
  station: Color(0xFFB44A56),
  onStation: Color(0xFFF7F4EC),
  onStationMuted: Color(0xFFFFF1F2),
);

const _fichaLight = ScheduleColors(
  paper: Color(0xFFF3F0E8),
  ink: Color(0xFF1C1916),
  muted: Color(0xFF5C564E),
  rule: Color(0xFFDDD6CC),
  station: Color(0xFF2C2824),
  onStation: Color(0xFFF3F0E8),
  onStationMuted: Color(0xFFD4CFC6),
);

const _fichaDark = ScheduleColors(
  paper: Color(0xFF161513),
  ink: Color(0xFFF3F0E8),
  muted: Color(0xFFC8C2B6),
  rule: Color(0xFF3A3630),
  station: Color(0xFF746C62),
  onStation: Color(0xFFF3F0E8),
  onStationMuted: Color(0xFFF7F4EE),
);

ScheduleColors scheduleColors(AppThemeId id, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return switch (id) {
    AppThemeId.programa => dark ? ScheduleColors.dark : ScheduleColors.light,
    AppThemeId.libro => dark ? _libroDark : _libroLight,
    AppThemeId.cuaderno => dark ? _cuadernoDark : _cuadernoLight,
    AppThemeId.periodico => dark ? _periodicoDark : _periodicoLight,
    AppThemeId.ficha => dark ? _fichaDark : _fichaLight,
  };
}

BorderRadius scheduleRadius(BuildContext context) {
  return BorderRadius.circular(ScheduleLook.of(context).radius);
}

TextStyle lookTitle(ScheduleLook look, Color color, {double size = 40}) {
  final scaled = size * look.titleScale;
  return TextStyle(
    fontFamily: look.titleFamily,
    fontWeight: look.titleWeight,
    fontSize: scaled,
    height: look.titleHeight,
    letterSpacing: scaled * look.titleTracking,
    color: color,
  );
}

TextStyle programTitle(BuildContext context, Color color, {double size = 40}) {
  return lookTitle(ScheduleLook.of(context), color, size: size);
}

ThemeData scheduleTheme(
  Brightness brightness, [
  AppThemeId id = AppThemeId.programa,
  AppFontId font = AppFontId.sistema,
]) {
  final colors = scheduleColors(id, brightness);
  final look = ScheduleLook.forTheme(id);
  final family = font.family;
  final fallback = family == null
      ? null
      : const <String>['CupertinoSystemText', 'Roboto'];
  final scheme =
      ColorScheme.fromSeed(
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
    extensions: [colors, look],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: colors.ink,
      displayColor: colors.ink,
      fontFamily: family,
      fontFamilyFallback: fallback,
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
        TextStyle(
          fontSize: 12,
          color: colors.ink,
          fontFamily: family,
          fontFamilyFallback: fallback,
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(look.radius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colors.station),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.ink,
      contentTextStyle: TextStyle(
        color: colors.paper,
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
    ),
  );
}
