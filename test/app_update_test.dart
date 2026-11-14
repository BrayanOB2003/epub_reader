import 'dart:async';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/app_update/app_update.dart';
import 'package:epub_reader/features/app_update/app_version.dart';
import 'package:epub_reader/features/premium/premium_controller.dart';
import 'package:epub_reader/features/premium/premium_gateway.dart';
import 'package:epub_reader/features/profile/profile_page.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an older build has to update', () {
    expect(versionIsBelow('1.0.0+1', '1.0.0+2'), isTrue);
    expect(versionIsBelow('1.0.0+1', '2'), isTrue);
    expect(versionIsBelow('4', '1.2.0+5'), isTrue);
    expect(versionIsBelow('1.0.1+1', '1.0.0+9'), isTrue);
    expect(versionIsBelow('9', '10'), isTrue);
    expect(versionIsBelow('1', '4.0'), isTrue);
  });

  test('the same or a newer build stays', () {
    expect(versionIsBelow('1.0.0+2', '1.0.0+2'), isFalse);
    expect(versionIsBelow('1.0.0+3', '1.0.0+2'), isFalse);
    expect(versionIsBelow('1.0.0+1', '1.0.1+1'), isFalse);
    expect(versionIsBelow('1.2.0+9', '1.2.0'), isFalse);
    expect(versionIsBelow('1.0.0', '1.0.1'), isFalse);
    expect(versionIsBelow('10', '9'), isFalse);
    expect(appBuildLabel('1'), '1');
    expect(appBuildLabel(' 4 '), '4');
    expect(appBuildLabel('1.0.0'), isNull);
    expect(appBuildLabel(''), isNull);
    expect(versionIsBelow('1.0.0', ''), isFalse);
    expect(versionIsBelow('1.0.0', '   '), isFalse);
    expect(versionIsBelow(null, '5'), isFalse);
    expect(versionIsBelow('4', 'soon'), isFalse);
    expect(versionIsBelow('soon', '5'), isFalse);
  });

  test('an old build opens the store for that phone', () {
    final android = decideAppUpdate(
      installedVersion: '4',
      minimumVersion: '5',
      platform: TargetPlatform.android,
    );
    expect(android.blocked, isTrue);
    expect(android.storeUrl, Uri.parse(androidStoreUrl));

    final ios = decideAppUpdate(
      installedVersion: '4',
      minimumVersion: '5',
      platform: TargetPlatform.iOS,
    );
    expect(ios.blocked, isTrue);
    expect(ios.storeUrl, storeListingUri(TargetPlatform.iOS));

    final desktop = decideAppUpdate(
      installedVersion: '1',
      minimumVersion: '9',
      platform: TargetPlatform.macOS,
    );
    expect(desktop.blocked, isFalse);
  });

  test('a failed refresh keeps the update on screen', () async {
    final config = _FakeConfig(const AppUpdatePolicy(minimumVersion: '2'));
    final container = ProviderContainer(
      overrides: [
        installedVersionProvider.overrideWith((ref) async => '1'),
        appUpdateConfigProvider.overrideWithValue(config),
        appUpdatePlatformProvider.overrideWithValue(TargetPlatform.android),
      ],
    );
    addTearDown(container.dispose);

    final first = await container.read(appUpdateStatusProvider.future);
    expect(first.blocked, isTrue);
    expect(first.storeUrl, Uri.parse(androidStoreUrl));

    config.fail = true;
    container.invalidate(appUpdateStatusProvider);
    final kept = await container.read(appUpdateStatusProvider.future);
    expect(kept.blocked, isTrue);
    expect(config.loads, 2);

    config
      ..fail = false
      ..policy = const AppUpdatePolicy(minimumVersion: '1');
    container.invalidate(appUpdateStatusProvider);
    final cleared = await container.read(appUpdateStatusProvider.future);
    expect(cleared.blocked, isFalse);
  });

  testWidgets('profile shows the installed version', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumGatewayProvider.overrideWithValue(_Store()),
          readerProfileProvider.overrideWith((ref) => Stream.value(null)),
          savedQuotesProvider.overrideWith((ref) => Stream.value(const [])),
          sampleSessionCountProvider.overrideWith((ref) => Stream.value(0)),
          quoteHighlightDefaultProvider.overrideWith((ref) => 'amber'),
          installedVersionProvider.overrideWith((ref) async => '8'),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: scheduleTheme(Brightness.light),
          home: const ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Versión 8'), findsOneWidget);
  });

  testWidgets('the update screen sends the reader to the store', (
    tester,
  ) async {
    final url = Uri.parse(androidStoreUrl);
    Uri? opened;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appUpdateStatusProvider.overrideWith(
            (ref) async => AppUpdateStatus(blocked: true, storeUrl: url),
          ),
          storeLauncherProvider.overrideWithValue((uri) async {
            opened = uri;
            return true;
          }),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: scheduleTheme(Brightness.light),
          home: const AppUpdateGate(child: Text('Biblioteca')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Actualiza Liora'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);

    await tester.tap(find.text('Ir a la tienda'));
    await tester.pumpAndSettle();
    expect(opened, url);
  });

  testWidgets('a store that does not open keeps the update on screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appUpdateStatusProvider.overrideWith(
            (ref) async => AppUpdateStatus(
              blocked: true,
              storeUrl: Uri.parse(androidStoreUrl),
            ),
          ),
          storeLauncherProvider.overrideWithValue((uri) async => false),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: scheduleTheme(Brightness.light),
          home: const AppUpdateGate(child: Text('Biblioteca')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ir a la tienda'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo abrir la tienda.'), findsOneWidget);
    expect(find.text('Actualiza Liora'), findsOneWidget);
  });
}

class _FakeConfig implements AppUpdateConfig {
  _FakeConfig(this.policy);

  AppUpdatePolicy policy;
  var fail = false;
  var loads = 0;

  @override
  Future<AppUpdatePolicy> load() async {
    loads++;
    if (fail) throw StateError('offline');
    return policy;
  }
}

class _Store implements PremiumGateway {
  final _unlocked = StreamController<bool>.broadcast();

  @override
  Stream<bool> get unlocked => _unlocked.stream;

  @override
  Future<void> start() async {}

  @override
  Future<String?> price() async => null;

  @override
  Future<PremiumOutcome> buy() async => PremiumOutcome.unavailable;

  @override
  Future<PremiumOutcome> restore() async => PremiumOutcome.unavailable;
}
