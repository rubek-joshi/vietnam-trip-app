import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/core/storage/hive_boxes.dart';
import 'package:vietnam_handbook/features/budget/domain/entities/budget_entities.dart';
import 'package:vietnam_handbook/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required Box<dynamic> configBox,
    required Box<dynamic> exchangesBox,
    required Box<dynamic> expensesBox,
  })  : _configBox = configBox,
        _exchangesBox = exchangesBox,
        _expensesBox = expensesBox;

  final Box<dynamic> _configBox;
  final Box<dynamic> _exchangesBox;
  final Box<dynamic> _expensesBox;

  static const _configKey = 'config';

  @override
  Future<Either<Failure, BudgetConfig>> getConfig() async {
    try {
      final raw = _configBox.get(_configKey);
      if (raw is Map) {
        return Right(BudgetConfig.fromJson(Map<dynamic, dynamic>.from(raw)));
      }
      return const Right(BudgetConfig());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveConfig(BudgetConfig config) async {
    try {
      await _configBox.put(_configKey, config.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExchangeRecord>>> getExchanges() async {
    try {
      final items = _exchangesBox.values
          .whereType<Map>()
          .map((e) => ExchangeRecord.fromJson(Map<dynamic, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(items);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertExchange(ExchangeRecord record) async {
    try {
      await _exchangesBox.put(record.id, record.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExchange(String id) async {
    try {
      await _exchangesBox.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseRecord>>> getExpenses() async {
    try {
      final items = _expensesBox.values
          .whereType<Map>()
          .map((e) => ExpenseRecord.fromJson(Map<dynamic, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(items);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertExpense(ExpenseRecord record) async {
    try {
      await _expensesBox.put(record.id, record.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpense(String id) async {
    try {
      await _expensesBox.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

Future<(Box, Box, Box)> openBudgetBoxes() async {
  final config = await Hive.openBox<dynamic>(HiveBoxes.budgetConfig);
  final exchanges = await Hive.openBox<dynamic>(HiveBoxes.exchanges);
  final expenses = await Hive.openBox<dynamic>(HiveBoxes.expenses);
  return (config, exchanges, expenses);
}
