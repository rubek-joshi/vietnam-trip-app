import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vietnam_handbook/core/widgets/scaffold_with_nav_bar.dart';
import 'package:vietnam_handbook/features/budget/presentation/pages/budget_page.dart';
import 'package:vietnam_handbook/features/budget/presentation/pages/budget_stats_page.dart';
import 'package:vietnam_handbook/features/checklist/presentation/pages/checklist_page.dart';
import 'package:vietnam_handbook/features/converter/presentation/pages/home_page.dart';
import 'package:vietnam_handbook/features/converter/presentation/pages/rates_page.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/pages/costs_page.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/pages/hotels_page.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/pages/inclusions_page.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/pages/itinerary_page.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/pages/others_hub_page.dart';
import 'package:vietnam_handbook/features/phrases/presentation/pages/phrases_page.dart';
import 'package:vietnam_handbook/features/settings/presentation/pages/settings_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/checklist',
                builder: (context, state) => const ChecklistPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/budget',
                builder: (context, state) => const BudgetPage(),
                routes: [
                  GoRoute(
                    path: 'stats',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const BudgetStatsPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/phrases',
                builder: (context, state) => const PhrasesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/others',
                builder: (context, state) => const OthersHubPage(),
                routes: [
                  GoRoute(
                    path: 'itinerary',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const ItineraryPage(),
                  ),
                  GoRoute(
                    path: 'hotels',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const HotelsPage(),
                  ),
                  GoRoute(
                    path: 'inclusions',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const InclusionsPage(),
                  ),
                  GoRoute(
                    path: 'costs',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const CostsPage(),
                  ),
                  GoRoute(
                    path: 'rates',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const RatesPage(),
                  ),
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
