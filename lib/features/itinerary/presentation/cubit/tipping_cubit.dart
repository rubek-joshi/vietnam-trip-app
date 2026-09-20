import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/fx_rates_repository.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/itinerary_data.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/tipping_rate_preset.dart';
import 'package:vietnam_handbook/features/itinerary/domain/repositories/tipping_rates_repository.dart';

class TippingState extends Equatable {
  const TippingState({
    this.perPersonUsd = TippingCubit.halfDayUsd,
    this.pax = TippingCubit.defaultPax,
    this.appRates = FxRates.defaults,
    this.overrideRates,
    this.activePresetId,
    this.presets = const [],
    this.isLoading = true,
  });

  final double perPersonUsd;
  final int pax;
  final FxRates appRates;
  final FxRates? overrideRates;
  final String? activePresetId;
  final List<TippingRatePreset> presets;
  final bool isLoading;

  bool get isOverridden => overrideRates != null;

  FxRates get rates => overrideRates ?? appRates;

  String get rateSourceLabel {
    if (!isOverridden) return 'App FX rates';
    if (activePresetId != null) {
      for (final preset in presets) {
        if (preset.id == activePresetId) return preset.label;
      }
    }
    return 'Page override';
  }

  double get totalUsd => perPersonUsd * pax;

  double get totalVnd => rates.fromUsd(totalUsd, CurrencyCode.vnd);

  double get totalNpr => rates.fromUsd(totalUsd, CurrencyCode.npr);

  bool isPreset(double amount) => (perPersonUsd - amount).abs() < 0.0001;

  TippingState copyWith({
    double? perPersonUsd,
    int? pax,
    FxRates? appRates,
    FxRates? overrideRates,
    bool clearOverride = false,
    String? activePresetId,
    bool clearActivePresetId = false,
    List<TippingRatePreset>? presets,
    bool? isLoading,
  }) {
    return TippingState(
      perPersonUsd: perPersonUsd ?? this.perPersonUsd,
      pax: pax ?? this.pax,
      appRates: appRates ?? this.appRates,
      overrideRates: clearOverride
          ? null
          : (overrideRates ?? this.overrideRates),
      activePresetId: clearActivePresetId
          ? null
          : (activePresetId ?? this.activePresetId),
      presets: presets ?? this.presets,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    perPersonUsd,
    pax,
    appRates,
    overrideRates,
    activePresetId,
    presets,
    isLoading,
  ];
}

class TippingCubit extends Cubit<TippingState> {
  TippingCubit({
    required FxRatesRepository fxRatesRepository,
    required TippingRatesRepository tippingRatesRepository,
  }) : _fxRatesRepository = fxRatesRepository,
       _tippingRatesRepository = tippingRatesRepository,
       super(const TippingState());

  static const halfDayUsd = 1.5;
  static const fullDayUsd = 3.0;
  static const defaultPax = PackageCosts.groupSize;
  static const minPax = 1;
  static const maxPax = 99;

  final FxRatesRepository _fxRatesRepository;
  final TippingRatesRepository _tippingRatesRepository;
  final _uuid = const Uuid();
  StreamSubscription<FxRates>? _ratesSub;

  Future<void> init() async {
    final appResult = await _fxRatesRepository.getRates();
    final appRates = appResult.getOrElse(() => FxRates.defaults);
    final overrideResult = await _tippingRatesRepository.getActiveOverride();
    final override = overrideResult.getOrElse(() => null);
    final presetsResult = await _tippingRatesRepository.getPresets();
    final presets = presetsResult.getOrElse(() => const []);

    emit(
      state.copyWith(
        appRates: appRates,
        overrideRates: override?.rates,
        activePresetId: override?.presetId,
        presets: presets,
        isLoading: false,
      ),
    );

    _ratesSub = _fxRatesRepository.watchRates().listen((rates) {
      emit(state.copyWith(appRates: rates));
    });
  }

  void incrementPax() {
    if (state.pax >= maxPax) return;
    emit(state.copyWith(pax: state.pax + 1));
  }

  void decrementPax() {
    if (state.pax <= minPax) return;
    emit(state.copyWith(pax: state.pax - 1));
  }

  void setPerPersonUsd(double amount) {
    if (amount < 0) return;
    emit(state.copyWith(perPersonUsd: amount));
  }

  void setPerPersonFromInput(String raw) {
    final parsed = double.tryParse(raw.replaceAll(',', '').trim());
    setPerPersonUsd(parsed ?? 0);
  }

  Future<void> applyOverride(FxRates rates, {String? saveAsLabel}) async {
    var presets = List<TippingRatePreset>.from(state.presets);
    String? presetId;
    final label = saveAsLabel?.trim();
    if (label != null && label.isNotEmpty) {
      final preset = TippingRatePreset(
        id: _uuid.v4(),
        label: label,
        rates: rates,
      );
      presets = [...presets, preset];
      await _tippingRatesRepository.savePresets(presets);
      presetId = preset.id;
    }

    await _tippingRatesRepository.saveActiveOverride(
      TippingFxOverride(rates: rates, presetId: presetId),
    );
    emit(
      state.copyWith(
        overrideRates: rates,
        activePresetId: presetId,
        presets: presets,
        clearActivePresetId: presetId == null,
      ),
    );
  }

  Future<void> selectPreset(TippingRatePreset preset) async {
    await _tippingRatesRepository.saveActiveOverride(
      TippingFxOverride(rates: preset.rates, presetId: preset.id),
    );
    emit(
      state.copyWith(overrideRates: preset.rates, activePresetId: preset.id),
    );
  }

  Future<void> deletePreset(String id) async {
    final presets = state.presets.where((preset) => preset.id != id).toList();
    await _tippingRatesRepository.savePresets(presets);
    if (state.activePresetId == id) {
      await _tippingRatesRepository.saveActiveOverride(
        TippingFxOverride(rates: state.rates),
      );
      emit(state.copyWith(presets: presets, clearActivePresetId: true));
    } else {
      emit(state.copyWith(presets: presets));
    }
  }

  Future<void> clearOverride() async {
    await _tippingRatesRepository.clearActiveOverride();
    emit(state.copyWith(clearOverride: true, clearActivePresetId: true));
  }

  @override
  Future<void> close() {
    _ratesSub?.cancel();
    return super.close();
  }
}
