---
title: Avoid Unnecessary Widget Rebuilds
impact: CRITICAL
impactDescription: Prevents wasted CPU cycles
tags: build, setState, performance, optimization
---

## Avoid Unnecessary Widget Rebuilds

**Impact: CRITICAL (prevents wasted computation)**

Don't call `setState()` when data hasn't actually changed. Avoid creating objects in build methods.

**Incorrect (rebuilds even when value unchanged):**

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String name = '';

  void updateName(String newName) {
    // Always rebuilds, even if name is the same
    setState(() {
      name = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Creates new object every build!
    final decoration = BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    );

    return Container(
      decoration: decoration,
      child: Text(name),
    );
  }
}
```

**Correct (only rebuilds when needed):**

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String name = '';

  // Cache decoration as static const
  static const _decoration = BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  void updateName(String newName) {
    // Only rebuild if value actually changed
    if (name != newName) {
      setState(() {
        name = newName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration,  // Reused
      child: Text(name),
    );
  }
}
```

**Other patterns to avoid:**

```dart
// BAD: Creating callbacks in build
onPressed: () => handlePress()

// GOOD: Reference method directly
onPressed: handlePress

// BAD: Creating lists in build
children: [Widget1(), Widget2()]

// GOOD: Use const
children: const [Widget1(), Widget2()]
```

Reference: [Flutter setState Documentation](https://api.flutter.dev/flutter/widgets/State/setState.html)
