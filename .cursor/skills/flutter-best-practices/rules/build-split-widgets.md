---
title: Split Large Widgets into Smaller Ones
impact: CRITICAL
impactDescription: Reduces rebuild scope
tags: build, widgets, architecture, performance
---

## Split Large Widgets into Smaller Ones

**Impact: CRITICAL (reduces rebuild scope)**

Break large widgets into smaller, focused widgets. When state changes, only the widget that uses that state rebuilds.

**Incorrect (entire widget rebuilds on counter change):**

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: Column(
        children: [
          // These all rebuild when counter changes!
          const ExpensiveHeader(),
          const ExpensiveList(),
          Text('Counter: $counter'),
          ElevatedButton(
            onPressed: () => setState(() => counter++),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
```

**Correct (only counter widget rebuilds):**

```dart
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: const Column(
        children: [
          ExpensiveHeader(),  // Never rebuilds
          ExpensiveList(),    // Never rebuilds
          CounterWidget(),    // Only this rebuilds
        ],
      ),
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

Reference: [Flutter Performance - Controlling Build Cost](https://docs.flutter.dev/perf/best-practices#controlling-build-cost)
