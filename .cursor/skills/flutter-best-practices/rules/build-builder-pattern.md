---
title: Use Builder Pattern for Context Access
impact: MEDIUM
impactDescription: Gets correct BuildContext in callbacks
tags: build, builder, context, widgets
---

## Use Builder Pattern for Context Access

**Impact: MEDIUM (prevents context bugs)**

Use `Builder` widget when you need a BuildContext that's a descendant of a widget being built in the same method.

**Incorrect (wrong context for SnackBar):**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          // This context is ABOVE Scaffold, no ScaffoldMessenger!
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hello')),
          );
        },
        child: const Text('Show SnackBar'),
      ),
    );
  }
}
```

**Correct (using Builder for correct context):**

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (scaffoldContext) {
          // scaffoldContext is BELOW Scaffold
          return ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                const SnackBar(content: Text('Hello')),
              );
            },
            child: const Text('Show SnackBar'),
          );
        },
      ),
    );
  }
}
```

**Alternative: Split into separate widget:**

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyButton(),  // Separate widget has correct context
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hello')),
        );
      },
      child: const Text('Show SnackBar'),
    );
  }
}
```

Reference: [Flutter Builder Class](https://api.flutter.dev/flutter/widgets/Builder-class.html)
