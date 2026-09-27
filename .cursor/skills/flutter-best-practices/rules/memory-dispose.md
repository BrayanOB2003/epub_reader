---
title: Always Dispose Controllers and Streams
impact: CRITICAL
impactDescription: Prevents memory leaks
tags: memory, dispose, controllers, streams
---

## Always Dispose Controllers and Streams

**Impact: CRITICAL (prevents memory leaks)**

Always dispose of controllers, streams, and subscriptions in the `dispose()` method to prevent memory leaks.

**Incorrect (memory leak):**

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = myStream.listen((data) {
      // handle data
    });
  }

  // Missing dispose() - MEMORY LEAK!

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}
```

**Correct (proper cleanup):**

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = myStream.listen((data) {
      // handle data
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _subscription.cancel();
    super.dispose();  // Always call super.dispose() last
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
    );
  }
}
```

**Common things to dispose:**

```dart
@override
void dispose() {
  // Controllers
  _textController.dispose();
  _scrollController.dispose();
  _pageController.dispose();
  _tabController.dispose();
  _animationController.dispose();

  // Focus nodes
  _focusNode.dispose();

  // Streams
  _subscription.cancel();
  _streamController.close();

  // Timers
  _timer?.cancel();
  _debounceTimer?.cancel();

  super.dispose();
}
```

**Using with ChangeNotifier:**

```dart
class MyNotifier extends ChangeNotifier {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

Reference: [State.dispose](https://api.flutter.dev/flutter/widgets/State/dispose.html)
