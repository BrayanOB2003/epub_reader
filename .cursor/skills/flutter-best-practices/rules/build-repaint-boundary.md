---
title: Use RepaintBoundary to Isolate Expensive Paints
impact: HIGH
impactDescription: Reduces repaint area
tags: build, repaint, painting, performance
---

## Use RepaintBoundary to Isolate Expensive Paints

**Impact: HIGH (reduces repaint cost)**

Wrap widgets that paint frequently or expensively with `RepaintBoundary` to isolate their repaints from the rest of the tree.

**When to use RepaintBoundary:**

```dart
// 1. Animated widgets
RepaintBoundary(
  child: AnimatedWidget(),
)

// 2. Complex custom painters
RepaintBoundary(
  child: CustomPaint(
    painter: ComplexChartPainter(),
  ),
)

// 3. Video or image galleries
RepaintBoundary(
  child: VideoPlayer(),
)
```

**Example with animation:**

```dart
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Isolate animated background from static content
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),
        ),
        // Static content won't repaint when background animates
        const Center(
          child: Text('Hello World'),
        ),
      ],
    );
  }
}
```

**Debug repaints:**

```dart
// In main.dart
import 'package:flutter/rendering.dart';

void main() {
  debugRepaintRainbowEnabled = true;  // Shows repaint areas
  runApp(const MyApp());
}
```

Reference: [Flutter RepaintBoundary](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html)
