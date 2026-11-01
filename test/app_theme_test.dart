import 'dart:io';

import 'package:epub_reader/app/app_theme_store.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an unknown theme id stays on the program', () {
    expect(AppThemeId.byId(null), AppThemeId.programa);
    expect(AppThemeId.byId(' '), AppThemeId.programa);
    expect(AppThemeId.byId('libro'), AppThemeId.libro);
  });

  test('each theme keeps one station and its own title face', () {
    expect(
      scheduleTheme(Brightness.light, AppThemeId.libro).colorScheme.primary,
      const Color(0xFF8C3D2F),
    );
    final notebook = scheduleTheme(Brightness.light, AppThemeId.cuaderno);
    expect(notebook.extension<ScheduleLook>()!.radius, 8);
    expect(notebook.extension<ScheduleLook>()!.titleFamily, isNull);
    expect(
      scheduleTheme(
        Brightness.light,
        AppThemeId.ficha,
      ).extension<ScheduleLook>()!.titleFamily,
      'RobotoSlab',
    );
    expect(
      scheduleTheme(Brightness.dark, AppThemeId.periodico).colorScheme.primary,
      const Color(0xFFB44A56),
    );
    expect(
      scheduleTheme(Brightness.light).extension<ScheduleLook>()!.titleFamily,
      'BarlowCondensed',
    );
  });

  test('the choice is remembered on this device', () async {
    final dir = await Directory.systemTemp.createTemp('liora-theme');
    addTearDown(() => dir.delete(recursive: true));
    final store = AppThemeStore(documentsDirectory: () async => dir);
    expect(await store.read(), AppThemeId.programa);
    await store.write(AppThemeId.cuaderno);
    expect(await store.read(), AppThemeId.cuaderno);
  });
}
