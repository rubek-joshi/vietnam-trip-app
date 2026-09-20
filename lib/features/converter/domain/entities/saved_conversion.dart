import 'package:equatable/equatable.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';

class SavedConversion extends Equatable {
  const SavedConversion({
    required this.id,
    required this.label,
    required this.usd,
    required this.npr,
    required this.vnd,
    required this.createdAt,
  });

  final String id;
  final String label;
  final double usd;
  final double npr;
  final double vnd;
  final DateTime createdAt;

  SavedConversion copyWith({
    String? id,
    String? label,
    double? usd,
    double? npr,
    double? vnd,
    DateTime? createdAt,
  }) {
    return SavedConversion(
      id: id ?? this.id,
      label: label ?? this.label,
      usd: usd ?? this.usd,
      npr: npr ?? this.npr,
      vnd: vnd ?? this.vnd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'usd': usd,
        'npr': npr,
        'vnd': vnd,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedConversion.fromJson(Map<dynamic, dynamic> json) {
    return SavedConversion(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      usd: (json['usd'] as num).toDouble(),
      npr: (json['npr'] as num).toDouble(),
      vnd: (json['vnd'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, label, usd, npr, vnd, createdAt];
}

enum ConversionSortField { label, amount }

enum SortDirection { ascending, descending }

class ConversionTriplet extends Equatable {
  const ConversionTriplet({
    required this.usd,
    required this.npr,
    required this.vnd,
    required this.source,
  });

  final double usd;
  final double npr;
  final double vnd;
  final CurrencyCode source;

  @override
  List<Object?> get props => [usd, npr, vnd, source];
}
