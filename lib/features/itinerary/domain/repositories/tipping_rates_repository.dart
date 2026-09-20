import 'package:dartz/dartz.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/tipping_rate_preset.dart';

abstract class TippingRatesRepository {
  Future<Either<Failure, TippingFxOverride?>> getActiveOverride();

  Future<Either<Failure, Unit>> saveActiveOverride(TippingFxOverride override);

  Future<Either<Failure, Unit>> clearActiveOverride();

  Future<Either<Failure, List<TippingRatePreset>>> getPresets();

  Future<Either<Failure, Unit>> savePresets(List<TippingRatePreset> presets);
}
