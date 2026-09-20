import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.listChecks),
            label: 'Checklist',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.wallet),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.languages),
            label: 'Phrases',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.ellipsis),
            label: 'Others',
          ),
        ],
      ),
    );
  }
}
