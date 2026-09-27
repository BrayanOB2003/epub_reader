# Flutter Best Practices

A comprehensive performance optimization guide for Flutter applications, designed as a Claude Code skill.

Contains **20+ rules** across 8 categories, prioritized by impact to guide code review, refactoring, and development.

## Rule Categories

| Priority | Category | Impact | Rules |
|----------|----------|--------|-------|
| 1 | Widget Build Optimization | CRITICAL | 6 |
| 2 | List & Scroll Performance | CRITICAL | 4 |
| 3 | State Management | HIGH | 2 |
| 4 | Image & Asset Optimization | HIGH | 2 |
| 5 | Animation Performance | MEDIUM | 2 |
| 6 | Navigation & Routing | MEDIUM | 1 |
| 7 | Memory Management | MEDIUM | 2 |
| 8 | App Size & Startup | LOW-MEDIUM | 2 |

## Installation

### For Claude Code Users

1. Clone this repository to your Claude skills directory:

```bash
git clone https://github.com/kaelen-hou/flutter-best-practices.git ~/.claude/skills/flutter-best-practices
```

2. The skill will be automatically available in Claude Code.

### Manual Installation

1. Download or clone this repository
2. Copy the entire folder to `~/.claude/skills/`

```bash
cp -r flutter-best-practices ~/.claude/skills/
```

## Usage

### Automatic Triggering

The skill automatically triggers when you:
- Write new Flutter widgets or screens
- Implement list rendering (ListView, GridView)
- Work with state management (Provider, Riverpod, BLoC)
- Optimize images and assets
- Review Flutter/Dart code for performance issues

### Manual Invocation

In Claude Code, you can explicitly invoke the skill:

```
/flutter-best-practices
```

### Example Prompts

- "Review this Flutter widget for performance issues"
- "Help me optimize this ListView"
- "What's wrong with this state management approach?"
- "How should I structure this animation?"

## Key Rules

### Widget Build (CRITICAL)

- **build-const-widgets** - Use `const` constructors for static widgets
- **build-split-widgets** - Split large widgets to reduce rebuild scope
- **build-avoid-rebuild** - Avoid unnecessary `setState()` calls

### List Performance (CRITICAL)

- **list-builder** - Use `ListView.builder` for large lists (10× memory improvement)
- **list-item-extent** - Specify `itemExtent` for fixed-height items (2-3× faster)

### State Management (HIGH)

- **state-selector** - Use `Selector` for granular rebuilds
- **state-notifier** - Prefer `ValueNotifier` for simple state

### Memory (MEDIUM)

- **memory-dispose** - Always dispose controllers and streams
- **memory-isolates** - Use `compute()` for heavy computation

## File Structure

```
flutter-best-practices/
├── SKILL.md              # Main skill definition
├── AGENTS.md             # Compiled full documentation
├── metadata.json         # Skill metadata
├── README.md             # This file
└── rules/
    ├── _template.md      # Rule template
    ├── _sections.md      # Category definitions
    ├── build-*.md        # Widget build rules
    ├── list-*.md         # List performance rules
    ├── state-*.md        # State management rules
    ├── image-*.md        # Image optimization rules
    ├── anim-*.md         # Animation rules
    ├── nav-*.md          # Navigation rules
    ├── memory-*.md       # Memory management rules
    └── app-*.md          # App size/startup rules
```

## Contributing

Contributions are welcome! To add a new rule:

1. Copy `rules/_template.md` to `rules/<category>-<rule-name>.md`
2. Fill in the rule details with examples
3. Update `SKILL.md` to include the new rule in the quick reference
4. Update `AGENTS.md` with the compiled content
5. Submit a pull request

## References

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)
- [Dart Language](https://dart.dev)

## License

MIT License - feel free to use and modify for your projects.
