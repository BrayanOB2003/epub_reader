import 'package:epub_reader/app/app_shell.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/analytics/app_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:epub_reader/features/discover/discover_page.dart';
import 'package:epub_reader/features/focus/focus_guide_page.dart';
import 'package:epub_reader/features/habits/reading_time_page.dart';
import 'package:epub_reader/features/library/home_page.dart';
import 'package:epub_reader/features/notifications/notification_permission_page.dart';
import 'package:epub_reader/features/notifications/notification_prompt.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/onboarding/onboarding_page.dart';
import 'package:epub_reader/features/profile/profile_page.dart';
import 'package:epub_reader/features/profile/quotes_page.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/reader/reader_page.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _OnboardingRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen(onboardingControllerProvider, (_, _) => refresh.bump());
  ref.listen(readerProfileProvider, (_, _) => refresh.bump());
  ref.listen(notificationPermissionGrantedProvider, (_, _) => refresh.bump());
  ref.listen(notificationPromptShownProvider, (_, _) => refresh.bump());

  final router = GoRouter(
    initialLocation: '/library',
    refreshListenable: refresh,
    observers: [
      if (firebaseReady)
        FirebaseAnalyticsObserver(
          analytics: FirebaseAnalytics.instance,
          nameExtractor: analyticsScreenName,
        ),
    ],
    redirect: (context, state) {
      final status = ref.read(onboardingControllerProvider);
      final bool? completed = status.isLoading
          ? null
          : status.hasError
          ? false
          : status.value ?? false;
      final location = state.matchedLocation;
      final profile = ref.read(readerProfileProvider);
      if (completed == true &&
          !profile.hasError &&
          (profile.isLoading || !profile.hasValue)) {
        if (location == '/boot' || location == '/notifications') return null;
        return '/boot';
      }
      final granted = ref.read(notificationPermissionGrantedProvider);
      if (completed == true && granted == null) {
        if (location == '/boot' || location == '/notifications') return null;
        return '/boot';
      }
      final shown =
          ref.read(notificationPromptShownProvider) ??
          profile.asData?.value?.notificationPromptSkippedOn;
      final due = notificationPromptDue(
        permissionGranted: granted,
        shownOn: shown,
        now: DateTime.now(),
      );
      return onboardingRedirect(
        completed: completed,
        location: location,
        editing: state.uri.queryParameters['editar'] == '1',
        notificationPromptDue: due,
      );
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/library'),
      GoRoute(
        path: '/boot',
        name: 'boot',
        builder: (context, state) => const _BootPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => OnboardingRoute(
          editing: state.uri.queryParameters['editar'] == '1',
        ),
      ),
      GoRoute(
        path: '/focus',
        name: 'focus',
        builder: (context, state) => const FocusGuidePage(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => NotificationPermissionPage(
          returnLocation: state.uri.queryParameters['volver'],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                name: 'discover',
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                name: 'library',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/time',
                name: 'time',
                builder: (context, state) => const ReadingTimePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/quotes',
        name: 'quotes',
        builder: (context, state) => const QuotesPage(),
      ),
      GoRoute(
        path: '/read/:bookId',
        name: 'read',
        builder: (context, state) {
          final bookId = int.tryParse(state.pathParameters['bookId'] ?? '');
          if (bookId == null) {
            return Scaffold(
              body: Center(
                child: Text(AppLocalizations.of(context).invalidBook),
              ),
            );
          }
          return ReaderPage(
            bookId: bookId,
            source: readingSessionSource(state.uri.queryParameters['origen']),
            quoteId: int.tryParse(state.uri.queryParameters['cita'] ?? ''),
          );
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _OnboardingRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}

class _BootPage extends StatelessWidget {
  const _BootPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
