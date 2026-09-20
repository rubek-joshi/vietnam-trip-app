import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/itinerary_data.dart';

class InclusionsPage extends StatelessWidget {
  const InclusionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Inclusions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Included', style: theme.textTheme.h4),
          const SizedBox(height: 8),
          ...packageInclusions.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShadCard(
                leading: Icon(
                  LucideIcons.check,
                  color: theme.colorScheme.primary,
                ),
                child: Text(e),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Excluded', style: theme.textTheme.h4),
          const SizedBox(height: 8),
          ...packageExclusions.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShadCard(
                leading: Icon(
                  LucideIcons.x,
                  color: theme.colorScheme.destructive,
                ),
                child: Text(e),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
