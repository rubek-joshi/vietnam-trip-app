import 'package:dartz/dartz.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';

abstract class FxRatesRepository {
  Future<Either<Failure, FxRates>> getRates();
  Future<Either<Failure, Unit>> saveRates(FxRates rates);
  Stream<FxRates> watchRates();
}
