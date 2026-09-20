import 'package:equatable/equatable.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';

class TippingRatePreset extends Equatable {
  const TippingRatePreset({
    required this.id,
    required this.label,
    required this.rates,
  });

  final String id;
  final String label;
  final FxRates rates;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    ...rates.toJson(),
  };

  factory TippingRatePreset.fromJson(Map<dynamic, dynamic> json) {
    return TippingRatePreset(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? 'Saved rate',
      rates: FxRates.fromJson(json),
    );
  }

  @override
  List<Object?> get props => [id, label, rates];
}

class TippingFxOverride extends Equatable {
  const TippingFxOverride({required this.rates, this.presetId});

  final FxRates rates;
  final String? presetId;

  Map<String, dynamic> toJson() => {
    ...rates.toJson(),
    if (presetId != null) 'presetId': presetId,
  };

  factory TippingFxOverride.fromJson(Map<dynamic, dynamic> json) {
    final id = json['presetId'] as String?;
    return TippingFxOverride(
      rates: FxRates.fromJson(json),
      presetId: (id == null || id.isEmpty) ? null : id,
    );
  }

  @override
  List<Object?> get props => [rates, presetId];
}
