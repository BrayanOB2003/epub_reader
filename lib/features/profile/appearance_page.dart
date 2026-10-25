import 'package:epub_reader/app/app_font_store.dart';
import 'package:epub_reader/app/app_theme_store.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected =
        ref.watch(appThemeProvider).asData?.value ?? AppThemeId.programa;
    final selectedFont =
        ref.watch(appFontProvider).asData?.value ?? AppFontId.sistema;
    final saved = ref.watch(readerProfileProvider).asData?.value;
    final period = saved == null ? null : ReadingRoutine.byId(saved.routine);
    final hour = saved?.routineHour;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleDetailTitle(
              title: l10n.appearance,
              onBack: () => context.pop(),
            ),
            SizedBox(
              width: double.infinity,
              child: ScheduleListing(
                title: period?.label(l10n) ?? l10n.readingHabit,
                subtitle: saved == null
                    ? null
                    : l10n.minutes(saved.dailyGoalMinutes),
                leading: hour == null ? null : readingHourLabel(hour),
                onAir: true,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final id in AppThemeId.values)
                    _ThemeChoice(
                      id: id,
                      label: themeLabel(l10n, id),
                      selected: id == selected,
                      onTap: () => _selectTheme(context, ref, id),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n.appFont,
                        style: programTitle(
                          context,
                          ScheduleColors.of(context).ink,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _FontChoice.stripHeight,
                    child: ListView.separated(
                      primary: false,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: AppFontId.values.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final id = AppFontId.values[index];
                        return _FontChoice(
                          key: ValueKey(id),
                          id: id,
                          themeId: selected,
                          label: fontLabel(l10n, id),
                          selected: id == selectedFont,
                          onTap: () => _selectFont(context, ref, id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const ScheduleRule(),
            ScheduleAction(
              label: l10n.appearanceRestore,
              onPressed: _isDefault(selected, selectedFont)
                  ? null
                  : () => _restore(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTheme(
    BuildContext context,
    WidgetRef ref,
    AppThemeId id,
  ) async {
    final current = ref.read(appThemeProvider).asData?.value;
    if (current == id) return;
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).themeChangeFailed;
    try {
      await ref.read(appThemeProvider.notifier).select(id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  Future<void> _selectFont(
    BuildContext context,
    WidgetRef ref,
    AppFontId id,
  ) async {
    final current = ref.read(appFontProvider).asData?.value;
    if (current == id) return;
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).fontChangeFailed;
    try {
      await ref.read(appFontProvider.notifier).select(id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).appearanceRestoreFailed;
    final theme = ref.read(appThemeProvider).asData?.value;
    final font = ref.read(appFontProvider).asData?.value;
    try {
      if (theme != AppThemeId.programa) {
        await ref.read(appThemeProvider.notifier).select(AppThemeId.programa);
      }
      if (font != AppFontId.sistema) {
        await ref.read(appFontProvider.notifier).select(AppFontId.sistema);
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }
}

bool _isDefault(AppThemeId theme, AppFontId font) {
  return theme == AppThemeId.programa && font == AppFontId.sistema;
}

String themeLabel(AppLocalizations l10n, AppThemeId id) {
  return switch (id) {
    AppThemeId.programa => l10n.themePrograma,
    AppThemeId.libro => l10n.themeLibro,
    AppThemeId.cuaderno => l10n.themeCuaderno,
    AppThemeId.periodico => l10n.themePeriodico,
    AppThemeId.ficha => l10n.themeFicha,
  };
}

TextStyle themeChoiceStyle(
  ScheduleLook look,
  Color color,
  TargetPlatform platform, {
  double size = 22,
}) {
  final family =
      look.titleFamily ??
      switch (platform) {
        TargetPlatform.iOS || TargetPlatform.macOS => 'CupertinoSystemText',
        _ => 'Roboto',
      };
  return lookTitle(look, color, size: size).copyWith(
    inherit: false,
    fontFamily: family,
    fontFamilyFallback: const ['CupertinoSystemText', 'Roboto'],
  );
}

String fontLabel(AppLocalizations l10n, AppFontId id) {
  return switch (id) {
    AppFontId.sistema => l10n.fontSystem,
    AppFontId.sourceSans => l10n.fontSourceSans,
    AppFontId.libreFranklin => l10n.fontLibreFranklin,
    AppFontId.sourceSerif => l10n.fontSourceSerif,
    AppFontId.newsreader => l10n.fontNewsreader,
  };
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId id;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final brightness = Theme.of(context).brightness;
    final palette = scheduleColors(id, brightness);
    final look = ScheduleLook.forTheme(id);
    final radius = BorderRadius.circular(look.radius);
    return Column(
      children: [
        Semantics(
          button: true,
          selected: selected,
          label: label,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _ThemeSpecimen(
                      look: look,
                      palette: palette,
                      radius: radius,
                      initial: label.isEmpty ? '' : label[0],
                      selected: selected,
                      borderColor: selected ? palette.station : colors.rule,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        label,
                        style: themeChoiceStyle(
                          look,
                          selected ? colors.ink : colors.muted,
                          Theme.of(context).platform,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? CupertinoIcons.check_mark
                            : Icons.check,
                        color: colors.station,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ColoredBox(
          color: colors.rule,
          child: const SizedBox(height: 1, width: double.infinity),
        ),
      ],
    );
  }
}

class _ThemeSpecimen extends StatelessWidget {
  const _ThemeSpecimen({
    required this.look,
    required this.palette,
    required this.radius,
    required this.initial,
    required this.selected,
    required this.borderColor,
  });

  final ScheduleLook look;
  final ScheduleColors palette;
  final BorderRadius radius;
  final String initial;
  final bool selected;
  final Color borderColor;

  static const width = 64.0;
  static const height = 86.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.paper,
          border: Border.all(color: borderColor),
          borderRadius: radius,
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    initial,
                    style: themeChoiceStyle(
                      look,
                      palette.ink,
                      Theme.of(context).platform,
                      size: 32,
                    ),
                  ),
                ),
              ),
              ColoredBox(
                color: palette.station,
                child: SizedBox(height: selected ? 14 : 10, width: width),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontChoice extends StatelessWidget {
  const _FontChoice({
    required this.id,
    required this.themeId,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final AppFontId id;
  final AppThemeId themeId;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const width = 128.0;
  static const cardHeight = 120.0;
  static const stripHeight = 176.0;

  @override
  Widget build(BuildContext context) {
    final palette = scheduleColors(themeId, Theme.of(context).brightness);
    final radius = BorderRadius.circular(ScheduleLook.forTheme(themeId).radius);
    final family = id.previewFamily(Theme.of(context).platform);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: radius,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.paper,
                    border: Border.all(
                      color: selected ? palette.station : palette.rule,
                    ),
                    borderRadius: radius,
                  ),
                  child: SizedBox(
                    width: width,
                    height: cardHeight,
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Aa',
                              style: TextStyle(
                                fontFamily: family,
                                fontFamilyFallback: const [
                                  'CupertinoSystemText',
                                  'Roboto',
                                ],
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                                height: 1,
                                color: selected ? palette.ink : palette.muted,
                              ),
                            ),
                          ),
                        ),
                        ColoredBox(
                          color: palette.station,
                          child: SizedBox(
                            height: selected ? 14 : 8,
                            width: width,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: family,
                  fontFamilyFallback: const ['CupertinoSystemText', 'Roboto'],
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? palette.ink : palette.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
