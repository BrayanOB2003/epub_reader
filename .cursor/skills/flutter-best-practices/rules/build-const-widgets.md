---
title: Use const Constructors for Static Widgets
impact: CRITICAL
impactDescription: Prevents unnecessary widget rebuilds
tags: build, const, performance, widgets
---

## Use const Constructors for Static Widgets

**Impact: CRITICAL (prevents rebuild allocation)**

Use `const` constructors for widgets that don't depend on runtime values. This allows Flutter to reuse widget instances instead of recreating them.

**Incorrect (creates new instance on every build):**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Hello'),  // New instance every build
        Icon(Icons.star),  // New instance every build
        SizedBox(height: 16),  // New instance every build
      ],
    );
  }
}
```

**Correct (reuses widget instances):**

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Hello'),  // Reused
        Icon(Icons.star),  // Reused
        SizedBox(height: 16),  // Reused
      ],
    );
  }
}
```

**Enable lint rules:**

```yaml
# analysis_options.yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
```

**When you can't use const:**

```dart
// Can't be const - depends on runtime value
Text(user.name)

// Can't be const - uses variable
Container(color: themeColor)

// CAN be const - static value
const Text('Static text')
```

Reference: [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
