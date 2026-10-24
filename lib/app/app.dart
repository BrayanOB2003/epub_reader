import 'package:epub_reader/app/app_font_store.dart';
import 'package:epub_reader/app/app_locale.dart';
import 'package:epub_reader/app/app_theme_store.dart';
import 'package:epub_reader/app/router.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/focus/focus_binding.dart';
import 'package:epub_reader/features/library/opened_epub.dart';
import 'package:epub_reader/features/notifications/notification_binding.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubReaderApp extends ConsumerWidget {
  const EpubReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final themeId =
        ref.watch(appThemeProvider).asData?.value ?? AppThemeId.programa;
    final fontId =
        ref.watch(appFontProvider).asData?.value ?? AppFontId.sistema;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Liora',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: scheduleTheme(Brightness.light, themeId, fontId),
      darkTheme: scheduleTheme(Brightness.dark, themeId, fontId),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        final colors = ScheduleColors.of(context);
        return OpenedEpubBinding(
          child: NotificationBinding(
            child: FocusBinding(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Theme.of(context).brightness,
                  primaryColor: colors.station,
                  scaffoldBackgroundColor: colors.paper,
                  barBackgroundColor: colors.paper,
                  textTheme: _cupertinoText(colors, fontId),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}

CupertinoTextThemeData _cupertinoText(ScheduleColors colors, AppFontId font) {
  final family = font.family;
  const fallback = ['CupertinoSystemText', 'Roboto'];
  return CupertinoTextThemeData(
    primaryColor: colors.station,
    textStyle: TextStyle(color: colors.ink, fontSize: 17, fontFamily: family),
    navLargeTitleTextStyle: TextStyle(
      color: colors.ink,
      fontSize: 34,
      fontWeight: FontWeight.w700,
      fontFamily: family,
    ),
    actionTextStyle: family == null
        ? null
        : TextStyle(
            inherit: false,
            fontFamily: family,
            fontFamilyFallback: fallback,
            fontSize: 17,
            letterSpacing: -0.41,
            decoration: TextDecoration.none,
            color: colors.station,
          ),
    tabLabelTextStyle: family == null
        ? null
        : TextStyle(
            inherit: false,
            fontFamily: family,
            fontFamilyFallback: fallback,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.24,
          ),
  );
}
