# Flutter Best Practices

> Comprehensive performance optimization guide for Flutter applications.
> Contains 20 rules across 8 categories, prioritized by impact.

## Table of Contents

1. [Widget Build Optimization (CRITICAL)](#1-widget-build-optimization-critical)
2. [List & Scroll Performance (CRITICAL)](#2-list--scroll-performance-critical)
3. [State Management (HIGH)](#3-state-management-high)
4. [Image & Asset Optimization (HIGH)](#4-image--asset-optimization-high)
5. [Animation Performance (MEDIUM)](#5-animation-performance-medium)
6. [Navigation & Routing (MEDIUM)](#6-navigation--routing-medium)
7. [Memory Management (MEDIUM)](#7-memory-management-medium)
8. [App Size & Startup (LOW-MEDIUM)](#8-app-size--startup-low-medium)

---

## 1. Widget Build Optimization (CRITICAL)

### build-const-widgets: Use const Constructors

**Impact: CRITICAL (prevents rebuild allocation)**

Use `const` for static widgets to reuse instances instead of recreating them.

```dart
// Incorrect
Column(
  children: [
    Text('Hello'),  // New instance every build
    SizedBox(height: 16),
  ],
)

// Correct
const Column(
  children: [
    Text('Hello'),  // Reused
    SizedBox(height: 16),
  ],
)
```

---

### build-split-widgets: Split Large Widgets

**Impact: CRITICAL (reduces rebuild scope)**

Break large widgets into smaller ones so only changed parts rebuild.

```dart
// Incorrect - entire page rebuilds on counter change
class MyPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveHeader(),  // Rebuilds unnecessarily
        Text('Counter: $counter'),
      ],
    );
  }
}

// Correct - only CounterWidget rebuilds
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ExpensiveHeader(),  // Never rebuilds
        CounterWidget(),    // Only this rebuilds
      ],
    );
  }
}
```

---

### build-avoid-rebuild: Avoid Unnecessary Rebuilds

**Impact: CRITICAL**

Don't call `setState()` when data hasn't changed. Cache objects outside build.

```dart
// Incorrect
void updateName(String newName) {
  setState(() => name = newName);  // Always rebuilds
}

// Correct
void updateName(String newName) {
  if (name != newName) {
    setState(() => name = newName);  // Only if changed
  }
}
```

---

### build-keys: Use Keys Correctly

**Impact: HIGH (preserves state in lists)**

```dart
// Incorrect - state gets mixed up on reorder
ListView(
  children: items.map((item) => StatefulTile(title: item.name)).toList(),
)

// Correct - state stays with item
ListView(
  children: items.map((item) =>
    StatefulTile(key: ValueKey(item.id), title: item.name)
  ).toList(),
)
```

---

### build-repaint-boundary: Isolate Expensive Paints

**Impact: HIGH**

```dart
RepaintBoundary(
  child: AnimatedWidget(),  // Repaints don't affect siblings
)
```

---

## 2. List & Scroll Performance (CRITICAL)

### list-builder: Use ListView.builder

**Impact: CRITICAL (10× memory improvement)**

```dart
// Incorrect - builds all items at once
ListView(children: items.map((item) => ListTile(...)).toList())

// Correct - builds items lazily
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index].name)),
)
```

---

### list-item-extent: Specify itemExtent

**Impact: CRITICAL (2-3× faster scrolling)**

```dart
ListView.builder(
  itemCount: items.length,
  itemExtent: 72,  // Skips measurement
  itemBuilder: (context, index) => ListTile(...),
)
```

---

### list-cache-extent: Configure cacheExtent

**Impact: MEDIUM**

```dart
ListView.builder(
  cacheExtent: 500,  // More items cached, smoother scroll
  // Or reduce for heavy items:
  cacheExtent: 100,  // Less memory usage
)
```

---

### list-sliver: Use Slivers for Complex Layouts

**Impact: HIGH**

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(expandedHeight: 200, pinned: true),
    SliverList(delegate: SliverChildBuilderDelegate(...)),
    SliverGrid(gridDelegate: ..., delegate: ...),
  ],
)
```

---

## 3. State Management (HIGH)

### state-selector: Use Selector for Granular Rebuilds

**Impact: HIGH**

```dart
// Incorrect - rebuilds on any state change
final state = context.watch<AppState>();

// Correct - only rebuilds when userName changes
final userName = context.select<AppState, String>((s) => s.user.name);
```

---

### state-notifier: Prefer ValueNotifier for Simple State

**Impact: MEDIUM**

```dart
final _counter = ValueNotifier<int>(0);

ValueListenableBuilder<int>(
  valueListenable: _counter,
  builder: (context, count, child) => Text('Count: $count'),
)
```

---

## 4. Image & Asset Optimization (HIGH)

### image-cached: Use cached_network_image

**Impact: HIGH**

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

---

### image-precache: Precache Images

**Impact: MEDIUM**

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(const AssetImage('assets/logo.png'), context);
}
```

---

## 5. Animation Performance (MEDIUM)

### anim-implicit: Prefer Implicit Animations

**Impact: MEDIUM**

```dart
// Simple - use implicit animation
AnimatedOpacity(
  opacity: visible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 300),
  child: child,
)

// Complex - use explicit animation only when needed
```

---

### anim-transform: Use Transform for Animations

**Impact: MEDIUM (avoids layout during animation)**

```dart
// Incorrect - triggers layout every frame
Container(margin: EdgeInsets.only(left: animation.value * 100))

// Correct - only affects paint
Transform.translate(offset: Offset(animation.value * 100, 0), child: child)
```

---

## 6. Navigation & Routing (MEDIUM)

### nav-go-router: Use GoRouter

**Impact: HIGH**

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/details/:id', builder: (_, state) =>
      DetailsScreen(id: state.pathParameters['id']!)),
  ],
);

// Navigation
context.push('/details/123');
context.go('/login');
```

---

## 7. Memory Management (MEDIUM)

### memory-dispose: Always Dispose Controllers

**Impact: CRITICAL (prevents memory leaks)**

```dart
class _MyState extends State<MyWidget> {
  final _controller = TextEditingController();
  late StreamSubscription _subscription;

  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }
}
```

---

### memory-isolates: Use Isolates for Heavy Computation

**Impact: HIGH (keeps UI responsive)**

```dart
// Runs in separate isolate
final result = await compute(heavyComputation, data);

// heavyComputation must be top-level or static function
static String heavyComputation(List<int> data) {
  return data.map((e) => e * 2).join(',');
}
```

---

## 8. App Size & Startup (LOW-MEDIUM)

### app-tree-shake: Enable Icon Tree Shaking

**Impact: MEDIUM**

```bash
# Enabled by default in release builds
flutter build apk --release
```

---

### app-deferred: Use Deferred Loading

**Impact: MEDIUM**

```dart
import 'features/settings.dart' deferred as settings;

Future<void> openSettings() async {
  await settings.loadLibrary();
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => settings.SettingsScreen(),
  ));
}
```

---

## References

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [Provider Package](https://pub.dev/packages/provider)
- [cached_network_image Package](https://pub.dev/packages/cached_network_image)
- [Dart Isolates](https://dart.dev/language/concurrency)
