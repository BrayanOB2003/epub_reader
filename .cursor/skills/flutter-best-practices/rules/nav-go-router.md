---
title: Use GoRouter for Declarative Routing
impact: HIGH
impactDescription: Type-safe, deep linking support
tags: navigation, gorouter, routing, architecture
---

## Use GoRouter for Declarative Routing

**Impact: HIGH (type-safe, deep linking, web support)**

Use GoRouter for declarative, type-safe routing with built-in deep linking support.

**Installation:**

```yaml
dependencies:
  go_router: ^13.0.0
```

**Basic setup:**

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailsScreen(id: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

// In MaterialApp
MaterialApp.router(
  routerConfig: router,
)
```

**Navigation:**

```dart
// Push
context.push('/details/123');

// Replace
context.pushReplacement('/home');

// Go (replace entire stack)
context.go('/login');

// Pop
context.pop();

// With extra data
context.push('/details/123', extra: myObject);
```

**Shell routes (nested navigation):**

```dart
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
```

**Redirect for auth:**

```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authService.isLoggedIn;
    final isOnLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (isLoggedIn && isOnLogin) return '/';
    return null;
  },
  routes: [...],
);
```

Reference: [GoRouter Package](https://pub.dev/packages/go_router)
