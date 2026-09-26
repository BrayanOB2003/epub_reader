import 'package:epub_reader/app/app_shell.dart';
import 'package:epub_reader/features/discover/discover_page.dart';
import 'package:epub_reader/features/habits/reading_time_page.dart';
import 'package:epub_reader/features/library/home_page.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/onboarding/onboarding_page.dart';
import 'package:epub_reader/features/reader/reader_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _OnboardingRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen(onboardingControllerProvider, (_, _) => refresh.bump());

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
      return onboardingRedirect(
        completed: completed,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/library'),
      GoRoute(path: '/boot', builder: (context, state) => const _BootPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
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
        ],
      ),
      GoRoute(
        path: '/read/:bookId',
        builder: (context, state) {
          final bookId = int.tryParse(state.pathParameters['bookId'] ?? '');
          if (bookId == null) {
            return const Scaffold(
              body: Center(child: Text('Libro no válido.')),
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
