---
title: Enable Icon Tree Shaking
impact: MEDIUM
impactDescription: Removes unused icons from bundle
tags: app, size, icons, tree-shaking
---

## Enable Icon Tree Shaking

**Impact: MEDIUM (reduces bundle size)**

Enable icon tree shaking to remove unused Material, Cupertino, and custom icons from your app bundle.

**Enable in build:**

```bash
# Enabled by default in release builds
flutter build apk --release

# Explicitly enable (if disabled)
flutter build apk --tree-shake-icons
```

**Check if enabled:**

```bash
# Should see "Font asset ... was tree-shaken"
flutter build apk --release -v 2>&1 | grep tree-shaken
```

**Use const for icon references:**

```dart
// Good - can be tree-shaken
const Icon(Icons.home)
const Icon(Icons.settings)

// Also good - icon is known at compile time
Icon(Icons.favorite)

// Cannot be tree-shaken - icon determined at runtime
Icon(iconData)  // Where iconData is a variable
```

**Custom icon fonts:**

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: CustomIcons
      fonts:
        - asset: fonts/CustomIcons.ttf
```

**Reduce Material icons:**

If you only use a few icons, consider using a custom icon font or SVG icons instead of including the entire Material Icons font.

```yaml
dependencies:
  flutter_svg: ^2.0.9
```

```dart
// Smaller than including full icon font
SvgPicture.asset(
  'assets/icons/home.svg',
  width: 24,
  height: 24,
)
```

Reference: [Flutter App Size](https://docs.flutter.dev/perf/app-size)
