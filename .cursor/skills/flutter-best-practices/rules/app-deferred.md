---
title: Use Deferred Loading for Features
impact: MEDIUM
impactDescription: Faster initial load, smaller initial bundle
tags: app, deferred, loading, bundle
---

## Use Deferred Loading for Features

**Impact: MEDIUM (faster initial load)**

Use Dart's deferred loading to split your app into smaller chunks that load on demand.

**Basic deferred import:**

```dart
import 'package:myapp/features/analytics/analytics.dart' deferred as analytics;

class MyApp extends StatelessWidget {
  Future<void> loadAnalytics() async {
    await analytics.loadLibrary();
    analytics.trackEvent('page_view');
  }
}
```

**With loading indicator:**

```dart
import 'package:myapp/features/settings/settings_screen.dart' deferred as settings;

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Show loading while feature loads
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await settings.loadLibrary();

        if (context.mounted) {
          Navigator.pop(context);  // Dismiss loading
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => settings.SettingsScreen(),
            ),
          );
        }
      },
      child: const Text('Settings'),
    );
  }
}
```

**Preload features in background:**

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Preload features user might need soon
    _preloadFeatures();
  }

  Future<void> _preloadFeatures() async {
    await Future.delayed(const Duration(seconds: 2));
    // Load in background after app starts
    await settings.loadLibrary();
    await analytics.loadLibrary();
  }
}
```

**Best candidates for deferred loading:**
- Settings screens
- Admin/debug features
- Onboarding flows (after first use)
- Heavy visualization libraries
- Features behind feature flags

Reference: [Deferred Components](https://docs.flutter.dev/perf/deferred-components)
