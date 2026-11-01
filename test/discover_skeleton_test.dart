import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/discover/discover_skeleton.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the catalog skeleton runs an ink press', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_app());
    await tester.pump();

    expect(find.byType(DiscoverSkeleton), findsOneWidget);
    expect(find.bySemanticsLabel('Cargando el catálogo'), findsOneWidget);
    expect(tester.hasRunningAnimations, isTrue);

    final first = await _pressPixels(tester);
    await tester.pump(const Duration(milliseconds: 400));
    final second = await _pressPixels(tester);
    expect(first, isNot(equals(second)));
  });

  testWidgets('the catalog skeleton stays still when motion is off', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_app(disableAnimations: true));
    await tester.pump();

    expect(find.byType(DiscoverSkeleton), findsOneWidget);
    expect(find.byType(ShaderMask), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

Widget _app({bool disableAnimations = false}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: scheduleTheme(Brightness.light),
    home: Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: const Scaffold(body: DiscoverSkeleton()),
        );
      },
    ),
  );
}

Future<List<int>> _pressPixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.descendant(
      of: find.byType(DiscoverSkeleton),
      matching: find.byType(RepaintBoundary),
    ),
  );
  final image = await tester.runAsync(boundary.toImage);
  final bytes = await tester.runAsync(() => image!.toByteData());
  return bytes!.buffer.asUint8List();
}
