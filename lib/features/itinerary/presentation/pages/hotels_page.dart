import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/itinerary_data.dart';

class HotelsPage extends StatelessWidget {
  const HotelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Hotels & cruise')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Option 1 · 3-star (or similar). Rooms may request a deposit at check-in.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 12),
          ...packageHotels.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShadCard(
                title: Text(h.name),
                description: Text(h.destination),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(h.room),
                ),
              ),
            ),
          ),
          const ShadSeparator.horizontal(),
          const SizedBox(height: 8),
          Text(
            'Note: No rooms were held at quoting time; availability can change.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
