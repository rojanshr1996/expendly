import 'package:injectable/injectable.dart';

import '../../domain/entities/budget_item.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';

import '../../../../core/database/enums/database_enums.dart';

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
    BudgetPeriod period = BudgetPeriod.monthly,
    bool notifyAtThreshold = true,
    int thresholdPercentage = 80,
  }) =>
      _localDataSource.setBudget(
        categoryId: categoryId,
        targetAmount: targetAmount,
        period: period,
        notifyAtThreshold: notifyAtThreshold,
        thresholdPercentage: thresholdPercentage,
      );

  @override
  Future<void> deleteBudget(int id) => _localDataSource.deleteBudget(id);
}
