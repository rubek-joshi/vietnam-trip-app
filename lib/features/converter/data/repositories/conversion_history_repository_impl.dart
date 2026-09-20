import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/core/storage/hive_boxes.dart';
import 'package:vietnam_handbook/features/converter/domain/entities/saved_conversion.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/conversion_history_repository.dart';

class ConversionHistoryRepositoryImpl implements ConversionHistoryRepository {
  ConversionHistoryRepositoryImpl(this._box);

  final Box<dynamic> _box;

  @override
  Future<Either<Failure, List<SavedConversion>>> getAll() async {
    try {
      final items = _box.values
          .whereType<Map>()
          .map((e) => SavedConversion.fromJson(Map<dynamic, dynamic>.from(e)))
          .toList();
      return Right(items);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> save(SavedConversion conversion) async {
    try {
      await _box.put(conversion.id, conversion.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> update(SavedConversion conversion) async {
    return save(conversion);
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _box.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

Future<Box<dynamic>> openSavedConversionsBox() =>
    Hive.openBox<dynamic>(HiveBoxes.savedConversions);
