import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/features/shopping/domain/entities/shopping_item.dart';
import 'package:vietnam_handbook/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:vietnam_handbook/features/shopping/domain/shopping_text.dart';
import 'package:vietnam_handbook/injection.dart';

class OthersHubPage extends StatelessWidget {
  const OthersHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final items = [
      (
        'Package costs',
        'USD / NPR breakdown',
        LucideIcons.receipt,
        '/others/costs',
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
        'Tipping calculator',
        'USD 1.5 / 3 per person × 9 people',
        LucideIcons.handCoins,
        '/others/tipping',
      ),
      (
        'Shopping list',
        shoppingListEmptySummary,
        LucideIcons.shoppingBag,
        '/others/shopping',
      ),
      (
        'FX rates',
        'Edit offline conversion rates',
        LucideIcons.badgeDollarSign,
        '/others/rates',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Others'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push('/others/settings'),
          ),
        ],
      ),
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
                        item.$4 == '/others/shopping'
                            ? const _ShoppingHubSubtitle()
                            : Text(item.$2, style: theme.textTheme.muted),
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

class _ShoppingHubSubtitle extends StatelessWidget {
  const _ShoppingHubSubtitle();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return StreamBuilder<List<ShoppingItem>>(
      stream: getIt<ShoppingRepository>().watchAll(),
      builder: (context, snapshot) {
        return Text(
          shoppingListSummary(snapshot.data ?? const []),
          style: theme.textTheme.muted,
        );
      },
    );
  }
}
