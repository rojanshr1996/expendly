import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/preference_service.dart';
import '../../domain/entities/analytics_report.dart';

abstract class AnalyticsLocalDataSource {
  Future<AnalyticsReport> getAnalyticsReport({
    String period = 'Monthly',
    DateTimeRange? customRange,
  });
}

@LazySingleton(as: AnalyticsLocalDataSource)
class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  final AppDatabase _db;

  AnalyticsLocalDataSourceImpl(this._db);

  @override
  Future<AnalyticsReport> getAnalyticsReport({
    String period = 'Monthly',
    DateTimeRange? customRange,
  }) async {
    final allTx = await _db.select(_db.transactions).get();
    final allCat = await _db.select(_db.categories).get();
    final allBudgets = await _db.select(_db.budgets).get();

    final catMap = {for (var c in allCat) c.id: c};

    final now = DateTime.now();

    // Smart date reference anchor:
    // If allTx contains records, anchor relative to data timestamps if current month has no records
    final refDate = allTx.isNotEmpty
        ? (allTx.any((t) =>
                t.timestamp.year == now.year && t.timestamp.month == now.month)
            ? now
            : allTx
                .map((t) => t.timestamp)
                .reduce((a, b) => a.isAfter(b) ? a : b))
        : now;

    DateTime startDate;
    DateTime endDate;

    if (period == 'Weekly') {
      final monday = refDate.subtract(Duration(days: refDate.weekday - 1));
      startDate = DateTime(monday.year, monday.month, monday.day, 0, 0, 0);
      endDate = DateTime(monday.year, monday.month, monday.day, 23, 59, 59)
          .add(const Duration(days: 6));
    } else if (period == 'Yearly') {
      startDate = DateTime(refDate.year, 1, 1, 0, 0, 0);
      endDate = DateTime(refDate.year, 12, 31, 23, 59, 59);
    } else if (period == 'Custom' && customRange != null) {
      startDate = DateTime(customRange.start.year, customRange.start.month,
          customRange.start.day, 0, 0, 0);
      endDate = DateTime(customRange.end.year, customRange.end.month,
          customRange.end.day, 23, 59, 59);
    } else {
      // Monthly default
      startDate = DateTime(refDate.year, refDate.month, 1, 0, 0, 0);
      final lastDay = DateTime(refDate.year, refDate.month + 1, 0).day;
      endDate = DateTime(refDate.year, refDate.month, lastDay, 23, 59, 59);
    }

    // Filter transactions within selected period
    final filteredTx = allTx.where((tx) {
      return tx.timestamp
              .isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          tx.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final categoryTotals = <int, double>{};

    for (final tx in filteredTx) {
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

    // Days count for avg daily spend
    final periodDays = endDate.difference(startDate).inDays + 1;
    final daysCount = periodDays > 0 ? periodDays : 1;
    final avgDailySpend = totalExpense / daysCount;

    // Calculate budget health
    double totalBudget = 0.0;
    for (final b in allBudgets) {
      totalBudget += b.targetAmount / 100.0;
    }
    double budgetHealthPct = 85.0;
    String budgetHealthStatus = 'STABLE';

    if (totalBudget > 0) {
      final usedPct = (totalExpense / totalBudget) * 100;
      budgetHealthPct = (100 - usedPct).clamp(0.0, 100.0);
      if (budgetHealthPct >= 70) {
        budgetHealthStatus = 'STABLE';
      } else if (budgetHealthPct >= 40) {
        budgetHealthStatus = 'OPTIMAL';
      } else {
        budgetHealthStatus = 'WARNING';
      }
    } else {
      budgetHealthPct = savingsRatePct > 0 ? savingsRatePct : 75.0;
    }

    // Category breakdown list
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

    String? topCatName;
    double? topCatPct;
    String? topCatDesc;
    if (breakdownList.isNotEmpty) {
      final topItem = breakdownList.first;
      topCatName = topItem.categoryName;
      topCatPct = topItem.percentage;

      final currencySymbol = getIt.isRegistered<PreferenceService>()
          ? getIt<PreferenceService>().currencySymbol
          : '\$';

      final netStatusText = netSavings >= 0
          ? 'You maintain a positive cash flow of $currencySymbol${netSavings.abs().toStringAsFixed(2)} (${savingsRatePct.toStringAsFixed(1)}% savings rate). Controlling spending in ${topItem.categoryName} will help optimize your savings trajectory.'
          : 'Expenses exceed income by $currencySymbol${netSavings.abs().toStringAsFixed(2)}. Reducing spending in ${topItem.categoryName} is strongly recommended to return to a balanced cash flow.';

      topCatDesc =
          '${topItem.categoryName} is your highest spending category for this $period period, accounting for ${topItem.percentage.toStringAsFixed(1)}% ($currencySymbol${topItem.amount.toStringAsFixed(2)}) of your total spending ($currencySymbol${totalExpense.toStringAsFixed(2)}).\n\n'
          '• Daily Burn: Averaging $currencySymbol${avgDailySpend.toStringAsFixed(2)}/day over $daysCount day(s).\n'
          '• Trend & Strategy: $netStatusText';
    } else {
      topCatDesc =
          'No spending recorded for this $period period. Your budget remains balanced with zero outflow.';
    }

    // Generate Period Flow Bar Graph Items based on period
    final dailyFlows = _generateFlowBars(
      period: period,
      filteredTx: filteredTx,
      startDate: startDate,
      endDate: endDate,
    );

    return AnalyticsReport(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRatePercentage: savingsRatePct,
      avgDailySpend: avgDailySpend,
      avgDailySpendChangePct: 4.2,
      budgetHealthPercentage: budgetHealthPct,
      budgetHealthStatus: budgetHealthStatus,
      topCategoryName: topCatName,
      topCategoryPercentage: topCatPct,
      topCategoryDesc: topCatDesc,
      categoryBreakdowns: breakdownList,
      dailyFlows: dailyFlows,
      periodName: period,
    );
  }

  List<DailyFlowItem> _generateFlowBars({
    required String period,
    required List<dynamic> filteredTx,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    List<String> labels = [];
    Map<int, double> flowTotals = {};

    if (period == 'Weekly') {
      labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (final tx in filteredTx) {
        if (tx.type == TransactionType.expense) {
          final key = tx.timestamp.weekday; // 1 to 7
          flowTotals[key] = (flowTotals[key] ?? 0.0) + (tx.amount / 100.0);
        }
      }
    } else if (period == 'Yearly') {
      labels = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      for (final tx in filteredTx) {
        if (tx.type == TransactionType.expense) {
          final key = tx.timestamp.month; // 1 to 12
          flowTotals[key] = (flowTotals[key] ?? 0.0) + (tx.amount / 100.0);
        }
      }
    } else if (period == 'Custom') {
      final daysDiff = endDate.difference(startDate).inDays;
      if (daysDiff <= 7) {
        labels = [
          'Day 1',
          'Day 2',
          'Day 3',
          'Day 4',
          'Day 5',
          'Day 6',
          'Day 7'
        ];
        for (final tx in filteredTx) {
          if (tx.type == TransactionType.expense) {
            final key =
                (tx.timestamp.difference(startDate).inDays + 1).clamp(1, 7);
            flowTotals[key] = (flowTotals[key] ?? 0.0) + (tx.amount / 100.0);
          }
        }
      } else {
        labels = ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'];
        for (final tx in filteredTx) {
          if (tx.type == TransactionType.expense) {
            final weekNum = ((tx.timestamp.day - 1) ~/ 7) + 1;
            final key = weekNum.clamp(1, 4);
            flowTotals[key] = (flowTotals[key] ?? 0.0) + (tx.amount / 100.0);
          }
        }
      }
    } else {
      // Monthly default (4 weeks)
      labels = ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'];
      for (final tx in filteredTx) {
        if (tx.type == TransactionType.expense) {
          final weekNum = ((tx.timestamp.day - 1) ~/ 7) + 1;
          final key = weekNum.clamp(1, 4);
          flowTotals[key] = (flowTotals[key] ?? 0.0) + (tx.amount / 100.0);
        }
      }
    }

    double maxAmount = 0.0;
    for (int i = 1; i <= labels.length; i++) {
      final amt = flowTotals[i] ?? 0.0;
      if (amt > maxAmount) maxAmount = amt;
    }

    final result = <DailyFlowItem>[];
    for (int i = 1; i <= labels.length; i++) {
      final amt = flowTotals[i] ?? 0.0;
      final ratio = maxAmount > 0 ? (amt / maxAmount).clamp(0.12, 1.0) : 0.15;
      final isPeak = maxAmount > 0 && amt == maxAmount;
      result.add(
        DailyFlowItem(
          label: labels[i - 1],
          amount: amt,
          heightRatio: ratio,
          isPeak: isPeak,
        ),
      );
    }
    return result;
  }
}
