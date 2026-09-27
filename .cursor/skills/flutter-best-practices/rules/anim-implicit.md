---
title: Prefer Implicit Animations When Possible
impact: MEDIUM
impactDescription: Less code, automatic optimization
tags: animation, implicit, animated, performance
---

## Prefer Implicit Animations When Possible

**Impact: MEDIUM (simpler code, automatic optimization)**

Use implicit animation widgets (`AnimatedContainer`, `AnimatedOpacity`, etc.) instead of explicit animations when you only need to animate between two states.

**Incorrect (explicit animation for simple transition):**

```dart
class FadeWidget extends StatefulWidget {
  final bool visible;
  const FadeWidget({required this.visible, super.key});

  @override
  State<FadeWidget> createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(FadeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Text('Hello'),
    );
  }
}
```

**Correct (implicit animation):**

```dart
class FadeWidget extends StatelessWidget {
  final bool visible;
  const FadeWidget({required this.visible, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: const Text('Hello'),
    );
  }
}
```

**Common implicit animation widgets:**

```dart
// Size changes
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  width: expanded ? 200 : 100,
  height: expanded ? 200 : 100,
  color: selected ? Colors.blue : Colors.grey,
)

// Position changes
AnimatedPositioned(
  duration: const Duration(milliseconds: 300),
  left: selected ? 100 : 0,
  child: child,
)

// Padding changes
AnimatedPadding(
  duration: const Duration(milliseconds: 300),
  padding: EdgeInsets.all(expanded ? 20 : 8),
  child: child,
)

// Cross-fade between widgets
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: Text(message, key: ValueKey(message)),
)
```

Reference: [Implicit Animations](https://docs.flutter.dev/ui/animations/implicit-animations)
