---
title: Use Selector for Granular State Rebuilds
impact: HIGH
impactDescription: Rebuilds only when specific data changes
tags: state, provider, selector, rebuilds
---

## Use Selector for Granular State Rebuilds

**Impact: HIGH (reduces unnecessary rebuilds)**

Use `Selector` or `context.select()` to rebuild widgets only when specific pieces of state change.

**Incorrect (rebuilds on any state change):**

```dart
class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Rebuilds when ANY part of AppState changes
    final state = context.watch<AppState>();

    return Text(state.user.name);
  }
}
```

**Correct (rebuilds only when user.name changes):**

```dart
class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Only rebuilds when user.name changes
    final userName = context.select<AppState, String>(
      (state) => state.user.name,
    );

    return Text(userName);
  }
}
```

**Using Selector widget:**

```dart
class CartIcon extends StatelessWidget {
  const CartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CartState, int>(
      selector: (context, cart) => cart.itemCount,
      builder: (context, itemCount, child) {
        return Badge(
          label: Text('$itemCount'),
          child: child!,
        );
      },
      child: const Icon(Icons.shopping_cart),  // Not rebuilt
    );
  }
}
```

**With Riverpod:**

```dart
// Define a provider that selects specific data
final userNameProvider = Provider<String>((ref) {
  return ref.watch(userProvider.select((user) => user.name));
});

// Or use select directly
class UserProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(
      userProvider.select((user) => user.name),
    );
    return Text(userName);
  }
}
```

Reference: [Provider Selector](https://pub.dev/documentation/provider/latest/provider/Selector-class.html)
