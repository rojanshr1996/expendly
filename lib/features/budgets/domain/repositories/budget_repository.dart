import '../../../../core/database/enums/database_enums.dart';
import '../entities/budget_item.dart';

abstract class BudgetRepository {
  Future<List<BudgetItem>> getBudgets();
  Future<int> setBudget({
    int? categoryId,
    required double targetAmount,
    BudgetPeriod period = BudgetPeriod.monthly,
    bool notifyAtThreshold = true,
    int thresholdPercentage = 80,
  });
  Future<void> deleteBudget(int id);
}
