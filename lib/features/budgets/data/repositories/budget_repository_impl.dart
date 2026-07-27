import 'package:injectable/injectable.dart';

import '../../domain/entities/budget_item.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';

@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource _localDataSource;

  BudgetRepositoryImpl(this._localDataSource);

  @override
  Future<List<BudgetItem>> getBudgets() => _localDataSource.getBudgets();

  @override
  Future<int> setBudget({
    int? categoryId,
    required double targetAmount,
  }) =>
      _localDataSource.setBudget(
        categoryId: categoryId,
        targetAmount: targetAmount,
      );

  @override
  Future<void> deleteBudget(int id) => _localDataSource.deleteBudget(id);
}
