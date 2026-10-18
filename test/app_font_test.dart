import 'dart:io';

import 'package:epub_reader/app/app_font_store.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an unknown font id stays on the system face', () {
    expect(AppFontId.byId(null), AppFontId.sistema);
    expect(AppFontId.byId(' '), AppFontId.sistema);
    expect(AppFontId.byId('sourceSans'), AppFontId.sourceSans);
  });

  test('a chosen face replaces interface type and leaves program titles', () {
    final themed = scheduleTheme(
      Brightness.light,
      AppThemeId.programa,
      AppFontId.sourceSans,
    );
    expect(themed.textTheme.bodyLarge?.fontFamily, 'SourceSans3');
    expect(themed.textTheme.headlineMedium?.fontFamily, 'SourceSans3');
    expect(themed.textTheme.labelLarge?.fontFamily, 'SourceSans3');
    expect(themed.extension<ScheduleLook>()!.titleFamily, 'BarlowCondensed');
    expect(
      themed.navigationBarTheme.labelTextStyle?.resolve(const {})?.fontFamily,
      'SourceSans3',
    );
    expect(themed.snackBarTheme.contentTextStyle?.fontFamily, 'SourceSans3');

    final serif = scheduleTheme(
      Brightness.light,
      AppThemeId.programa,
      AppFontId.sourceSerif,
    );
    expect(serif.textTheme.bodyMedium?.fontFamily, 'SourceSerif4');
    expect(serif.extension<ScheduleLook>()!.titleFamily, 'BarlowCondensed');
    expect(
      scheduleTheme(
        Brightness.light,
        AppThemeId.libro,
        AppFontId.newsreader,
      ).extension<ScheduleLook>()!.titleFamily,
      'SourceSerif4',
    );
    expect(
      scheduleTheme(
        Brightness.light,
        AppThemeId.ficha,
        AppFontId.libreFranklin,
      ).textTheme.bodyMedium?.fontFamily,
      'LibreFranklin',
    );
  });

  test('the system face leaves the platform family in place', () {
    final family = scheduleTheme(
      Brightness.light,
    ).textTheme.bodyLarge?.fontFamily;
    expect(family, isNot('SourceSans3'));
    expect(family, isNot('LibreFranklin'));
    expect(family, isNot('Newsreader'));
    expect(family, isNot('SourceSerif4'));
  });

  test('the font choice is remembered on this device', () async {
    final dir = await Directory.systemTemp.createTemp('liora-font');
    addTearDown(() => dir.delete(recursive: true));
    final store = AppFontStore(documentsDirectory: () async => dir);
    expect(await store.read(), AppFontId.sistema);
    await store.write(AppFontId.newsreader);
    expect(await store.read(), AppFontId.newsreader);
  });
}
