---
title: Use Slivers for Complex Scrolling Layouts
impact: HIGH
impactDescription: Efficient mixed-content scrolling
tags: list, slivers, scrolling, customscrollview
---

## Use Slivers for Complex Scrolling Layouts

**Impact: HIGH (efficient mixed-content scrolling)**

Use `CustomScrollView` with Slivers for complex scrolling layouts with headers, grids, and lists combined.

**Incorrect (nested scrollables):**

```dart
// BAD: Nested scrollables cause issues
SingleChildScrollView(
  child: Column(
    children: [
      Header(),
      SizedBox(
        height: 300,  // Must specify height!
        child: ListView.builder(...),  // Nested scroll
      ),
    ],
  ),
)
```

**Correct (using Slivers):**

```dart
CustomScrollView(
  slivers: [
    // App bar that collapses
    const SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('My App'),
      ),
    ),

    // Fixed header
    const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Featured Items'),
      ),
    ),

    // Horizontal list
    SliverToBoxAdapter(
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: featuredItems.length,
          itemBuilder: (context, index) => FeaturedCard(item: featuredItems[index]),
        ),
      ),
    ),

    // Grid section
    SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => GridItem(item: gridItems[index]),
        childCount: gridItems.length,
      ),
    ),

    // List section
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListItem(item: listItems[index]),
        childCount: listItems.length,
      ),
    ),
  ],
)
```

**Common Sliver widgets:**
- `SliverList` - Lazy list
- `SliverGrid` - Lazy grid
- `SliverAppBar` - Collapsible app bar
- `SliverToBoxAdapter` - Single widget
- `SliverPadding` - Padding around slivers
- `SliverFillRemaining` - Fill remaining space

Reference: [Flutter Slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers)
