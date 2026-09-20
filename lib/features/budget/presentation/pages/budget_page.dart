import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/budget/domain/entities/budget_entities.dart';
import 'package:vietnam_handbook/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BudgetCubit>()..init(),
      child: const _BudgetView(),
    );
  }
}

class _BudgetView extends StatelessWidget {
  const _BudgetView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            tooltip: 'Stats',
            icon: const Icon(LucideIcons.chartPie),
            onPressed: () => context.push('/budget/stats'),
          ),
          IconButton(
            tooltip: 'Configure budget',
            icon: const Icon(LucideIcons.slidersHorizontal),
            onPressed: () => _showConfigSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
            context.read<BudgetCubit>().clearMessage();
          }
        },
        builder: (context, state) {
          if (state.isLoading || state.snapshot == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final snap = state.snapshot!;
          final theme = ShadTheme.of(context);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ShadCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!snap.config.configured)
                        ShadAlert(
                          title: const Text('Set your trip budget'),
                          description: const Text(
                            'Tap the sliders icon to configure initial USD (and optional VND).',
                          ),
                        )
                      else if (snap.isOverspent)
                        const ShadAlert.destructive(
                          title: Text('Overspent'),
                          description: Text(
                            'Remaining balance is negative — review expenses.',
                          ),
                        ),
                      Text('Remaining', style: theme.textTheme.muted),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(
                          snap.remainingUsdEquivalent,
                          CurrencyCode.usd,
                        ),
                        style: theme.textTheme.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${CurrencyFormatter.format(snap.remainingVndEquivalent, CurrencyCode.vnd)}'
                        ' · ${CurrencyFormatter.format(snap.remainingNpr, CurrencyCode.npr)}',
                        style: theme.textTheme.small,
                      ),
                      const SizedBox(height: 8),
                      ShadProgress(value: snap.progressUsed.clamp(0.0, 1.0)),
                      const SizedBox(height: 4),
                      Text(
                        'USD left ${CurrencyFormatter.format(snap.remainingUsd, CurrencyCode.usd)}'
                        ' · VND left ${CurrencyFormatter.format(snap.remainingVnd, CurrencyCode.vnd)}',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Vietnamese Dong'),
                          Tab(text: 'USD'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _WalletPane(
                              currency: ExpenseCurrency.vnd,
                              snapshot: snap,
                            ),
                            _WalletPane(
                              currency: ExpenseCurrency.usd,
                              snapshot: snap,
                            ),
                          ],
                        ),
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
}

class _WalletPane extends StatelessWidget {
  const _WalletPane({required this.currency, required this.snapshot});

  final ExpenseCurrency currency;
  final BudgetSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final expenses = snapshot.expensesFor(currency);
    final theme = ShadTheme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      children: [
        Row(
          children: [
            Expanded(
              child: ShadButton(
                onPressed: () => _showExpenseSheet(context, currency: currency),
                child: const Text('Add expense'),
              ),
            ),
            if (currency == ExpenseCurrency.usd) ...[
              const SizedBox(width: 8),
              Expanded(
                child: ShadButton.outline(
                  onPressed: () => _showExchangeSheet(context),
                  child: const Text('Exchange → VND'),
                ),
              ),
            ],
          ],
        ),
        if (currency == ExpenseCurrency.usd &&
            snapshot.exchanges.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Exchanges', style: theme.textTheme.h4),
          const SizedBox(height: 8),
          ...snapshot.exchanges.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShadCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${CurrencyFormatter.format(e.usdAmount, CurrencyCode.usd)}'
                            ' → ${CurrencyFormatter.format(e.vndReceived, CurrencyCode.vnd)}',
                          ),
                          Text(
                            'Rate ~${CurrencyFormatter.grouped(e.impliedRate, CurrencyCode.vnd)} VND/USD'
                            '${e.note.isEmpty ? '' : ' · ${e.note}'}',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    ShadIconButton.ghost(
                      icon: const Icon(LucideIcons.trash2, size: 18),
                      onPressed: () =>
                          context.read<BudgetCubit>().deleteExchange(e.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text('Expenses', style: theme.textTheme.h4),
        const SizedBox(height: 8),
        if (expenses.isEmpty)
          Text('No expenses yet.', style: theme.textTheme.muted)
        else
          ...expenses.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ExpenseTile(expense: e, rates: snapshot.rates),
            ),
          ),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.rates});

  final ExpenseRecord expense;
  final FxRates rates;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final code = expense.currency == ExpenseCurrency.usd
        ? CurrencyCode.usd
        : CurrencyCode.vnd;
    final npr = rates.toNpr(expense.amount, code);

