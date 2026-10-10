import 'package:epub_reader/app/app_shell.dart';
import 'package:epub_reader/features/discover/discover_page.dart';
import 'package:epub_reader/features/habits/reading_time_page.dart';
import 'package:epub_reader/features/library/home_page.dart';
import 'package:epub_reader/features/notifications/notification_permission_page.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/onboarding/onboarding_page.dart';
import 'package:epub_reader/features/profile/profile_page.dart';
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

  final router = GoRouter(
    initialLocation: '/library',
    refreshListenable: refresh,
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
      final prompted = !profile.hasValue || profile.hasError
          ? true
          : profile.requireValue?.notificationsPrompted ?? false;
      return onboardingRedirect(
        completed: completed,
        location: location,
        editing: state.uri.queryParameters['editar'] == '1',
        notificationsPrompted: prompted,
      );
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/library'),
      GoRoute(path: '/boot', builder: (context, state) => const _BootPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingRoute(
          editing: state.uri.queryParameters['editar'] == '1',
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationPermissionPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/time',
                builder: (context, state) => const ReadingTimePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/read/:bookId',
        builder: (context, state) {
          final bookId = int.tryParse(state.pathParameters['bookId'] ?? '');
          if (bookId == null) {
            return Scaffold(
              body: Center(
                child: Text(AppLocalizations.of(context).invalidBook),
              ),
            );
          }
          return ReaderPage(bookId: bookId);
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
