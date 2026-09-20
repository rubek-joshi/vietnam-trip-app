import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/core/trip/trip_dates.dart';
import 'package:vietnam_handbook/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class BudgetStatsPage extends StatelessWidget {
  const BudgetStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BudgetCubit>()..init(),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget stats')),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          if (state.isLoading || state.snapshot == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final snap = state.snapshot!;
          final remainingDays = TripDates.remainingDays();
          final perDay = context.read<BudgetCubit>().suggestedPerDayUsd();
          final activeDay = TripDates.activeDay();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ShadCard(
                title: const Text('Remaining budget'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(
                        snap.remainingUsdEquivalent,
                        CurrencyCode.usd,
                      ),
                      style: theme.textTheme.h2,
                    ),
                    Text(
                      CurrencyFormatter.format(
                        snap.remainingVndEquivalent,
                        CurrencyCode.vnd,
                      ),
                      style: theme.textTheme.p,
                    ),
                    Text(
                      CurrencyFormatter.format(
                        snap.remainingNpr,
                        CurrencyCode.npr,
                      ),
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ShadCard(
                title: const Text('Trip progress'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Today is Day $activeDay of ${TripDates.totalDays}'),
                    Text(
                      remainingDays == 0
                          ? 'Trip complete — enjoy the leftover!'
                          : '$remainingDays day(s) remaining (including today)',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ShadCard(
                title: const Text('Suggested per-day spend'),
                description: Text(
                  remainingDays == 0
                      ? 'No daily target after the trip ends.'
                      : 'Remaining ÷ $remainingDays remaining day(s)',
                  style: theme.textTheme.muted,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (perDay == null)
                      Text('—', style: theme.textTheme.h3)
                    else ...[
                      Text(
                        CurrencyFormatter.format(perDay, CurrencyCode.usd),
                        style: theme.textTheme.h3,
                      ),
                      Text(
                        CurrencyFormatter.format(
                          snap.rates.fromUsd(perDay, CurrencyCode.vnd),
                          CurrencyCode.vnd,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                          snap.rates.fromUsd(perDay, CurrencyCode.npr),
                          CurrencyCode.npr,
                        ),
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ShadCard(
                title: const Text('Wallets'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'USD wallet: ${CurrencyFormatter.format(snap.remainingUsd, CurrencyCode.usd)}',
                    ),
                    Text(
                      'VND wallet: ${CurrencyFormatter.format(snap.remainingVnd, CurrencyCode.vnd)}',
                    ),
                    Text(
                      'Spent (USD eq.): ${CurrencyFormatter.format(snap.spentUsdEquivalent, CurrencyCode.usd)}',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
