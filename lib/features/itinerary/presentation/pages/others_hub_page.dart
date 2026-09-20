import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OthersHubPage extends StatelessWidget {
  const OthersHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final items = [
      (
        'Itinerary',
        'Day-by-day package details',
        LucideIcons.map,
        '/others/itinerary',
      ),
      (
        'Vouchers',
        'Confirmed hotels, cruise, flights & services',
        LucideIcons.ticket,
        '/others/vouchers',
      ),
      (
        'Hotels & cruise',
        'Accommodations from the package',
        LucideIcons.building2,
        '/others/hotels',
      ),
      (
        'Inclusions',
        'What is and isn’t covered',
        LucideIcons.clipboardList,
        '/others/inclusions',
      ),
      (
        'Package costs',
        'USD / NPR breakdown',
        LucideIcons.receipt,
        '/others/costs',
      ),
      (
        'FX rates',
        'Edit offline conversion rates',
        LucideIcons.badgeDollarSign,
        '/others/rates',
      ),
      (
        'Settings',
        'Theme, colors, and other preferences',
        LucideIcons.settings,
        '/others/settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Others')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => context.push(item.$4),
            borderRadius: BorderRadius.circular(12),
            child: ShadCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(item.$3, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1),
                        Text(item.$2, style: theme.textTheme.muted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    LucideIcons.chevronRight,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
