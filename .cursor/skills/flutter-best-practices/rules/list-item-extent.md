---
title: Specify itemExtent for Fixed-Height Items
impact: CRITICAL
impactDescription: Skips layout calculation, 2-3× faster scrolling
tags: list, itemExtent, layout, performance
---

## Specify itemExtent for Fixed-Height Items

**Impact: CRITICAL (2-3× faster scrolling)**

When all list items have the same height, specify `itemExtent` to skip expensive layout calculations.

**Incorrect (measures each item):**

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return SizedBox(
      height: 72,  // Flutter still measures each item!
      child: ListTile(title: Text(items[index].name)),
    );
  },
)
```

**Correct (skips measurement):**

```dart
ListView.builder(
  itemCount: items.length,
  itemExtent: 72,  // Flutter knows exact size, no measurement needed
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index].name));
  },
)
```

**Alternative: prototypeItem:**

```dart
ListView.builder(
  itemCount: items.length,
  prototypeItem: const ListTile(
    title: Text('Prototype'),  // Measures this once, uses for all
  ),
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index].name));
  },
)
```

**For Slivers:**

```dart
CustomScrollView(
  slivers: [
    SliverFixedExtentList(
      itemExtent: 72,
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text(items[index].name)),
        childCount: items.length,
      ),
    ),
  ],
)
```

Reference: [ListView itemExtent](https://api.flutter.dev/flutter/widgets/ListView/itemExtent.html)
