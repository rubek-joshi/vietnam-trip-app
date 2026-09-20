import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/trip/trip_dates.dart';

typedef DayPageBuilder = Widget Function(BuildContext context, int day);

/// Swipeable Day 1–7 pager with chip tabs; opens on [initialDay] (active trip day).
class DayPager extends StatefulWidget {
  const DayPager({
    super.key,
    required this.builder,
    this.initialDay,
    this.onDayChanged,
  });

  final DayPageBuilder builder;
  final int? initialDay;
  final ValueChanged<int>? onDayChanged;

  @override
  State<DayPager> createState() => _DayPagerState();
}

class _DayPagerState extends State<DayPager> {
  late final PageController _controller;
  late int _currentDay;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.initialDay ?? TripDates.activeDay();
    _controller = PageController(initialPage: _currentDay - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToDay(int day) {
    if (day == _currentDay) return;
    setState(() => _currentDay = day);
    _controller.animateToPage(
      day - 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    widget.onDayChanged?.call(day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: TripDates.totalDays,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final day = index + 1;
              final selected = day == _currentDay;
              return GestureDetector(
                onTap: () => _goToDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Day $day',
                      style: theme.textTheme.small.copyWith(
                        color: selected
                            ? theme.colorScheme.primaryForeground
                            : theme.colorScheme.mutedForeground,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              TripDates.labelForDay(_currentDay),
              style: theme.textTheme.muted,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: TripDates.totalDays,
            onPageChanged: (index) {
              final day = index + 1;
              setState(() => _currentDay = day);
              widget.onDayChanged?.call(day);
            },
            itemBuilder: (context, index) => widget.builder(context, index + 1),
          ),
        ),
      ],
    );
  }
}
