import 'package:epub_reader/app/schedule_theme.dart';
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
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onSelect,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Descubrimiento',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Biblioteca',
        ),
        NavigationDestination(
          icon: Icon(Icons.timer_outlined),
          selectedIcon: Icon(Icons.timer),
          label: 'Tiempo',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
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
    return CupertinoTabBar(
      currentIndex: index,
      onTap: onSelect,
      activeColor: colors.station,
      inactiveColor: colors.muted,
      backgroundColor: colors.paper.withValues(alpha: 0.94),
      border: Border(top: BorderSide(color: colors.rule)),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.compass),
          label: 'Descubrimiento',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.book),
          label: 'Biblioteca',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.timer),
          label: 'Tiempo',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
