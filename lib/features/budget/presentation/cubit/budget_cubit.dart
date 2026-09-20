import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/core/trip/trip_dates.dart';
import 'package:vietnam_handbook/features/budget/domain/entities/budget_entities.dart';
import 'package:vietnam_handbook/features/budget/domain/repositories/budget_repository.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/fx_rates_repository.dart';

class BudgetState extends Equatable {
  const BudgetState({
    this.snapshot,
    this.isLoading = true,
    this.activeWallet = ExpenseCurrency.vnd,
    this.message,
  });

  final BudgetSnapshot? snapshot;
  final bool isLoading;
  final ExpenseCurrency activeWallet;
  final String? message;

  BudgetState copyWith({
    BudgetSnapshot? snapshot,
    bool? isLoading,
    ExpenseCurrency? activeWallet,
    String? message,
    bool clearMessage = false,
  }) {
    return BudgetState(
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
      activeWallet: activeWallet ?? this.activeWallet,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [snapshot, isLoading, activeWallet, message];
}

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit({
    required BudgetRepository budgetRepository,
    required FxRatesRepository fxRatesRepository,
  })  : _budgetRepository = budgetRepository,
        _fxRatesRepository = fxRatesRepository,
        super(const BudgetState());

  final BudgetRepository _budgetRepository;
  final FxRatesRepository _fxRatesRepository;
  final _uuid = const Uuid();
  StreamSubscription<FxRates>? _ratesSub;

  Future<void> init() async {
    await refresh();
    _ratesSub = _fxRatesRepository.watchRates().listen((_) => refresh());
  }

  Future<void> refresh() async {
    final configR = await _budgetRepository.getConfig();
    final exchR = await _budgetRepository.getExchanges();
    final expR = await _budgetRepository.getExpenses();
    final ratesR = await _fxRatesRepository.getRates();

    if (configR.isLeft() ||
        exchR.isLeft() ||
        expR.isLeft() ||
        ratesR.isLeft()) {
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Failed to load budget data',
        ),
      );
      return;
    }

    final snapshot = BudgetSnapshot(
      config: configR.getOrElse(() => const BudgetConfig()),
      exchanges: exchR.getOrElse(() => const []),
      expenses: expR.getOrElse(() => const []),
      rates: ratesR.getOrElse(() => FxRates.defaults),
    );
    emit(state.copyWith(snapshot: snapshot, isLoading: false));
  }

  void setWallet(ExpenseCurrency currency) {
    emit(state.copyWith(activeWallet: currency));
  }

  Future<void> configureBudget({
    required double initialUsd,
    required double initialVnd,
  }) async {
    final config = BudgetConfig(
      initialUsd: initialUsd,
      initialVnd: initialVnd,
      configured: true,
    );
    final result = await _budgetRepository.saveConfig(config);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) => refresh(),
    );
  }

  Future<void> addExchange({
    required double usdAmount,
    required double vndReceived,
    required DateTime date,
    String note = '',
    String? id,
  }) async {
    final record = ExchangeRecord(
      id: id ?? _uuid.v4(),
      usdAmount: usdAmount,
      vndReceived: vndReceived,
      date: date,
      note: note,
    );
    final result = await _budgetRepository.upsertExchange(record);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) {
        emit(state.copyWith(message: 'Exchange saved'));
        refresh();
      },
    );
  }

  Future<void> deleteExchange(String id) async {
    final result = await _budgetRepository.deleteExchange(id);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) => refresh(),
    );
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required ExpenseCurrency currency,
    required DateTime date,
    String note = '',
    String? id,
  }) async {
    final record = ExpenseRecord(
      id: id ?? _uuid.v4(),
      title: title.trim(),
      amount: amount,
      currency: currency,
      date: date,
      note: note,
    );
    final result = await _budgetRepository.upsertExpense(record);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) {
        emit(state.copyWith(message: 'Expense saved'));
        refresh();
      },
    );
  }

  Future<void> deleteExpense(String id) async {
    final result = await _budgetRepository.deleteExpense(id);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) => refresh(),
    );
  }

  /// Suggested per-day spend in USD equivalent.
  double? suggestedPerDayUsd() {
    final snap = state.snapshot;
    if (snap == null) return null;
    final days = TripDates.remainingDays();
    if (days <= 0) return null;
    return snap.remainingUsdEquivalent / days;
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));

  @override
  Future<void> close() {
    _ratesSub?.cancel();
    return super.close();
  }
}
