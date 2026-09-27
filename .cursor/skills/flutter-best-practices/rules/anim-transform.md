---
title: Use Transform Instead of Container for Animations
impact: MEDIUM
impactDescription: Avoids layout recalculation
tags: animation, transform, performance, layout
---

## Use Transform Instead of Container for Animations

**Impact: MEDIUM (avoids layout during animation)**

Use `Transform` widget for position, scale, and rotation animations. It applies changes at paint time, avoiding expensive layout recalculations.

**Incorrect (triggers layout on every frame):**

```dart
AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    return Container(
      margin: EdgeInsets.only(left: _animation.value * 100),
      child: child,
    );
  },
  child: const MyWidget(),
)
```

**Correct (only affects paint, no layout):**

```dart
AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(_animation.value * 100, 0),
      child: child,
    );
  },
  child: const MyWidget(),
)
```

**Common Transform patterns:**

```dart
// Scale animation
Transform.scale(
  scale: _scaleAnimation.value,
  child: child,
)

// Rotation animation
Transform.rotate(
  angle: _rotationAnimation.value,
  child: child,
)

// Combined transforms
Transform(
  transform: Matrix4.identity()
    ..translate(_offsetAnimation.value.dx, _offsetAnimation.value.dy)
    ..scale(_scaleAnimation.value)
    ..rotateZ(_rotationAnimation.value),
  alignment: Alignment.center,
  child: child,
)
```

**Using AnimatedBuilder efficiently:**

```dart
class AnimatedCard extends StatefulWidget {
  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // child is NOT rebuilt, only transform changes
      child: const Card(child: Text('Hello')),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_controller.value * 0.2),
          child: child,
        );
      },
    );
  }
}
```

Reference: [Transform Class](https://api.flutter.dev/flutter/widgets/Transform-class.html)
