import 'package:dartz/dartz.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/features/checklist/domain/entities/checklist_item.dart';

abstract class ChecklistRepository {
  Future<Either<Failure, List<ChecklistItem>>> getAll();
  Future<Either<Failure, List<ChecklistItem>>> getByDay(int day);
  Future<Either<Failure, Unit>> upsert(ChecklistItem item);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, Unit>> seedIfEmpty();
}
