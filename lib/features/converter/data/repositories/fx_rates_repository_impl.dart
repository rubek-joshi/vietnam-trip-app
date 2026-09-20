import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/core/storage/hive_boxes.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/fx_rates_repository.dart';

class FxRatesRepositoryImpl implements FxRatesRepository {
  FxRatesRepositoryImpl(this._box);

  final Box<dynamic> _box;
  final _controller = StreamController<FxRates>.broadcast();

  static const _key = 'rates';

  @override
  Future<Either<Failure, FxRates>> getRates() async {
    try {
      final raw = _box.get(_key);
      if (raw is Map) {
        return Right(FxRates.fromJson(Map<dynamic, dynamic>.from(raw)));
      }
      await _box.put(_key, FxRates.defaults.toJson());
      return const Right(FxRates.defaults);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveRates(FxRates rates) async {
    try {
      await _box.put(_key, rates.toJson());
      _controller.add(rates);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<FxRates> watchRates() async* {
    final current = await getRates();
    yield current.getOrElse(() => FxRates.defaults);
    yield* _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}

Future<Box<dynamic>> openFxRatesBox() =>
    Hive.openBox<dynamic>(HiveBoxes.fxRates);
