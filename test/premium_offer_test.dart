import 'dart:async';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/premium/premium_controller.dart';
import 'package:epub_reader/features/premium/premium_gateway.dart';
import 'package:epub_reader/features/premium/premium_keys.dart';
import 'package:epub_reader/features/profile/premium_offer.dart';
import 'package:epub_reader/features/profile/profile_page.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:epub_reader/l10n/app_localizations_es.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// A store that answers from memory.
class FakeGateway implements PremiumGateway {
  FakeGateway({
    this.owned = false,
    this.storePrice = '6,99 US\$',
    this.buyOutcome = PremiumOutcome.unlocked,
    this.restoreOutcome = PremiumOutcome.nothingToRestore,
    this.offline = false,
  });

  bool owned;
  final String storePrice;
  final PremiumOutcome buyOutcome;
  final PremiumOutcome restoreOutcome;
  final bool offline;
  final _unlocked = StreamController<bool>.broadcast();
  int buys = 0;
  int restores = 0;

  @override
  Stream<bool> get unlocked => _unlocked.stream;

  @override
  Future<void> start() async {
    if (offline) throw StateError('no store');
    _unlocked.add(owned);
  }

  @override
  Future<String?> price() async => storePrice;

  @override
  Future<PremiumOutcome> buy() async {
    buys++;
    return buyOutcome;
  }

  @override
  Future<PremiumOutcome> restore() async {
    restores++;
    return restoreOutcome;
  }
}

const _monthLead =
    'El mes que cerraste: los días del plan, el tiempo y los libros.';

GoRouter _router() {
  return GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(
        path: '/profile',
        builder: (_, _) => const ProfilePage(),
        routes: [
          GoRoute(path: 'premium', builder: (_, _) => const PremiumPage()),
        ],
      ),
    ],
  );
}

