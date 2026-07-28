import 'package:equatable/equatable.dart';

/// Represents daily aggregated income and expense for the cash flow chart.
class DailyCashFlowPoint extends Equatable {
  final DateTime date;
  final double income;
  final double expense;

  const DailyCashFlowPoint({
    required this.date,
    required this.income,
    required this.expense,
  });

  int get day => date.day;

  @override
  List<Object?> get props => [date, income, expense];
}

class DashboardTransactionItem extends Equatable {
  final int id;
  final String title;
  final String categoryName;
  final String iconName;
  final String colorHex;
  final double amount;
  final DateTime date;
  final bool isIncome;

  const DashboardTransactionItem({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.iconName,
    required this.colorHex,
    required this.amount,
    required this.date,
    this.isIncome = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        categoryName,
        iconName,
        colorHex,
        amount,
        date,
        isIncome,
      ];
}

class DashboardCategoryShare extends Equatable {
  final String categoryName;
  final String colorHex;
  final double amount;
  final double percentage;

  const DashboardCategoryShare({
    required this.categoryName,
    required this.colorHex,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryName, colorHex, amount, percentage];
}

/// Entity representing overall financial overview for the current period.
class FinancialSummary extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double monthlyBudgetLimit;
  final String currencySymbol;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<DashboardTransactionItem> recentTransactions;
  final List<DashboardCategoryShare> categoryBreakdowns;
  final List<DailyCashFlowPoint> dailyCashFlow;

  const FinancialSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    this.monthlyBudgetLimit = 5000.0,
    required this.currencySymbol,
    required this.periodStart,
    required this.periodEnd,
    this.recentTransactions = const [],
    this.categoryBreakdowns = const [],
    this.dailyCashFlow = const [],
  });

  @override
  List<Object?> get props => [
        totalBalance,
        totalIncome,
        totalExpense,
        monthlyBudgetLimit,
        currencySymbol,
        periodStart,
        periodEnd,
        recentTransactions,
        categoryBreakdowns,
        dailyCashFlow,
      ];
}
