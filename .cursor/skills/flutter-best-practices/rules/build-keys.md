---
title: Use Keys Correctly for Widget Identity
impact: HIGH
impactDescription: Preserves state and improves list performance
tags: build, keys, widgets, lists
---

## Use Keys Correctly for Widget Identity

**Impact: HIGH (preserves state, optimizes updates)**

Use keys to help Flutter identify widgets across rebuilds. Critical for lists and when widget order changes.

**When to use keys:**

```dart
// 1. Lists with reorderable or removable items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),  // Use unique ID
      title: Text(items[index].name),
    );
  },
)

// 2. Stateful widgets that may swap positions
Row(
  children: [
    if (showFirst)
      TextField(key: const ValueKey('first')),
    TextField(key: const ValueKey('second')),
  ],
)

// 3. AnimatedSwitcher and similar widgets
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: Text(
    message,
    key: ValueKey(message),  // Key triggers animation
  ),
)
```

**Types of keys:**

```dart
// ValueKey - for unique values
ValueKey(item.id)
ValueKey('unique_string')

// ObjectKey - for object identity
ObjectKey(myObject)

// UniqueKey - new key every time (use sparingly)
UniqueKey()

// GlobalKey - access state from outside (expensive)
final formKey = GlobalKey<FormState>();
```

**Incorrect (no keys, wrong state after reorder):**

```dart
ListView(
  children: items.map((item) =>
    StatefulTile(title: item.name)  // State gets mixed up
  ).toList(),
)
```

**Correct (keys preserve state):**

```dart
ListView(
  children: items.map((item) =>
    StatefulTile(
      key: ValueKey(item.id),  // State stays with item
      title: item.name,
    )
  ).toList(),
)
```

Reference: [Flutter Keys Documentation](https://api.flutter.dev/flutter/foundation/Key-class.html)
