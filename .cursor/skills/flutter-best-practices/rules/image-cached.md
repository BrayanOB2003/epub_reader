---
title: Use cached_network_image for Remote Images
impact: HIGH
impactDescription: Automatic caching, placeholder support
tags: image, caching, network, performance
---

## Use cached_network_image for Remote Images

**Impact: HIGH (automatic caching, better UX)**

Use `cached_network_image` package for efficient loading and caching of network images.

**Installation:**

```yaml
dependencies:
  cached_network_image: ^3.3.0
```

**Incorrect (no caching):**

```dart
Image.network(
  'https://example.com/image.jpg',
  // No caching, no placeholder, poor UX
)
```

**Correct (with caching and placeholders):**

```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fadeInDuration: const Duration(milliseconds: 300),
)
```

**With memory cache configuration:**

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 200,  // Cache at specific size
  memCacheHeight: 200,
  maxWidthDiskCache: 400,
  maxHeightDiskCache: 400,
  placeholder: (context, url) => const Shimmer(),
  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
)
```

**Custom cache manager:**

```dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );
}

// Usage
CachedNetworkImage(
  imageUrl: imageUrl,
  cacheManager: CustomCacheManager.instance,
)
```

Reference: [cached_network_image Package](https://pub.dev/packages/cached_network_image)