    return ShadCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: theme.textTheme.large),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(expense.amount, code),
                  style: theme.textTheme.p,
                ),
                const SizedBox(height: 4),
                ShadBadge(
                  child: Text(
                    '≈ ${CurrencyFormatter.format(npr, CurrencyCode.npr)}',
                  ),
                ),
                if (expense.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(expense.note, style: theme.textTheme.muted),
                  ),
              ],
            ),
          ),
          ShadIconButton.ghost(
            icon: const Icon(LucideIcons.pencil, size: 18),
            onPressed: () => _showExpenseSheet(
              context,
              currency: expense.currency,
              existing: expense,
            ),
          ),
          ShadIconButton.ghost(
            icon: const Icon(LucideIcons.trash2, size: 18),
            onPressed: () =>
                context.read<BudgetCubit>().deleteExpense(expense.id),
          ),
        ],
      ),
    );
  }
}

Future<void> _showConfigSheet(BuildContext context) async {
  final cubit = context.read<BudgetCubit>();
  final snap = cubit.state.snapshot;
  final usdCtrl = TextEditingController(
    text: snap?.config.initialUsd == 0
        ? ''
        : snap!.config.initialUsd.toStringAsFixed(2),
  );
  final vndCtrl = TextEditingController(
    text: snap?.config.initialVnd == 0
        ? ''
        : snap!.config.initialVnd.toStringAsFixed(0),
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Initial budget', style: ShadTheme.of(ctx).textTheme.h4),
            const SizedBox(height: 12),
            ShadInput(
              controller: usdCtrl,
              placeholder: const Text('Initial USD'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leading: const Text('USD'),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: vndCtrl,
              placeholder: const Text('Starting VND (optional)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leading: const Text('VND'),
            ),
            const SizedBox(height: 12),
            ShadButton(
              onPressed: () {
                cubit.configureBudget(
                  initialUsd: double.tryParse(usdCtrl.text) ?? 0,
                  initialVnd: double.tryParse(vndCtrl.text) ?? 0,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
  usdCtrl.dispose();
  vndCtrl.dispose();
}

Future<void> _showExchangeSheet(BuildContext context) async {
  final cubit = context.read<BudgetCubit>();
  final usdCtrl = TextEditingController();
  final vndCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Exchange USD → VND', style: ShadTheme.of(ctx).textTheme.h4),
            const SizedBox(height: 12),
            ShadInput(
              controller: usdCtrl,
              placeholder: const Text('USD given'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leading: const Text('USD'),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: vndCtrl,
              placeholder: const Text('VND received'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leading: const Text('VND'),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: noteCtrl,
              placeholder: const Text('Note (optional)'),
            ),
            const SizedBox(height: 12),
            ShadButton(
              onPressed: () {
                final usd = double.tryParse(usdCtrl.text) ?? 0;
                final vnd = double.tryParse(vndCtrl.text) ?? 0;
                if (usd <= 0 || vnd <= 0) return;
                cubit.addExchange(
                  usdAmount: usd,
                  vndReceived: vnd,
                  date: DateTime.now(),
                  note: noteCtrl.text,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save exchange'),
            ),
          ],
        ),
      );
    },
  );
  usdCtrl.dispose();
  vndCtrl.dispose();
  noteCtrl.dispose();
}

Future<void> _showExpenseSheet(
  BuildContext context, {
  required ExpenseCurrency currency,
  ExpenseRecord? existing,
}) async {
  final cubit = context.read<BudgetCubit>();
  final rates = cubit.state.snapshot?.rates ?? FxRates.defaults;
  final code = currency == ExpenseCurrency.usd
      ? CurrencyCode.usd
      : CurrencyCode.vnd;

  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final amountCtrl = TextEditingController(
    text: existing == null ? '' : existing.amount.toString(),
  );
  final noteCtrl = TextEditingController(text: existing?.note ?? '');
  var liveNpr = existing == null ? 0.0 : rates.toNpr(existing.amount, code);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null ? 'Add expense' : 'Edit expense',
                  style: ShadTheme.of(ctx).textTheme.h4,
                ),
                const SizedBox(height: 12),
                ShadInput(
                  controller: titleCtrl,
                  placeholder: const Text('Title'),
                ),
                const SizedBox(height: 8),
                ShadInput(
                  controller: amountCtrl,
                  placeholder: Text(code.name.toUpperCase()),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  leading: Text(code.name.toUpperCase()),
                  onChanged: (v) {
                    final amt = double.tryParse(v) ?? 0;
                    setModalState(() {
                      liveNpr = rates.toNpr(amt, code);
                    });
                  },
                ),
                const SizedBox(height: 8),
                ShadBadge(
                  child: Text(
                    '≈ ${CurrencyFormatter.format(liveNpr, CurrencyCode.npr)}',
                  ),
                ),
                const SizedBox(height: 8),
                ShadInput(
                  controller: noteCtrl,
                  placeholder: const Text('Note (optional)'),
                ),
                const SizedBox(height: 12),
                ShadButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text) ?? 0;
                    if (titleCtrl.text.trim().isEmpty || amt <= 0) return;
                    cubit.addExpense(
                      id: existing?.id,
                      title: titleCtrl.text,
                      amount: amt,
                      currency: currency,
                      date: existing?.date ?? DateTime.now(),
                      note: noteCtrl.text,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  titleCtrl.dispose();
  amountCtrl.dispose();
  noteCtrl.dispose();
}
