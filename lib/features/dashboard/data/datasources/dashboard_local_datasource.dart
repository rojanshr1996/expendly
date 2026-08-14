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
      } else if (tx.type == TransactionType.transfer) {
        totalExpense += _parseTransferFeeFromNote(tx.note);
      }
    }

    final totalBalance = totalIncome - totalExpense;

    // Fetch recent 5 transactions ordered by timestamp descending and id descending
    final recentTxRows = await (_db.select(_db.transactions)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(5))
        .get();

    final recentItems = <DashboardTransactionItem>[];
    for (final tx in recentTxRows) {
      final cat = categoryMap[tx.categoryId];
      recentItems.add(
        DashboardTransactionItem(
          id: tx.id,
          categoryId: tx.categoryId,
          title: cat?.name ?? 'Transaction',
          categoryName: cat?.name ?? 'General',
          note: tx.note,
          iconName: cat?.icon ?? 'receipt_long',
          colorHex: cat?.color ?? '#57F1DB',
          amount: tx.amount / 100.0,
          date: tx.timestamp,
          type: tx.type,
          isIncome: tx.type == TransactionType.income,
        ),
      );
    }

    // Compute Category Spending Breakdown from user's expense transactions and transfer fees
    final categoryTotals = <String, Map<String, dynamic>>{};
    for (final tx in allTransactions) {
      if (tx.type == TransactionType.expense) {
        final cat = categoryMap[tx.categoryId];
        final catName = cat?.name ?? 'Other';
        final color = cat?.color ?? '#FB7185';
        final double realAmount = tx.amount / 100.0;
        if (!categoryTotals.containsKey(catName)) {
          categoryTotals[catName] = {'sum': 0.0, 'color': color};
        }
        categoryTotals[catName]!['sum'] =
            (categoryTotals[catName]!['sum'] as double) + realAmount;
      } else if (tx.type == TransactionType.transfer) {
        final fee = _parseTransferFeeFromNote(tx.note);
        if (fee > 0) {
          final cat = categoryMap[tx.categoryId];
          final catName = cat?.name ?? 'Transfer Fee';
          final color = cat?.color ?? '#9333EA';
          if (!categoryTotals.containsKey(catName)) {
            categoryTotals[catName] = {'sum': 0.0, 'color': color};
          }
          categoryTotals[catName]!['sum'] =
              (categoryTotals[catName]!['sum'] as double) + fee;
        }
      }
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

    // Compute daily cash flow for the last 180 days (6 months)
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 180));
    final dailyMap = <String, Map<String, double>>{};

    for (final tx in allTransactions) {
      final date = tx.timestamp;
      if (date.isAfter(startDate)) {
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final amount = tx.amount / 100.0;
        dailyMap.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0});
        if (tx.type == TransactionType.income) {
          dailyMap[key]!['income'] = (dailyMap[key]!['income'] ?? 0.0) + amount;
        } else if (tx.type == TransactionType.expense) {
          dailyMap[key]!['expense'] =
              (dailyMap[key]!['expense'] ?? 0.0) + amount;
        } else if (tx.type == TransactionType.transfer) {
          final fee = _parseTransferFeeFromNote(tx.note);
          if (fee > 0) {
            dailyMap[key]!['expense'] =
                (dailyMap[key]!['expense'] ?? 0.0) + fee;
          }
        }
      }
    }

    final cashFlowPoints = <DailyCashFlowPoint>[];
    for (int i = 180; i >= 0; i--) {
      final d =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final inc = dailyMap[key]?['income'] ?? 0.0;
      final exp = dailyMap[key]?['expense'] ?? 0.0;
      cashFlowPoints.add(DailyCashFlowPoint(
        date: d,
        income: inc,
        expense: exp,
      ));
    }

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
      dailyCashFlow: cashFlowPoints,
    );
  }

  double _parseTransferFeeFromNote(String? note) {
    if (note == null || !note.contains('(Fee:')) return 0.0;
    final regExp = RegExp(r'\(Fee:\s*[^0-9]*([0-9]+(?:\.[0-9]+)?)\)');
    final match = regExp.firstMatch(note);
    if (match != null && match.groupCount >= 1) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
    return 0.0;
  }
}
