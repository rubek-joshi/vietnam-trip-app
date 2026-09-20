import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/core/widgets/confirm_remove_dialog.dart';
import 'package:vietnam_handbook/features/converter/presentation/cubit/converter_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConverterCubit>()..init(),
      child: const _RatesView(),
    );
  }
}

class _RatesView extends StatefulWidget {
  const _RatesView();

  @override
  State<_RatesView> createState() => _RatesViewState();
}

class _RatesViewState extends State<_RatesView> {
  final _nprCtrl = TextEditingController();
  final _vndCtrl = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _nprCtrl.dispose();
    _vndCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('FX rates')),
      body: BlocConsumer<ConverterCubit, ConverterState>(
        listener: (context, state) {
          if (!_filled && !state.isLoading) {
            _nprCtrl.text = state.rates.usdToNpr.toStringAsFixed(2);
            _vndCtrl.text = state.rates.usdToVnd.toStringAsFixed(0);
            _filled = true;
          }
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
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
              Text(
                'Rates are stored on this device and used for the converter, '
                'budget NPR equivalents, and remaining balances.',
                style: theme.textTheme.muted,
              ),
              const SizedBox(height: 16),
              ShadCard(
                title: const Text('1 USD equals'),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    ShadInput(
                      controller: _nprCtrl,
                      placeholder: const Text('NPR'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      leading: const Text('NPR'),
                    ),
                    const SizedBox(height: 12),
                    ShadInput(
                      controller: _vndCtrl,
                      placeholder: const Text('VND'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      leading: const Text('VND'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ShadButton(
                        onPressed: () async {
                          final npr = double.tryParse(_nprCtrl.text);
                          final vnd = double.tryParse(_vndCtrl.text);
                          if (npr == null ||
                              vnd == null ||
                              npr <= 0 ||
                              vnd <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter valid positive rates'),
                              ),
                            );
                            return;
                          }
                          await context.read<ConverterCubit>().updateRates(
                            FxRates(usdToNpr: npr, usdToVnd: vnd),
                          );
                          if (context.mounted) context.pop();
                        },
                        child: const Text('Save rates'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShadButton.outline(
                      width: double.infinity,
                      onPressed: () async {
                        final confirmed = await confirmRemove(
                          context,
                          title: 'Reset to defaults?',
                          description:
                              'This will restore 1 USD = ${CurrencyFormatter.grouped(FxRates.defaults.usdToNpr, CurrencyCode.npr)} NPR and ${CurrencyFormatter.grouped(FxRates.defaults.usdToVnd, CurrencyCode.vnd)} VND.',
                          confirmLabel: 'Reset',
                        );
                        if (!confirmed || !context.mounted) return;
                        _nprCtrl.text =
                            FxRates.defaults.usdToNpr.toStringAsFixed(2);
                        _vndCtrl.text =
                            FxRates.defaults.usdToVnd.toStringAsFixed(0);
                        context
                            .read<ConverterCubit>()
                            .updateRates(FxRates.defaults);
                      },
                      child: const Text('Reset to defaults'),
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
