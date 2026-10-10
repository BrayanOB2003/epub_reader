import 'package:drift/drift.dart' hide Column, isNull;
import 'package:drift/native.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/focus/focus_binding.dart';
import 'package:epub_reader/features/focus/focus_guide_page.dart';
import 'package:epub_reader/features/focus/focus_mode.dart';
import 'package:epub_reader/features/focus/focus_session.dart';
import 'package:epub_reader/features/profile/profile_page.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('focus holds while the app is in front', () {
    expect(
      focusShouldHold(enabled: false, lifecycle: AppLifecycleState.resumed),
      isFalse,
    );
    expect(
      focusShouldHold(enabled: true, lifecycle: AppLifecycleState.resumed),
      isTrue,
    );
    expect(
      focusShouldHold(enabled: true, lifecycle: AppLifecycleState.inactive),
      isTrue,
    );
    expect(focusShouldHold(enabled: true, lifecycle: null), isTrue);
    expect(
      focusShouldHold(enabled: true, lifecycle: AppLifecycleState.paused),
      isFalse,
    );
    expect(
      focusShouldHold(enabled: true, lifecycle: AppLifecycleState.hidden),
      isFalse,
    );
    expect(
      focusShouldHold(enabled: true, lifecycle: AppLifecycleState.detached),
      isFalse,
    );
  });

  test('a session enables once and releases when the app leaves', () {
    final session = FocusSession();
    expect(session.next(shouldHold: false), isNull);

    expect(session.next(shouldHold: true), FocusAction.enable);
    session.commit(FocusAction.enable);
    expect(session.next(shouldHold: true), isNull);

    expect(session.next(shouldHold: false), FocusAction.disable);
    session.commit(FocusAction.disable);
    expect(session.next(shouldHold: false), isNull);
    expect(session.next(shouldHold: true), FocusAction.enable);
  });

  testWidgets('Android focus silences the phone only while Liora is open', (
    tester,
  ) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel(focusModeChannelName),
      (call) async {
        calls.add(call.method);
        return true;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(focusModeChannelName),
        null,
      );
    });

    final database = await _profileDatabase();
    await tester.pumpWidget(_profileApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(calls, containsAllInOrder(['hasAccess', 'enable']));
    expect(
      (await database.select(database.readerProfiles).getSingle()).focusMode,
      isTrue,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(calls, containsAllInOrder(['enable', 'disable']));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(calls.last, 'enable');
    await _unmount(tester);
  });

  testWidgets('Android focus stays off when access is denied', (tester) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel(focusModeChannelName),
      (call) async {
        calls.add(call.method);
        return call.method == 'openSettings';
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(focusModeChannelName),
        null,
      );
    });

    final database = await _profileDatabase();
    await tester.pumpWidget(_profileApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(calls, contains('openSettings'));
    expect(
      (await database.select(database.readerProfiles).getSingle()).focusMode,
      isFalse,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(calls, isNot(contains('enable')));
    expect(find.textContaining('acceso a No molestar'), findsOneWidget);
    expect(
      (await database.select(database.readerProfiles).getSingle()).focusMode,
      isFalse,
    );
    await _unmount(tester);
  });

  testWidgets(
    'iOS focus turns on only after the Shortcuts guide is confirmed',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final database = await _profileDatabase();
        final router = GoRouter(
          initialLocation: '/profile',
          routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
            GoRoute(path: '/focus', builder: (_, _) => const FocusGuidePage()),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWith((ref) {
                ref.onDispose(database.close);
                return database;
              }),
            ],
            child: MaterialApp.router(
              locale: const Locale('es'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(find.text('No molestar al leer'), findsOneWidget);
        expect(find.text('Al abrir Liora'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('Al cerrar Liora'), 200);
        expect(find.text('Al cerrar Liora'), findsOneWidget);
        expect(find.textContaining('Definir concentración'), findsOneWidget);
        expect(
          (await database.select(database.readerProfiles).getSingle())
              .focusMode,
          isFalse,
        );

        await tester.tap(find.text('Listo'));
        await tester.pumpAndSettle();

        expect(find.text('Modo concentración'), findsOneWidget);
        expect(
          (await database.select(database.readerProfiles).getSingle())
              .focusMode,
          isTrue,
        );
        await _unmount(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

Future<AppDatabase> _profileDatabase() async {
  final database = AppDatabase(NativeDatabase.memory());
  await database
      .into(database.readerProfiles)
      .insert(
        ReaderProfilesCompanion.insert(
          motivations: 'habit',
          dailyGoalMinutes: 10,
          routine: 'night',
          routineHour: const Value(21),
          routineDays: const Value('1,2,3,4,5,6,7'),
          completedAt: DateTime.utc(2026, 10, 9),
        ),
      );
  return database;
}

Widget _profileApp(AppDatabase database) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWith((ref) {
        ref.onDispose(database.close);
        return database;
      }),
    ],
    child: const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FocusBinding(child: ProfilePage()),
    ),
  );
}
