import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/core/storage/hive_boxes.dart';
import 'package:vietnam_handbook/features/checklist/domain/entities/checklist_item.dart';
import 'package:vietnam_handbook/features/checklist/domain/repositories/checklist_repository.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  ChecklistRepositoryImpl(this._box);

  final Box<dynamic> _box;

  @override
  Future<Either<Failure, List<ChecklistItem>>> getAll() async {
    try {
      final items = _box.values
          .whereType<Map>()
          .map((e) => ChecklistItem.fromJson(Map<dynamic, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return Right(items);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChecklistItem>>> getByDay(int day) async {
    final all = await getAll();
    return all.map((items) => items.where((e) => e.day == day).toList());
  }

  @override
  Future<Either<Failure, Unit>> upsert(ChecklistItem item) async {
    try {
      await _box.put(item.id, item.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
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

  @override
  Future<Either<Failure, Unit>> seedIfEmpty() async {
    try {
      if (_box.isEmpty) {
        for (final item in seedChecklistItems()) {
          await _box.put(item.id, item.toJson());
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

Future<Box<dynamic>> openChecklistBox() =>
    Hive.openBox<dynamic>(HiveBoxes.checklistItems);
