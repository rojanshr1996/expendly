import '../entities/budget_item.dart';

abstract class BudgetRepository {
  Future<List<BudgetItem>> getBudgets();
  Future<int> setBudget({
    int? categoryId,
    required double targetAmount,
  });
  Future<void> deleteBudget(int id);
}
