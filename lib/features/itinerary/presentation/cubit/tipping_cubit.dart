import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/fx_rates_repository.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/itinerary_data.dart';

class TippingState extends Equatable {
  const TippingState({
    this.perPersonUsd = TippingCubit.halfDayUsd,
    this.rates = FxRates.defaults,
    this.isLoading = true,
  });

  final double perPersonUsd;
  final FxRates rates;
  final bool isLoading;

  int get pax => PackageCosts.groupSize;

  double get totalUsd => perPersonUsd * pax;

  double get totalVnd => rates.fromUsd(totalUsd, CurrencyCode.vnd);

  double get totalNpr => rates.fromUsd(totalUsd, CurrencyCode.npr);

  bool isPreset(double amount) => (perPersonUsd - amount).abs() < 0.0001;

  TippingState copyWith({
    double? perPersonUsd,
    FxRates? rates,
    bool? isLoading,
  }) {
    return TippingState(
      perPersonUsd: perPersonUsd ?? this.perPersonUsd,
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [perPersonUsd, rates, isLoading];
}

class TippingCubit extends Cubit<TippingState> {
  TippingCubit(this._fxRatesRepository) : super(const TippingState());

  static const halfDayUsd = 1.5;
  static const fullDayUsd = 3.0;

  final FxRatesRepository _fxRatesRepository;
  StreamSubscription<FxRates>? _ratesSub;

  Future<void> init() async {
    final result = await _fxRatesRepository.getRates();
    final rates = result.getOrElse(() => FxRates.defaults);
    emit(state.copyWith(rates: rates, isLoading: false));
    _ratesSub = _fxRatesRepository.watchRates().listen((r) {
      emit(state.copyWith(rates: r));
    });
  }

  void setPerPersonUsd(double amount) {
    if (amount < 0) return;
    emit(state.copyWith(perPersonUsd: amount));
  }

  void setPerPersonFromInput(String raw) {
    final parsed = double.tryParse(raw.replaceAll(',', '').trim());
    setPerPersonUsd(parsed ?? 0);
  }

  @override
  Future<void> close() {
    _ratesSub?.cancel();
    return super.close();
  }
}
