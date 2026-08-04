import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/preference_service.dart';
import '../../domain/entities/budget_item.dart';

abstract class BudgetLocalDataSource {
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

@LazySingleton(as: BudgetLocalDataSource)
class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final AppDatabase _db;

  BudgetLocalDataSourceImpl(this._db);

  @override
  Future<List<BudgetItem>> getBudgets() async {
    final budgetsList = await _db.select(_db.budgets).get();
    final categoriesList = await _db.select(_db.categories).get();
    final transactionsList = await _db.select(_db.transactions).get();

    final catMap = {for (var c in categoriesList) c.id: c};

    // Calculate total spending per category in current month
    final now = DateTime.now();
    final spendingByCat = <int, double>{};
    for (final tx in transactionsList) {
      if (tx.type == TransactionType.expense &&
          tx.timestamp.year == now.year &&
          tx.timestamp.month == now.month) {
        spendingByCat[tx.categoryId] =
            (spendingByCat[tx.categoryId] ?? 0.0) + (tx.amount / 100.0);
      }
    }

    final items = <BudgetItem>[];
    for (final b in budgetsList) {
      final cat = b.categoryId != null ? catMap[b.categoryId] : null;
      final spent = b.categoryId != null
          ? (spendingByCat[b.categoryId] ?? 0.0)
          : spendingByCat.values
              .fold(0.0, (previousValue, element) => previousValue + element);

      items.add(
        BudgetItem(
          id: b.id,
          categoryId: b.categoryId,
          categoryName: cat?.name ?? 'Overall Monthly Budget',
          categoryIcon: cat?.icon ?? 'account_balance_wallet',
          categoryColorHex: cat?.color ?? '#57F1DB',
          targetAmount: b.targetAmount / 100.0,
          spentAmount: spent,
          period: b.period,
          notifyAtThreshold: b.notifyAtThreshold,
          thresholdPercentage: b.thresholdPercentage,
        ),
      );
    }

    return items;
  }

  @override
  Future<int> setBudget({
    int? categoryId,
    required double targetAmount,
    BudgetPeriod period = BudgetPeriod.monthly,
    bool notifyAtThreshold = true,
    int thresholdPercentage = 80,
  }) async {
    final now = DateTime.now();
    final minorUnits = (targetAmount * 100).round();
    final currencyCode = getIt<PreferenceService>().currencyCode;

    // Check if budget for category exists
    final query = _db.select(_db.budgets);
    if (categoryId != null) {
      query.where((b) => b.categoryId.equals(categoryId));
    } else {
      query.where((b) => b.categoryId.isNull());
    }
    final existing = await query.getSingleOrNull();

    if (existing != null) {
      throw StateError('A budget already exists for this category.');
    } else {
      final allBudgets = await _db.select(_db.budgets).get();
      if (allBudgets.length >= 4) {
        throw StateError('Maximum limit of 4 budgets reached.');
      }
      return await _db.into(_db.budgets).insert(
            BudgetsCompanion.insert(
              categoryId: Value(categoryId),
              targetAmount: minorUnits,
              period: period,
              year: Value(now.year),
              month: Value(now.month),
              currencyCode: Value(currencyCode),
              notifyAtThreshold: Value(notifyAtThreshold),
              thresholdPercentage: Value(thresholdPercentage),
            ),
          );
    }
  }

  @override
  Future<void> deleteBudget(int id) async {
    await (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
  }
}
