import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/services/preference_service.dart';
import '../../domain/entities/financial_summary.dart';
import '../models/financial_summary_model.dart';

abstract class DashboardLocalDataSource {
  Future<FinancialSummaryModel> getFinancialSummary();
}

@LazySingleton(as: DashboardLocalDataSource)
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final AppDatabase _db;
  final PreferenceService _preferenceService;

  DashboardLocalDataSourceImpl(this._db, this._preferenceService);

  @override
  Future<FinancialSummaryModel> getFinancialSummary() async {
    final currencySymbol = _preferenceService.currencySymbol;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // Fetch all transactions from SQLite database
    final allTransactions = await _db.select(_db.transactions).get();
    final allCategories = await _db.select(_db.categories).get();

    final categoryMap = {for (var c in allCategories) c.id: c};

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final tx in allTransactions) {
      final double realAmount = tx.amount / 100.0;
      if (tx.type == TransactionType.income) {
        totalIncome += realAmount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += realAmount;
      }
    }

    final totalBalance = totalIncome - totalExpense;

    // Fetch recent 5 transactions ordered by timestamp descending
    final recentTxRows = await (_db.select(_db.transactions)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(5))
        .get();

    final recentItems = <DashboardTransactionItem>[];
    for (final tx in recentTxRows) {
      final cat = categoryMap[tx.categoryId];
      recentItems.add(
        DashboardTransactionItem(
          id: tx.id,
          title: tx.note?.isNotEmpty == true
              ? tx.note!
              : (cat?.name ?? 'Transaction'),
          categoryName: cat?.name ?? 'General',
          iconName: cat?.icon ?? 'receipt_long',
          colorHex: cat?.color ?? '#57F1DB',
          amount: tx.amount / 100.0,
          date: tx.timestamp,
          isIncome: tx.type == TransactionType.income,
        ),
      );
    }

    // Compute Category Spending Breakdown from user's expense transactions
    final categoryTotals = <String, Map<String, dynamic>>{};
    for (final tx
        in allTransactions.where((t) => t.type == TransactionType.expense)) {
      final cat = categoryMap[tx.categoryId];
      final catName = cat?.name ?? 'Other';
      final color = cat?.color ?? '#FB7185';
      final double realAmount = tx.amount / 100.0;
      if (!categoryTotals.containsKey(catName)) {
        categoryTotals[catName] = {'sum': 0.0, 'color': color};
      }
      categoryTotals[catName]!['sum'] =
          (categoryTotals[catName]!['sum'] as double) + realAmount;
    }

    final breakdowns = <DashboardCategoryShare>[];
    categoryTotals.forEach((name, data) {
      final sum = data['sum'] as double;
      final pct = totalExpense > 0 ? (sum / totalExpense) * 100 : 0.0;
      breakdowns.add(
        DashboardCategoryShare(
          categoryName: name,
          colorHex: data['color'] as String,
          amount: sum,
          percentage: pct,
        ),
      );
    });

    return FinancialSummaryModel(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      monthlyBudgetLimit: 5000.0,
      currencySymbol: currencySymbol,
      periodStart: firstDayOfMonth,
      periodEnd: now,
      recentTransactions: recentItems,
      categoryBreakdowns: breakdowns,
    );
  }
}
