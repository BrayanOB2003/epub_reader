import 'package:epub_reader/app/router.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubReaderApp extends ConsumerWidget {
  const EpubReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Liora',
      theme: scheduleTheme(Brightness.light),
      darkTheme: scheduleTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        final colors = ScheduleColors.of(context);
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Theme.of(context).brightness,
            primaryColor: colors.station,
            scaffoldBackgroundColor: colors.paper,
            barBackgroundColor: colors.paper,
            textTheme: CupertinoTextThemeData(
              primaryColor: colors.station,
              textStyle: TextStyle(color: colors.ink, fontSize: 17),
              navLargeTitleTextStyle: TextStyle(
                color: colors.ink,
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
