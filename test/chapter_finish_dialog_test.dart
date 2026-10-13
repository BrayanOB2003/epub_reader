import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/reader/chapter_finish_dialog.dart';
import 'package:epub_reader/features/reader/contents.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the locator title names the chapter, then the index', () {
    final roots = contentsTree(
      tableOfContents: [
        Link(
          href: 'part.xhtml',
          title: 'Parte',
          children: [Link(href: 'c2.xhtml', title: 'El jardín')],
        ),
      ],
      readingOrder: const [],
    );

    expect(
      finishChapterTitle(
        locatorTitle: 'Desde el lector',
        roots: roots,
        href: 'c2.xhtml',
        untitled: 'Sin título',
        chapter: (position) => 'Capítulo $position',
      ),
      'Desde el lector',
    );
    expect(
      finishChapterTitle(
        locatorTitle: '  ',
        roots: roots,
        href: 'c2.xhtml#p3',
        untitled: 'Sin título',
        chapter: (position) => 'Capítulo $position',
      ),
      'El jardín',
    );
    expect(
      finishChapterTitle(
        locatorTitle: null,
        roots: contentsTree(
          tableOfContents: [Link(href: 'c1.xhtml')],
          readingOrder: const [],
        ),
        href: 'c1.xhtml',
        untitled: 'Sin título',
        chapter: (position) => 'Capítulo $position',
      ),
      'Capítulo 1',
    );
  });

  testWidgets('staying is the filled action and leaving is one tap', (
    tester,
  ) async {
    final outcome = await _ask(tester, minutes: 5, chapterTitle: 'El jardín');

    expect(find.text('¿Sigues un poco más?'), findsOneWidget);
    expect(
      find.text('Te faltan unos 5 min para acabar «El jardín».'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('Seguir leyendo'), findsOneWidget);
    expect(find.text('Salir'), findsOneWidget);

    await tester.tap(find.text('Seguir leyendo'));
    await tester.pumpAndSettle();
    expect(outcome(), 'sigue');
  });

  testWidgets('leaving closes the offer', (tester) async {
    final outcome = await _ask(tester, minutes: 1);

    expect(
      find.text('Te falta un minuto para acabar el capítulo.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
    expect(outcome(), 'sale');
  });
}

Future<String Function()> _ask(
  WidgetTester tester, {
  required int minutes,
  String? chapterTitle,
}) async {
  final result = ValueNotifier<String>('abierto');
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: scheduleTheme(Brightness.light),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                final leave = await showDialog<bool>(
                  context: context,
                  builder: (context) => ChapterFinishDialog(
                    minutes: minutes,
                    chapterTitle: chapterTitle,
                  ),
                );
                result.value = leave == true ? 'sale' : 'sigue';
              },
              child: const Text('cerrar'),
            );
          },
        ),
      ),
    ),
  );
  await tester.tap(find.text('cerrar'));
  await tester.pumpAndSettle();
  return () => result.value;
}
