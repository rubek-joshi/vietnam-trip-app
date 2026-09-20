import 'package:equatable/equatable.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';

class BudgetConfig extends Equatable {
  const BudgetConfig({
    this.initialUsd = 0,
    this.initialVnd = 0,
    this.configured = false,
  });

  final double initialUsd;
  final double initialVnd;
  final bool configured;

  BudgetConfig copyWith({
    double? initialUsd,
    double? initialVnd,
    bool? configured,
  }) {
    return BudgetConfig(
      initialUsd: initialUsd ?? this.initialUsd,
      initialVnd: initialVnd ?? this.initialVnd,
      configured: configured ?? this.configured,
    );
  }

  Map<String, dynamic> toJson() => {
        'initialUsd': initialUsd,
        'initialVnd': initialVnd,
        'configured': configured,
      };

  factory BudgetConfig.fromJson(Map<dynamic, dynamic> json) {
    return BudgetConfig(
      initialUsd: (json['initialUsd'] as num?)?.toDouble() ?? 0,
      initialVnd: (json['initialVnd'] as num?)?.toDouble() ?? 0,
      configured: json['configured'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [initialUsd, initialVnd, configured];
}

class ExchangeRecord extends Equatable {
  const ExchangeRecord({
    required this.id,
    required this.usdAmount,
    required this.vndReceived,
    required this.date,
    this.note = '',
  });

  final String id;
  final double usdAmount;
  final double vndReceived;
  final DateTime date;
  final String note;

  double get impliedRate => usdAmount == 0 ? 0 : vndReceived / usdAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'usdAmount': usdAmount,
        'vndReceived': vndReceived,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory ExchangeRecord.fromJson(Map<dynamic, dynamic> json) {
    return ExchangeRecord(
      id: json['id'] as String,
      usdAmount: (json['usdAmount'] as num).toDouble(),
      vndReceived: (json['vndReceived'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, usdAmount, vndReceived, date, note];
}

enum ExpenseCurrency { usd, vnd }

class ExpenseRecord extends Equatable {
  const ExpenseRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    this.note = '',
  });

  final String id;
  final String title;
  final double amount;
  final ExpenseCurrency currency;
  final DateTime date;
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'currency': currency.name,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory ExpenseRecord.fromJson(Map<dynamic, dynamic> json) {
    return ExpenseRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: ExpenseCurrency.values.byName(json['currency'] as String),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
    );
  }

  ExpenseRecord copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCurrency? currency,
    DateTime? date,
    String? note,
  }) {
    return ExpenseRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, currency, date, note];
}

class BudgetSnapshot extends Equatable {
  const BudgetSnapshot({
    required this.config,
    required this.exchanges,
    required this.expenses,
    required this.rates,
  });

  final BudgetConfig config;
  final List<ExchangeRecord> exchanges;
  final List<ExpenseRecord> expenses;
  final FxRates rates;

  double get exchangedUsd =>
      exchanges.fold(0.0, (s, e) => s + e.usdAmount);

  double get exchangedVnd =>
      exchanges.fold(0.0, (s, e) => s + e.vndReceived);

  double get usdExpenses => expenses
      .where((e) => e.currency == ExpenseCurrency.usd)
      .fold(0.0, (s, e) => s + e.amount);

  double get vndExpenses => expenses
      .where((e) => e.currency == ExpenseCurrency.vnd)
      .fold(0.0, (s, e) => s + e.amount);

  double get remainingUsd =>
      config.initialUsd - exchangedUsd - usdExpenses;

  double get remainingVnd =>
      config.initialVnd + exchangedVnd - vndExpenses;

  double get remainingUsdEquivalent =>
      remainingUsd + rates.toUsd(remainingVnd, CurrencyCode.vnd);

  double get remainingVndEquivalent =>
      remainingVnd + rates.fromUsd(remainingUsd, CurrencyCode.vnd);

  double get remainingNpr =>
      rates.toNpr(remainingUsdEquivalent, CurrencyCode.usd);

  double get totalInitialUsdEquivalent =>
      config.initialUsd + rates.toUsd(config.initialVnd, CurrencyCode.vnd);

  double get spentUsdEquivalent =>
      totalInitialUsdEquivalent - remainingUsdEquivalent;

  double get progressUsed {
    if (totalInitialUsdEquivalent <= 0) return 0;
    return (spentUsdEquivalent / totalInitialUsdEquivalent).clamp(0.0, 1.5);
  }

  bool get isOverspent => remainingUsdEquivalent < 0;

  List<ExpenseRecord> expensesFor(ExpenseCurrency currency) =>
      expenses.where((e) => e.currency == currency).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  List<Object?> get props => [config, exchanges, expenses, rates];
}
