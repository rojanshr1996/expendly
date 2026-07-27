import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../domain/entities/analytics_report.dart';

abstract class AnalyticsLocalDataSource {
  Future<AnalyticsReport> getAnalyticsReport();
}

@LazySingleton(as: AnalyticsLocalDataSource)
class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  final AppDatabase _db;

  AnalyticsLocalDataSourceImpl(this._db);

  @override
  Future<AnalyticsReport> getAnalyticsReport() async {
    final allTx = await _db.select(_db.transactions).get();
    final allCat = await _db.select(_db.categories).get();

    final catMap = {for (var c in allCat) c.id: c};

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    final categoryTotals = <int, double>{};

    for (final tx in allTx) {
      final double realAmount = tx.amount / 100.0;
      if (tx.type == TransactionType.income) {
        totalIncome += realAmount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += realAmount;
        categoryTotals[tx.categoryId] =
            (categoryTotals[tx.categoryId] ?? 0.0) + realAmount;
      }
    }

    final netSavings = totalIncome - totalExpense;
    final savingsRatePct = totalIncome > 0
        ? ((netSavings / totalIncome) * 100).clamp(0.0, 100.0)
        : 0.0;

    final breakdownList = <CategoryReportItem>[];
    categoryTotals.forEach((catId, sum) {
      final cat = catMap[catId];
      final pct = totalExpense > 0 ? (sum / totalExpense) * 100 : 0.0;
      breakdownList.add(
        CategoryReportItem(
          categoryName: cat?.name ?? 'Other',
          iconName: cat?.icon ?? 'category',
          colorHex: cat?.color ?? '#57F1DB',
          amount: sum,
          percentage: pct,
        ),
      );
    });

    breakdownList.sort((a, b) => b.amount.compareTo(a.amount));

    return AnalyticsReport(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRatePercentage: savingsRatePct,
      categoryBreakdowns: breakdownList,
    );
  }
}
