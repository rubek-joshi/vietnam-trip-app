import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/fx/currency_input_formatter.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/tipping_rate_preset.dart';
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
              const SizedBox(height: 16),
              _FxOverrideCard(state: state),
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

class _FxOverrideCard extends StatelessWidget {
  const _FxOverrideCard({required this.state});

  final TippingState state;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final cubit = context.read<TippingCubit>();

    return ShadCard(
      title: const Text('Exchange rates'),
      description: Text(
        '1 USD = ${CurrencyFormatter.grouped(state.rates.usdToNpr, CurrencyCode.npr)} NPR · '
        '${CurrencyFormatter.grouped(state.rates.usdToVnd, CurrencyCode.vnd)} VND',
        style: theme.textTheme.muted,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.rateSourceLabel, style: theme.textTheme.small),
            const SizedBox(height: 12),
            ShadButton.outline(
              width: double.infinity,
              leading: const Icon(LucideIcons.pencil, size: 16),
              onPressed: () => _showOverrideDialog(context),
              child: const Text('Override exchange'),
            ),
            if (state.isOverridden) ...[
              const SizedBox(height: 8),
              ShadButton.ghost(
                width: double.infinity,
                onPressed: cubit.clearOverride,
                child: const Text('Use app rates'),
              ),
            ],
            if (state.presets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Saved rates', style: theme.textTheme.muted),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in state.presets)
                    _savedRateBadge(
                      label: preset.label,
                      selected: state.activePresetId == preset.id,
                      onPressed: () => cubit.selectPreset(preset),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _savedRateBadge({
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

void _showOverrideDialog(BuildContext context) {
  final cubit = context.read<TippingCubit>();
  final dialogWidth = MediaQuery.sizeOf(context).width - 48;

  showShadDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: cubit,
        child: ShadDialog(
          closeIconData: LucideIcons.x,
          useSafeArea: false,
          scrollable: false,
          alignment: Alignment.center,
          constraints: BoxConstraints.tightFor(width: dialogWidth),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          title: const Text('Override exchange'),
          description: const Text(
            'Applies on this page only. Optionally save as a named rate '
            'to reuse later.',
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.7,
            ),
            child: const SingleChildScrollView(child: _OverrideRatesForm()),
          ),
        ),
      );
    },
  );
}

class _OverrideRatesForm extends StatefulWidget {
  const _OverrideRatesForm();

  @override
  State<_OverrideRatesForm> createState() => _OverrideRatesFormState();
}

class _OverrideRatesFormState extends State<_OverrideRatesForm> {
  late final TextEditingController _nprCtrl;
  late final TextEditingController _vndCtrl;
  late final TextEditingController _nameCtrl;
  bool _saveAsNamed = false;

  @override
  void initState() {
    super.initState();
    final rates = context.read<TippingCubit>().state.rates;
    _nprCtrl = TextEditingController(
      text: CurrencyFormatter.grouped(rates.usdToNpr, CurrencyCode.npr),
    );
    _vndCtrl = TextEditingController(
      text: CurrencyFormatter.grouped(rates.usdToVnd, CurrencyCode.vnd),
    );
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nprCtrl.dispose();
    _vndCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  double? _parseRate(String raw) {
    return double.tryParse(raw.replaceAll(',', '').trim());
  }

  FxRates? _readRates() {
    final npr = _parseRate(_nprCtrl.text);
    final vnd = _parseRate(_vndCtrl.text);
    if (npr == null || vnd == null || npr <= 0 || vnd <= 0) return null;
    return FxRates(usdToNpr: npr, usdToVnd: vnd);
  }

  void _fillFrom(FxRates rates) {
    _nprCtrl.text = CurrencyFormatter.grouped(rates.usdToNpr, CurrencyCode.npr);
    _vndCtrl.text = CurrencyFormatter.grouped(rates.usdToVnd, CurrencyCode.vnd);
  }

  Future<void> _apply() async {
    final rates = _readRates();
    if (rates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid positive rates')),
      );
      return;
    }

    String? saveAs;
    if (_saveAsNamed) {
      final label = _nameCtrl.text.trim();
      if (label.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a name to save this rate')),
        );
        return;
      }
      saveAs = label;
    }

    await context.read<TippingCubit>().applyOverride(
      rates,
      saveAsLabel: saveAs,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1 USD equals', style: theme.textTheme.small),
          const SizedBox(height: 8),
          ShadInput(
            controller: _nprCtrl,
            placeholder: const Text('NPR'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [CurrencyInputFormatter(CurrencyCode.npr)],
            leading: const Text('NPR'),
          ),
          const SizedBox(height: 8),
          ShadInput(
            controller: _vndCtrl,
            placeholder: const Text('VND'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [CurrencyInputFormatter(CurrencyCode.vnd)],
            leading: const Text('VND'),
          ),
          const SizedBox(height: 12),
          ShadCheckbox(
            value: _saveAsNamed,
            onChanged: (value) => setState(() => _saveAsNamed = value),
            label: const Text('Save as a named rate'),
            sublabel: const Text(
              'Keep this set alongside other saved exchange rates.',
            ),
          ),
          if (_saveAsNamed) ...[
            const SizedBox(height: 8),
            ShadInput(
              controller: _nameCtrl,
              placeholder: const Text('e.g. Street cash, Hotel desk'),
            ),
          ],
          BlocBuilder<TippingCubit, TippingState>(
            builder: (context, state) {
              if (state.presets.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saved rates', style: theme.textTheme.muted),
                    const SizedBox(height: 8),
                    for (final preset in state.presets)
                      _SavedRateRow(
                        preset: preset,
                        selected: state.activePresetId == preset.id,
                        onSelect: () {
                          _fillFrom(preset.rates);
                          context.read<TippingCubit>().selectPreset(preset);
                        },
                        onDelete: () => context
                            .read<TippingCubit>()
                            .deletePreset(preset.id),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: _apply,
              child: Text(
                _saveAsNamed ? 'Save & apply' : 'Apply for this page',
              ),
            ),
          ),
          BlocBuilder<TippingCubit, TippingState>(
            builder: (context, state) {
              if (!state.isOverridden) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ShadButton.outline(
                  width: double.infinity,
                  onPressed: () async {
                    await context.read<TippingCubit>().clearOverride();
                    if (context.mounted) {
                      _fillFrom(context.read<TippingCubit>().state.rates);
                    }
                  },
                  child: const Text('Use app rates'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SavedRateRow extends StatelessWidget {
  const _SavedRateRow({
    required this.preset,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
  });

  final TippingRatePreset preset;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onSelect,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.label,
                      style: selected
                          ? theme.textTheme.small.copyWith(
                              fontWeight: FontWeight.w600,
                            )
                          : theme.textTheme.small,
                    ),
                    Text(
                      '1 USD = ${CurrencyFormatter.grouped(preset.rates.usdToNpr, CurrencyCode.npr)} NPR · '
                      '${CurrencyFormatter.grouped(preset.rates.usdToVnd, CurrencyCode.vnd)} VND',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ShadIconButton.ghost(
            icon: const Icon(LucideIcons.trash2, size: 16),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
