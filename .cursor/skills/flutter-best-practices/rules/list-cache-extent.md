---
title: Configure cacheExtent Appropriately
impact: MEDIUM
impactDescription: Balance between smoothness and memory
tags: list, cache, scrolling, memory
---

## Configure cacheExtent Appropriately

**Impact: MEDIUM (smoothness vs memory trade-off)**

Adjust `cacheExtent` to control how many off-screen items are kept in memory. Default is 250 logical pixels.

**Default behavior:**

```dart
ListView.builder(
  // Default cacheExtent is 250 pixels
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)
```

**Increased cache for smoother scrolling:**

```dart
ListView.builder(
  cacheExtent: 500,  // More items cached, smoother fast scroll
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)
```

**Reduced cache for memory-constrained scenarios:**

```dart
ListView.builder(
  cacheExtent: 100,  // Fewer items cached, less memory
  itemCount: items.length,
  itemBuilder: (context, index) => HeavyItemWidget(item: items[index]),
)
```

**When to increase cacheExtent:**
- Fast scrolling causes blank areas
- Items are lightweight
- Device has plenty of memory

**When to decrease cacheExtent:**
- Items are memory-heavy (images, complex widgets)
- List is very long
- Device is memory-constrained

**Debugging:**

```dart
// Visualize what's in cache
ListView.builder(
  cacheExtent: 500,
  itemCount: items.length,
  itemBuilder: (context, index) {
    debugPrint('Building item $index');  // See what's being built
    return ItemWidget(item: items[index]);
  },
)
```

Reference: [ScrollView cacheExtent](https://api.flutter.dev/flutter/widgets/ScrollView/cacheExtent.html)
