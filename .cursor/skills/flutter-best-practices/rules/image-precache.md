---
title: Precache Images for Smooth Display
impact: MEDIUM
impactDescription: Eliminates loading delay on display
tags: image, precache, loading, performance
---

## Precache Images for Smooth Display

**Impact: MEDIUM (eliminates loading flicker)**

Use `precacheImage` to load images before they're displayed, preventing visible loading states.

**Precache on app startup:**

```dart
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache critical images
    precacheImage(const AssetImage('assets/logo.png'), context);
    precacheImage(const AssetImage('assets/background.jpg'), context);
  }

  @override
  Widget build(BuildContext context) => const HomePage();
}
```

**Precache before navigation:**

```dart
Future<void> navigateToDetails(BuildContext context, Product product) async {
  // Precache the product image before navigating
  await precacheImage(
    NetworkImage(product.imageUrl),
    context,
  );

  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetails(product: product),
      ),
    );
  }
}
```

**Precache multiple images:**

```dart
Future<void> precacheProductImages(
  BuildContext context,
  List<Product> products,
) async {
  await Future.wait(
    products.take(10).map((product) =>
      precacheImage(NetworkImage(product.imageUrl), context)
    ),
  );
}
```

**With error handling:**

```dart
Future<void> safePrecache(BuildContext context, String url) async {
  try {
    await precacheImage(NetworkImage(url), context);
  } catch (e) {
    debugPrint('Failed to precache image: $url');
  }
}
```

Reference: [precacheImage Function](https://api.flutter.dev/flutter/widgets/precacheImage.html)
