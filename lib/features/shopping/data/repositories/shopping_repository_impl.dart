import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/core/storage/hive_boxes.dart';
import 'package:vietnam_handbook/features/shopping/domain/entities/shopping_item.dart';
import 'package:vietnam_handbook/features/shopping/domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  ShoppingRepositoryImpl(this._box);

  final Box<dynamic> _box;

  @override
  Future<Either<Failure, List<ShoppingItem>>> getAll() async {
    try {
      final items = _box.values
          .whereType<Map>()
          .map((e) => ShoppingItem.fromJson(Map<dynamic, dynamic>.from(e)))
          .toList();
      return Right(items);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<List<ShoppingItem>> watchAll() async* {
    yield (await getAll()).getOrElse(() => const []);
    yield* _box.watch().asyncMap((_) async {
      return (await getAll()).getOrElse(() => const []);
    });
  }

  @override
  Future<Either<Failure, Unit>> upsert(ShoppingItem item) async {
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
}

Future<Box<dynamic>> openShoppingBox() =>
    Hive.openBox<dynamic>(HiveBoxes.shoppingItems);
