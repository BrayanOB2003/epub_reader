import 'package:epub_reader/app/app_theme_store.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
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
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: l10n.back,
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: ListView(
                children: [
                  ScheduleHeader(title: l10n.appearance),
                  const ScheduleRule(),
                  for (final id in AppThemeId.values)
                    _ThemeChoice(
                      id: id,
                      label: themeLabel(l10n, id),
                      selected: id == selected,
                      onTap: () => _select(context, ref, id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(
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
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: radius,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette.paper,
                          border: Border.all(color: colors.rule),
                          borderRadius: radius,
                        ),
                        child: SizedBox(
                          width: 36,
                          height: 48,
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    label.isEmpty ? '' : label[0],
                                    style: lookTitle(
                                      look,
                                      palette.ink,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                              ColoredBox(
                                color: palette.station,
                                child: const SizedBox(height: 8, width: 36),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        label,
                        style: lookTitle(look, colors.ink, size: 22),
                      ),
                    ),
                    if (selected) Icon(Icons.check, color: colors.station),
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
