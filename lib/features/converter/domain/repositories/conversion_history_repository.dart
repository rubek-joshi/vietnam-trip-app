import 'package:dartz/dartz.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/features/converter/domain/entities/saved_conversion.dart';

abstract class ConversionHistoryRepository {
  Future<Either<Failure, List<SavedConversion>>> getAll();
  Future<Either<Failure, Unit>> save(SavedConversion conversion);
  Future<Either<Failure, Unit>> update(SavedConversion conversion);
  Future<Either<Failure, Unit>> delete(String id);
}