Future<void> _pump(
  WidgetTester tester,
  FakeGateway gateway, {
  String start = '/profile',
}) async {
  // Tall enough that the lazy list builds every section.
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = _router();
  addTearDown(router.dispose);
  if (start != '/profile') router.go(start);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        premiumGatewayProvider.overrideWithValue(gateway),
        readerProfileProvider.overrideWith((ref) => Stream.value(null)),
        savedQuotesProvider.overrideWith((ref) => Stream.value(const [])),
        readingSessionsProvider.overrideWith((ref) => Stream.value(const [])),
        sampleSessionCountProvider.overrideWith((ref) => Stream.value(0)),
        quoteHighlightDefaultProvider.overrideWith((ref) => 'amber'),
      ],
      child: MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: scheduleTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('premium is a profile row that opens the offer', (tester) async {
    await _pump(tester, FakeGateway());

    expect(find.widgetWithText(ListTile, 'Premium'), findsOneWidget);
    expect(find.text('6,99 US\$'), findsOneWidget);
    expect(find.text('Un pago abre las tres.'), findsOneWidget);
    expect(find.text(_monthLead), findsNothing);

    await tester.tap(find.widgetWithText(ListTile, 'Premium'));
    await tester.pumpAndSettle();

    expect(find.text(_monthLead), findsOneWidget);
    expect(
      find.text(
        'El tiempo de cada libro, aparte de la semana y el calendario.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('El papel, la tinta y la letra con la que se lee Liora.'),
      findsOneWidget,
    );
    expect(find.text('Potencia tu hábito de lectura'), findsOneWidget);
    expect(find.text('Un solo pago.'), findsOneWidget);
    expect(find.text('Desbloquear · 6,99 US\$'), findsOneWidget);
    expect(find.text('Restaurar compra'), findsOneWidget);
  });

  testWidgets('buying unlocks the page and shows the active note', (
    tester,
  ) async {
    final gateway = FakeGateway();
    await _pump(tester, gateway, start: '/profile/premium');

    await tester.tap(find.text('Desbloquear · 6,99 US\$'));
    await tester.pumpAndSettle();

    expect(gateway.buys, 1);
    expect(find.text('Desbloquear · 6,99 US\$'), findsNothing);
    expect(find.text('Restaurar compra'), findsNothing);
    expect(find.text('Activo'), findsOneWidget);
  });

  testWidgets('a cancelled purchase leaves the page quiet', (tester) async {
    final gateway = FakeGateway(buyOutcome: PremiumOutcome.cancelled);
    await _pump(tester, gateway, start: '/profile/premium');

    await tester.tap(find.text('Desbloquear · 6,99 US\$'));
    await tester.pumpAndSettle();

    expect(gateway.buys, 1);
    expect(find.text('Desbloquear · 6,99 US\$'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('a failed purchase says so', (tester) async {
    final gateway = FakeGateway(buyOutcome: PremiumOutcome.failed);
    await _pump(tester, gateway, start: '/profile/premium');

    await tester.tap(find.text('Desbloquear · 6,99 US\$'));
    await tester.pumpAndSettle();

    expect(
      find.text(AppLocalizationsEs().premiumPurchaseFailed),
      findsOneWidget,
    );
  });

  testWidgets('restore with nothing to restore says so', (tester) async {
    final gateway = FakeGateway();
    await _pump(tester, gateway, start: '/profile/premium');

    await tester.tap(find.text('Restaurar compra'));
    await tester.pumpAndSettle();

    expect(gateway.restores, 1);
    expect(
      find.text(AppLocalizationsEs().premiumNothingToRestore),
      findsOneWidget,
    );
  });

  testWidgets('restore finds the purchase and unlocks', (tester) async {
    final gateway = FakeGateway(restoreOutcome: PremiumOutcome.unlocked);
    await _pump(tester, gateway, start: '/profile/premium');

    await tester.tap(find.text('Restaurar compra'));
    await tester.pumpAndSettle();

    expect(find.text('Activo'), findsOneWidget);
  });

  testWidgets('an owner sees the three sections in the profile', (
    tester,
  ) async {
    await _pump(tester, FakeGateway(owned: true));

    expect(find.text('Activo'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Apariencia'), findsOneWidget);
    expect(find.text('Un pago abre las tres.'), findsNothing);
  });

  group('premiumRedirect', () {
    test('sends a free reader from a premium page to the offer', () {
      for (final location in [
        '/profile/month',
        '/profile/appearance',
        '/time/books',
        '/time/books/42',
      ]) {
        expect(
          premiumRedirect(location: location, unlocked: false),
          '/profile/premium',
          reason: location,
        );
      }
    });

    test('lets owners and unknown state through', () {
      expect(premiumRedirect(location: '/profile/month', unlocked: true), null);
      expect(premiumRedirect(location: '/profile/month', unlocked: null), null);
    });

    test('ignores the free pages', () {
      expect(premiumRedirect(location: '/profile', unlocked: false), null);
      expect(
        premiumRedirect(location: '/profile/premium', unlocked: false),
        null,
      );
      expect(premiumRedirect(location: '/time', unlocked: false), null);
    });
  });

  group('premium controller', () {
    test('a device without a store counts as not bought', () async {
      final container = ProviderContainer(
        overrides: [
          premiumGatewayProvider.overrideWithValue(FakeGateway(offline: true)),
        ],
      );
      addTearDown(container.dispose);
      container.read(premiumProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(premiumProvider).unlocked, false);
    });

    test('follows the store and loads the price', () async {
      final container = ProviderContainer(
        overrides: [
          premiumGatewayProvider.overrideWithValue(FakeGateway(owned: true)),
        ],
      );
      addTearDown(container.dispose);
      container.read(premiumProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(premiumProvider);
      expect(state.unlocked, true);
      expect(state.price, '6,99 US\$');
    });
  });

  group('envValue', () {
    const raw =
        '# keys\nX_EPUB_KEY: abc\nREVENUECAT_KEY_IOS=appl_1\n'
        'REVENUECAT_KEY_ANDROID : goog_2 \nEMPTY:\n';

    test('reads colon and equals files', () {
      expect(envValue(raw, 'X_EPUB_KEY'), 'abc');
      expect(envValue(raw, revenueCatIosKeyName), 'appl_1');
      expect(envValue(raw, revenueCatAndroidKeyName), 'goog_2');
    });

    test('is null for missing or empty names', () {
      expect(envValue(raw, 'NOPE'), null);
      expect(envValue(raw, 'EMPTY'), null);
    });
  });
}
