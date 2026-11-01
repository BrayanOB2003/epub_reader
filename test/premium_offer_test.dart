import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/profile/premium_offer.dart';
import 'package:epub_reader/features/profile/profile_page.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('premium is a profile row that opens the offer', (tester) async {
    final router = GoRouter(
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
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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

    expect(find.widgetWithText(ListTile, 'Premium'), findsOneWidget);
    expect(find.text('7 USD'), findsOneWidget);
    expect(find.text('Un pago abre las tres.'), findsOneWidget);
    expect(
      find.text(
        'El mes que cerraste: los días del plan, el tiempo y los libros.',
      ),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(ListTile, 'Premium'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'El mes que cerraste: los días del plan, el tiempo y los libros.',
      ),
      findsOneWidget,
    );
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
    expect(find.text('Desbloquear · 7 USD'), findsOneWidget);

    await tester.tap(find.text('Desbloquear · 7 USD'));
    await tester.pump();

    expect(find.text('La compra no está disponible todavía.'), findsOneWidget);
  });
}
