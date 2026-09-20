import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/trip/trip_dates.dart';
import 'package:vietnam_handbook/core/widgets/day_pager.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/itinerary_data.dart';

class ItineraryPage extends StatelessWidget {
  const ItineraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Itinerary')),
      body: DayPager(
        initialDay: TripDates.activeDay(),
        builder: (context, day) {
          final info = itineraryForDay(day);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              ShadCard(
                title: Text(info.title),
                description: Text(
                  '${info.dateLabel} · Meals: ${info.meals} · Overnight: ${info.overnight}',
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(info.summary, style: theme.textTheme.p),
                ),
              ),
              const SizedBox(height: 12),
              Text('Details', style: theme.textTheme.h4),
              const SizedBox(height: 8),
              ...info.details.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ShadCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.circle, size: 10),
                        const SizedBox(width: 10),
                        Expanded(child: Text(d)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
