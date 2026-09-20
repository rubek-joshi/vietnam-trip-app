import 'package:dartz/dartz.dart';
import 'package:vietnam_handbook/core/error/failures.dart';
import 'package:vietnam_handbook/features/budget/domain/entities/budget_entities.dart';

abstract class BudgetRepository {
  Future<Either<Failure, BudgetConfig>> getConfig();
  Future<Either<Failure, Unit>> saveConfig(BudgetConfig config);
  Future<Either<Failure, List<ExchangeRecord>>> getExchanges();
  Future<Either<Failure, Unit>> upsertExchange(ExchangeRecord record);
  Future<Either<Failure, Unit>> deleteExchange(String id);
  Future<Either<Failure, List<ExpenseRecord>>> getExpenses();
  Future<Either<Failure, Unit>> upsertExpense(ExpenseRecord record);
  Future<Either<Failure, Unit>> deleteExpense(String id);
}
