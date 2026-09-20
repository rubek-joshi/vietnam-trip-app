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
              leading: Icon(item.$3),
              title: Text(item.$1),
              description: Text(item.$2, style: theme.textTheme.muted),
              trailing: const Icon(LucideIcons.chevronRight),
            ),
          );
        },
      ),
    );
  }
}
