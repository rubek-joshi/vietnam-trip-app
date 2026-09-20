import 'package:dartz/dartz.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/features/shopping/domain/entities/shopping_item.dart';

abstract class ShoppingRepository {
  Future<Either<Failure, List<ShoppingItem>>> getAll();

  Stream<List<ShoppingItem>> watchAll();

  Future<Either<Failure, Unit>> upsert(ShoppingItem item);
  Future<Either<Failure, Unit>> delete(String id);
}
