import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ios
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IosBar(
                  index: navigationShell.currentIndex,
                  onSelect: _select,
                ),
              ],
            )
          : _AndroidBar(index: navigationShell.currentIndex, onSelect: _select),
    );
  }
}

class _AndroidBar extends StatelessWidget {
  const _AndroidBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onSelect,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore),
          label: l10n.discover,
        ),
        NavigationDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book),
          label: l10n.library,
        ),
        NavigationDestination(
          icon: const Icon(Icons.timer_outlined),
          selectedIcon: const Icon(Icons.timer),
          label: l10n.time,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
    );
  }
}

class _IosBar extends StatelessWidget {
  const _IosBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    return CupertinoTabBar(
      currentIndex: index,
      onTap: onSelect,
      activeColor: colors.station,
      inactiveColor: colors.muted,
      backgroundColor: colors.paper.withValues(alpha: 0.94),
      border: Border(top: BorderSide(color: colors.rule)),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.compass),
          label: l10n.discover,
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.book),
          label: l10n.library,
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.timer),
          label: l10n.time,
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.person),
          label: l10n.profile,
        ),
      ],
    );
  }
}
