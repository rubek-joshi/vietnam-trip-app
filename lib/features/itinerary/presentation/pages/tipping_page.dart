import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/fx/currency_input_formatter.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/cubit/tipping_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class TippingPage extends StatelessWidget {
  const TippingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TippingCubit>()..init(),
      child: const _TippingView(),
    );
  }
}

class _TippingView extends StatefulWidget {
  const _TippingView();

  @override
  State<_TippingView> createState() => _TippingViewState();
}

class _TippingViewState extends State<_TippingView> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: '1.5');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(double amount) {
    _amountCtrl.text = amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(1);
    _amountCtrl.selection = TextSelection.collapsed(
      offset: _amountCtrl.text.length,
    );
    context.read<TippingCubit>().setPerPersonUsd(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tipping calculator')),
      body: BlocBuilder<TippingCubit, TippingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Compulsory tipping is USD 3 per person for a full day, '
                'or USD 1.5 for a half day / airport transfer. Totals are '
                'always for ${state.pax} people.',
                style: theme.textTheme.muted,
              ),
              const SizedBox(height: 16),
              ShadCard(
                title: const Text('Tip per person'),
                description: Text(
                  'USD · ${state.pax} adults',
                  style: theme.textTheme.muted,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _presetBadge(
                            label: 'USD 1.5',
                            selected: state.isPreset(TippingCubit.halfDayUsd),
                            onPressed: () =>
                                _applyPreset(TippingCubit.halfDayUsd),
                          ),
                          _presetBadge(
                            label: 'USD 3',
                            selected: state.isPreset(TippingCubit.fullDayUsd),
                            onPressed: () =>
                                _applyPreset(TippingCubit.fullDayUsd),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ShadInput(
                        controller: _amountCtrl,
                        placeholder: const Text('Amount per person'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: const [
                          CurrencyInputFormatter(CurrencyCode.usd),
                        ],
                        leading: const Text('USD'),
                        onChanged: context
                            .read<TippingCubit>()
                            .setPerPersonFromInput,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShadCard(
                title: const Text('Total for 9 people'),
                description: Text(
                  '${CurrencyFormatter.format(state.perPersonUsd, CurrencyCode.usd)} × ${state.pax}',
                  style: theme.textTheme.muted,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyFormatter.format(
                          state.totalUsd,
                          CurrencyCode.usd,
                        ),
                        style: theme.textTheme.h2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(
                          state.totalVnd,
                          CurrencyCode.vnd,
                        ),
                        style: theme.textTheme.p,
                      ),
                      Text(
                        '≈ ${CurrencyFormatter.format(state.totalNpr, CurrencyCode.npr)}',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _presetBadge({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    final child = Text(label);
    if (selected) {
      return ShadBadge(onPressed: onPressed, child: child);
    }
    return ShadBadge.outline(onPressed: onPressed, child: child);
  }
}
