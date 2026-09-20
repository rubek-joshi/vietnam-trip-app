import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/fx/currency_input_formatter.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/converter/domain/entities/saved_conversion.dart';
import 'package:vietnam_handbook/features/converter/presentation/cubit/converter_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConverterCubit>()..init(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  late final TextEditingController _usdCtrl;
  late final TextEditingController _nprCtrl;
  late final TextEditingController _vndCtrl;
  late final TextEditingController _labelCtrl;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _usdCtrl = TextEditingController();
    _nprCtrl = TextEditingController();
    _vndCtrl = TextEditingController();
    _labelCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _usdCtrl.dispose();
    _nprCtrl.dispose();
    _vndCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  void _syncControllers(ConverterState state) {
    if (_syncing) return;
    _syncing = true;
    void set(TextEditingController c, double v, CurrencyCode code) {
      final text = v == 0
          ? ''
          : CurrencyFormatter.grouped(
              v,
              code,
              decimals: code == CurrencyCode.vnd
                  ? 0
                  : (v.truncateToDouble() == v ? 0 : 2),
            );
      if (c.text != text) {
        c.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }

    if (state.source != CurrencyCode.usd) {
      set(_usdCtrl, state.usd, CurrencyCode.usd);
    }
    if (state.source != CurrencyCode.npr) {
      set(_nprCtrl, state.npr, CurrencyCode.npr);
    }
    if (state.source != CurrencyCode.vnd) {
      set(_vndCtrl, state.vnd, CurrencyCode.vnd);
    }
    _syncing = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency'),
        actions: [
          IconButton(
            tooltip: 'Edit rates',
            icon: const Icon(LucideIcons.settings2),
            onPressed: () => context.push('/others/rates'),
          ),
        ],
      ),
      body: BlocConsumer<ConverterCubit, ConverterState>(
        listenWhen: (p, c) =>
            p.usd != c.usd ||
            p.npr != c.npr ||
            p.vnd != c.vnd ||
            p.message != c.message,
        listener: (context, state) {
          _syncControllers(state);
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
            context.read<ConverterCubit>().clearMessage();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ShadCard(
                title: const Text('Quick converter'),
                description: Text(
                  '1 USD = ${CurrencyFormatter.grouped(state.rates.usdToNpr, CurrencyCode.npr)} NPR · '
                  '${CurrencyFormatter.grouped(state.rates.usdToVnd, CurrencyCode.vnd)} VND',
                  style: theme.textTheme.muted,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _CurrencyField(
                      label: 'USD',
                      code: CurrencyCode.usd,
                      controller: _usdCtrl,
                      onChanged: (v) => context
                          .read<ConverterCubit>()
                          .updateAmount(v, CurrencyCode.usd),
                    ),
                    const SizedBox(height: 12),
                    _CurrencyField(
                      label: 'NPR',
                      code: CurrencyCode.npr,
                      controller: _nprCtrl,
                      onChanged: (v) => context
                          .read<ConverterCubit>()
                          .updateAmount(v, CurrencyCode.npr),
                    ),
                    const SizedBox(height: 12),
                    _CurrencyField(
                      label: 'VND',
                      code: CurrencyCode.vnd,
                      controller: _vndCtrl,
                      onChanged: (v) => context
                          .read<ConverterCubit>()
                          .updateAmount(v, CurrencyCode.vnd),
                    ),
                    const SizedBox(height: 16),
                    ShadInput(
                      controller: _labelCtrl,
                      placeholder: const Text('Label (e.g. Lunch tip)'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ShadButton(
                        onPressed: () {
                          context.read<ConverterCubit>().saveCurrent(
                            _labelCtrl.text,
                          );
                          _labelCtrl.clear();
                        },
                        child: const Text('Save calculation'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Saved', style: theme.textTheme.h4),
                  const Spacer(),
                  _SortControls(state: state),
                ],
              ),
              const SizedBox(height: 8),
              if (state.sortedHistory.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No saved calculations yet.',
                    style: theme.textTheme.muted,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...state.sortedHistory.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HistoryTile(item: item),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CurrencyField extends StatelessWidget {
  const _CurrencyField({
    required this.label,
    required this.code,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final CurrencyCode code;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: controller,
      placeholder: Text(label),
      keyboardType: code == CurrencyCode.vnd
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [CurrencyInputFormatter(code)],
      leading: SizedBox(
        width: 44,
        child: Text(
          label,
          style: ShadTheme.of(
            context,
          ).textTheme.small.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _SortControls extends StatelessWidget {
  const _SortControls({required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadButton.outline(
          size: ShadButtonSize.sm,
          onPressed: () {
            cubit.setSort(
              field: state.sortField == ConversionSortField.label
                  ? ConversionSortField.amount
                  : ConversionSortField.label,
            );
          },
          child: Text(
            state.sortField == ConversionSortField.label ? 'Label' : 'Amount',
          ),
        ),
        const SizedBox(width: 6),
        ShadIconButton.ghost(
          icon: Icon(
            state.sortDirection == SortDirection.ascending
                ? LucideIcons.arrowUpNarrowWide
                : LucideIcons.arrowDownWideNarrow,
          ),
          onPressed: () {
            cubit.setSort(
              direction: state.sortDirection == SortDirection.ascending
                  ? SortDirection.descending
                  : SortDirection.ascending,
            );
          },
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final SavedConversion item;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: theme.textTheme.large),
                const SizedBox(height: 4),
                Text(
                  '${CurrencyFormatter.format(item.usd, CurrencyCode.usd)} · '
                  '${CurrencyFormatter.format(item.npr, CurrencyCode.npr)} · '
                  '${CurrencyFormatter.format(item.vnd, CurrencyCode.vnd)}',
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
          ShadIconButton.ghost(
            icon: const Icon(LucideIcons.pencil, size: 18),
            onPressed: () => _edit(context),
          ),
          ShadIconButton.ghost(
            icon: const Icon(LucideIcons.trash2, size: 18),
            onPressed: () =>
                context.read<ConverterCubit>().deleteSaved(item.id),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final ctrl = TextEditingController(text: item.label);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit label'),
        content: ShadInput(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<ConverterCubit>().updateSaved(
        item.copyWith(label: ctrl.text.trim()),
      );
    }
    ctrl.dispose();
  }
}
