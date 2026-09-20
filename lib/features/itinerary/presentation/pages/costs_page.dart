import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/itinerary_data.dart';

class CostsPage extends StatelessWidget {
  const CostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Package costs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShadCard(
            title: const Text('Vietnam Amazing Tour'),
            description: Text(
              '${PackageCosts.nights} · ${PackageCosts.groupSize} adults · '
              'from ${PackageCosts.travelFrom}',
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CurrencyFormatter.format(
                      PackageCosts.usdPerPax,
                      CurrencyCode.usd,
                    ),
                    style: theme.textTheme.h2,
                  ),
                  Text('per person (package)', style: theme.textTheme.muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ShadCard(
            title: const Text('NPR breakdown (quote)'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(PackageCosts.nprPackageRateNote),
                const ShadSeparator.horizontal(),
                _row(
                  'International ticket',
                  CurrencyFormatter.format(
                    PackageCosts.internationalTicketNpr,
                    CurrencyCode.npr,
                  ),
                ),
                _row(
                  'Domestic ticket',
                  CurrencyFormatter.format(
                    PackageCosts.domesticTicketNpr,
                    CurrencyCode.npr,
                  ),
                ),
                const ShadSeparator.horizontal(),
                _row(
                  'Total',
                  CurrencyFormatter.format(
                    PackageCosts.totalNpr,
                    CurrencyCode.npr,
                  ),
                  bold: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'ROE note: xe + 3 when paying in NPR at payment time.',
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: bold ? const TextStyle(fontWeight: FontWeight.w700) : null,
          ),
        ],
      ),
    );
  }
}
