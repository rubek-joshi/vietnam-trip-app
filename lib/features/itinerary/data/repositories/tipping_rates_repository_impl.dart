import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/core/storage/hive_boxes.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/tipping_rate_preset.dart';
import 'package:vietnam_handbook/features/itinerary/domain/repositories/tipping_rates_repository.dart';

class TippingRatesRepositoryImpl implements TippingRatesRepository {
  TippingRatesRepositoryImpl(this._box);

  final Box<dynamic> _box;

  static const _activeKey = 'active';
  static const _presetsKey = 'presets';

  @override
  Future<Either<Failure, TippingFxOverride?>> getActiveOverride() async {
    try {
      final raw = _box.get(_activeKey);
      if (raw is Map) {
        return Right(
          TippingFxOverride.fromJson(Map<dynamic, dynamic>.from(raw)),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveActiveOverride(
    TippingFxOverride override,
  ) async {
    try {
      await _box.put(_activeKey, override.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearActiveOverride() async {
    try {
      await _box.delete(_activeKey);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TippingRatePreset>>> getPresets() async {
    try {
      final raw = _box.get(_presetsKey);
      if (raw is! List) return const Right([]);
      return Right(
        raw
            .whereType<Map>()
            .map(
              (item) =>
                  TippingRatePreset.fromJson(Map<dynamic, dynamic>.from(item)),
            )
            .where((preset) => preset.id.isNotEmpty)
            .toList(),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePresets(
    List<TippingRatePreset> presets,
  ) async {
    try {
      await _box.put(
        _presetsKey,
        presets.map((preset) => preset.toJson()).toList(),
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

Future<Box<dynamic>> openTippingRatesBox() =>
    Hive.openBox<dynamic>(HiveBoxes.tippingRates);
