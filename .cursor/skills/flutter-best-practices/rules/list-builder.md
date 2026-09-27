---
title: Use ListView.builder for Large Lists
impact: CRITICAL
impactDescription: Lazy loading, 10× memory improvement
tags: list, listview, builder, performance
---

## Use ListView.builder for Large Lists

**Impact: CRITICAL (lazy loading, 10× memory improvement)**

Use `ListView.builder` instead of `ListView` with children for lists with many items. It builds items lazily as they scroll into view.

**Incorrect (builds all items at once):**

```dart
ListView(
  children: items.map((item) => ListTile(
    title: Text(item.name),
  )).toList(),  // Creates ALL widgets immediately!
)
```

**Correct (builds items on demand):**

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].name),
    );
  },
)
```

**With separators:**

```dart
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].name),
    );
  },
  separatorBuilder: (context, index) {
    return const Divider();
  },
)
```

**For grids:**

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ProductCard(product: items[index]);
  },
)
```

Reference: [Flutter ListView.builder](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html)
