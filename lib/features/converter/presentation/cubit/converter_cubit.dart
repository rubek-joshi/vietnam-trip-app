import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/converter/domain/entities/saved_conversion.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/conversion_history_repository.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/fx_rates_repository.dart';
import 'package:vietnam_handbook/features/converter/domain/usecases/convert_currency.dart';

class ConverterState extends Equatable {
  const ConverterState({
    this.rates = FxRates.defaults,
    this.usd = 0,
    this.npr = 0,
    this.vnd = 0,
    this.source = CurrencyCode.usd,
    this.history = const [],
    this.sortField = ConversionSortField.amount,
    this.sortDirection = SortDirection.descending,
    this.isLoading = true,
    this.message,
  });

  final FxRates rates;
  final double usd;
  final double npr;
  final double vnd;
  final CurrencyCode source;
  final List<SavedConversion> history;
  final ConversionSortField sortField;
  final SortDirection sortDirection;
  final bool isLoading;
  final String? message;

  List<SavedConversion> get sortedHistory {
    final list = [...history];
    list.sort((a, b) {
      int cmp;
      if (sortField == ConversionSortField.label) {
        cmp = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      } else {
        cmp = a.usd.compareTo(b.usd);
      }
      return sortDirection == SortDirection.ascending ? cmp : -cmp;
    });
    return list;
  }

  ConverterState copyWith({
    FxRates? rates,
    double? usd,
    double? npr,
    double? vnd,
    CurrencyCode? source,
    List<SavedConversion>? history,
    ConversionSortField? sortField,
    SortDirection? sortDirection,
    bool? isLoading,
    String? message,
    bool clearMessage = false,
  }) {
    return ConverterState(
      rates: rates ?? this.rates,
      usd: usd ?? this.usd,
      npr: npr ?? this.npr,
      vnd: vnd ?? this.vnd,
      source: source ?? this.source,
      history: history ?? this.history,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        rates,
        usd,
        npr,
        vnd,
        source,
        history,
        sortField,
        sortDirection,
        isLoading,
        message,
      ];
}

class ConverterCubit extends Cubit<ConverterState> {
  ConverterCubit({
    required FxRatesRepository fxRatesRepository,
    required ConversionHistoryRepository historyRepository,
    required ConvertCurrency convertCurrency,
  })  : _fxRatesRepository = fxRatesRepository,
        _historyRepository = historyRepository,
        _convertCurrency = convertCurrency,
        super(const ConverterState());

  final FxRatesRepository _fxRatesRepository;
  final ConversionHistoryRepository _historyRepository;
  final ConvertCurrency _convertCurrency;
  final _uuid = const Uuid();
  StreamSubscription<FxRates>? _ratesSub;

  Future<void> init() async {
    final ratesResult = await _fxRatesRepository.getRates();
    final rates = ratesResult.getOrElse(() => FxRates.defaults);
    await _loadHistory();
    emit(state.copyWith(rates: rates, isLoading: false));
    _ratesSub = _fxRatesRepository.watchRates().listen((r) {
      final amount = switch (state.source) {
        CurrencyCode.usd => state.usd,
        CurrencyCode.npr => state.npr,
        CurrencyCode.vnd => state.vnd,
      };
      _recalculate(amount, state.source, rates: r);
    });
  }

  Future<void> _loadHistory() async {
    final result = await _historyRepository.getAll();
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (items) => emit(state.copyWith(history: items)),
    );
  }

  void updateAmount(String raw, CurrencyCode from) {
    final amount = double.tryParse(raw.replaceAll(',', '')) ?? 0;
    _recalculate(amount, from);
  }

  void _recalculate(
    double amount,
    CurrencyCode from, {
    FxRates? rates,
  }) {
    final r = rates ?? state.rates;
    final triplet = _convertCurrency(amount: amount, from: from, rates: r);
    emit(
      state.copyWith(
        rates: r,
        usd: triplet.usd,
        npr: triplet.npr,
        vnd: triplet.vnd,
        source: from,
      ),
    );
  }

  Future<void> saveCurrent(String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(message: 'Enter a label to save'));
      return;
    }
    final item = SavedConversion(
      id: _uuid.v4(),
      label: trimmed,
      usd: state.usd,
      npr: state.npr,
      vnd: state.vnd,
      createdAt: DateTime.now(),
    );
    final result = await _historyRepository.save(item);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) {
        emit(
          state.copyWith(
            history: [...state.history, item],
            message: 'Saved "$trimmed"',
          ),
        );
      },
    );
  }

  Future<void> updateSaved(SavedConversion item) async {
    final result = await _historyRepository.update(item);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) {
        final list = state.history
            .map((e) => e.id == item.id ? item : e)
            .toList();
        emit(state.copyWith(history: list, message: 'Updated'));
      },
    );
  }

  Future<void> deleteSaved(String id) async {
    final result = await _historyRepository.delete(id);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) {
        emit(
          state.copyWith(
            history: state.history.where((e) => e.id != id).toList(),
            message: 'Deleted',
          ),
        );
      },
    );
  }

  void setSort({
    ConversionSortField? field,
    SortDirection? direction,
  }) {
    emit(
      state.copyWith(
        sortField: field,
        sortDirection: direction,
      ),
    );
  }

  Future<void> updateRates(FxRates rates) async {
    final result = await _fxRatesRepository.saveRates(rates);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) {
        final amount = switch (state.source) {
          CurrencyCode.usd => state.usd,
          CurrencyCode.npr => state.npr,
          CurrencyCode.vnd => state.vnd,
        };
        _recalculate(amount, state.source, rates: rates);
        emit(state.copyWith(message: 'Rates updated'));
      },
    );
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));

  @override
  Future<void> close() {
    _ratesSub?.cancel();
    return super.close();
  }
}
