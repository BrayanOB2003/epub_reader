import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/reader/contents.dart';
import 'package:epub_reader/features/reader/contents_dialog.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_test/flutter_test.dart';

Link _link(String href, {String? title, List<Link> children = const []}) {
  return Link(href: href, title: title, children: children);
}

List<ContentsNode> _tree(List<Link> links) {
  return contentsTree(tableOfContents: links, readingOrder: const []);
}

void main() {
  test('a navigation document wins over the reading order', () {
    final tree = contentsTree(
      tableOfContents: [_link('nav.xhtml', title: 'Nav')],
      readingOrder: [_link('spine.xhtml', title: 'Lomo')],
    );

    expect(tree.single.link.title, 'Nav');
  });

  test('an empty navigation document falls back to the reading order', () {
    final tree = contentsTree(
      tableOfContents: const [],
      readingOrder: [_link('spine.xhtml', title: 'Lomo')],
    );

    expect(tree.single.link.href, 'spine.xhtml');
  });

  test('a blank title becomes the chapter place', () {
    final tree = _tree([_link('a.xhtml', title: '  '), _link('b.xhtml')]);

    expect(
      contentsTitle(
        tree[1],
        untitled: 'Sin título',
        chapter: (position) => 'Capítulo $position',
      ),
      'Capítulo 2',
    );
  });

  test('the current place ignores fragments and file prefixes', () {
    expect(contentsHrefMatches('c1.xhtml', 'c1.xhtml#p3'), isTrue);
    expect(contentsHrefMatches('c1.xhtml', 'file:///books/c1.xhtml'), isTrue);
    expect(contentsHrefMatches('c1.xhtml', 'c2.xhtml'), isFalse);

    final tree = _tree([
      _link(
        'part.xhtml',
        title: 'Parte',
        children: [_link('c1.xhtml', title: 'Uno')],
      ),
    ]);
    final current = currentContentsNode(tree, 'file:///books/c1.xhtml#p3');

    expect(current?.link.title, 'Uno');
    expect(expandedContents(tree, current), {1});
  });

  test('children stay folded until their part is open', () {
    final tree = _tree([
      _link(
        'part.xhtml',
        title: 'Parte',
        children: [_link('c1.xhtml', title: 'Capítulo único')],
      ),
    ]);

    expect(
      visibleContents(
        roots: tree,
        expanded: const {},
        query: '',
        titleOf: (node) => node.link.title ?? '',
      ).map((node) => node.link.title),
      ['Parte'],
    );
    expect(
      visibleContents(
        roots: tree,
        expanded: const {},
        query: 'capitulo',
        titleOf: (node) => node.link.title ?? '',
      ).map((node) => node.link.title),
      ['Parte', 'Capítulo único'],
    );
  });

  test('scroll offset follows the row index', () {
    final tree = _tree([
      for (var i = 1; i <= 4; i++) _link('c$i.xhtml', title: 'Tema $i'),
    ]);

    expect(contentsScrollOffset(tree, tree[3].position), 144);
    expect(contentsShowsSearch(tree), isFalse);
    expect(
      contentsShowsSearch(
        _tree([
          for (var i = 1; i <= 13; i++) _link('c$i.xhtml', title: 'Tema $i'),
        ]),
      ),
      isTrue,
    );
  });

  testWidgets('the current chapter is on air and the list opens there', (
    tester,
  ) async {
    final tree = _tree([
      for (var i = 1; i <= 20; i++) _link('c$i.xhtml', title: 'Tema $i'),
    ]);
    await _open(tester, roots: tree, currentHref: 'c20.xhtml');

    expect(find.text('Atrás'), findsOneWidget);
    expect(find.text('Cerrar'), findsNothing);
    final row = tester.getRect(find.text('Tema 20'));
    final list = tester.getRect(find.byType(ListView));
    expect(row.top, greaterThanOrEqualTo(list.top - 1));
    expect(row.bottom, lessThanOrEqualTo(list.bottom + 1));
    final materials = tester.widgetList<Material>(find.byType(Material));
    expect(
      materials.any(
        (material) => material.color == ScheduleColors.light.station,
      ),
      isTrue,
    );
  });

  testWidgets('a part stays closed until its chapters are shown', (
    tester,
  ) async {
    await _open(
      tester,
      roots: _tree([
        _link(
          'part.xhtml',
          title: 'Parte I',
          children: [_link('c.xhtml', title: 'Dentro')],
        ),
      ]),
    );

    expect(find.text('Dentro'), findsNothing);
    await tester.tap(find.byTooltip('Mostrar capítulos'));
    await tester.pumpAndSettle();
    expect(find.text('Dentro'), findsOneWidget);
  });

  testWidgets('the chapter in progress starts with its part open', (
    tester,
  ) async {
    await _open(
      tester,
      roots: _tree([
        _link(
          'part.xhtml',
          title: 'Parte I',
          children: [_link('c.xhtml', title: 'Dentro')],
        ),
      ]),
      currentHref: 'c.xhtml',
    );

    expect(find.text('Dentro'), findsOneWidget);
  });

  testWidgets('search appears only for a long index', (tester) async {
    await _open(
      tester,
      roots: _tree([
        for (var i = 1; i <= 3; i++) _link('c$i.xhtml', title: 'Tema $i'),
      ]),
    );
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    await _open(
      tester,
      roots: _tree([
        for (var i = 1; i <= 13; i++) _link('c$i.xhtml', title: 'Tema $i'),
      ]),
    );
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Tema 13');
    await tester.pump();
    expect(find.text('Tema 13'), findsNWidgets(2));
    expect(find.text('Tema 2'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();
    expect(find.text('Ningún capítulo coincide.'), findsOneWidget);
  });

  testWidgets('a failed jump stays in the index and can be retried', (
    tester,
  ) async {
    var calls = 0;
    await _open(
      tester,
      roots: _tree([_link('a.xhtml', title: 'Uno')]),
      onOpen: (_) async {
        calls++;
        return calls > 1;
      },
    );

    await tester.tap(find.text('Uno'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo abrir «Uno».'), findsOneWidget);
    expect(find.text('Índice'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Índice'), findsNothing);
    expect(calls, 2);
  });

  testWidgets('an empty book says to keep turning pages', (tester) async {
    await _open(tester, roots: const []);

    expect(find.text('Este libro no tiene índice.'), findsOneWidget);
    expect(find.text('Puedes seguir pasando páginas.'), findsOneWidget);
    expect(find.text('Atrás'), findsOneWidget);
  });
}

Future<void> _open(
  WidgetTester tester, {
  required List<ContentsNode> roots,
  String? currentHref,
  Future<bool> Function(Link link)? onOpen,
}) async {
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
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => ContentsDialog(
                    roots: roots,
                    currentHref: currentHref,
                    onOpen: onOpen ?? (_) async => false,
                  ),
                );
              },
              child: const Text('abrir'),
            );
          },
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}
