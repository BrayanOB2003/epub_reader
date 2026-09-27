# Rule Sections

This document defines the structure and organization of rules in this skill.

## Categories

### 1. Widget Build Optimization (CRITICAL)
Optimizations for widget construction and rebuild cycles. Excessive rebuilds are the #1 cause of poor Flutter performance.

### 2. List & Scroll Performance (CRITICAL)
ListView, GridView, and scrolling optimizations. Poor list performance causes janky scrolling and high memory usage.

### 3. State Management (HIGH)
Patterns for efficient state handling with Provider, Riverpod, BLoC, and built-in solutions.

### 4. Image & Asset Optimization (HIGH)
Image loading, caching, and display optimizations. Images often dominate memory usage and network bandwidth.

### 5. Animation Performance (MEDIUM)
Techniques for smooth 60fps animations without jank.

### 6. Navigation & Routing (MEDIUM)
GoRouter and Navigator 2.0 patterns for efficient routing.

### 7. Memory Management (MEDIUM)
Preventing memory leaks and managing resources efficiently.

### 8. App Size & Startup (LOW-MEDIUM)
Reducing app bundle size and improving cold start time.

## Rule Naming Convention

Rules are named with a prefix indicating their category:
- `build-*` - Widget build optimizations
- `list-*` - List and scroll optimizations
- `state-*` - State management patterns
- `image-*` - Image optimizations
- `anim-*` - Animation performance
- `nav-*` - Navigation patterns
- `memory-*` - Memory management
- `app-*` - App size and startup
