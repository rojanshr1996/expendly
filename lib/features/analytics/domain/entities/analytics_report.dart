import 'package:equatable/equatable.dart';

class DailyFlowItem extends Equatable {
  final String label;
  final double amount;
  final double heightRatio;
  final bool isPeak;

  const DailyFlowItem({
    required this.label,
    required this.amount,
    required this.heightRatio,
    this.isPeak = false,
  });

  @override
  List<Object?> get props => [label, amount, heightRatio, isPeak];
}

class CategoryReportItem extends Equatable {
  final String categoryName;
  final String iconName;
  final String colorHex;
  final double amount;
  final double percentage;

  const CategoryReportItem({
    required this.categoryName,
    required this.iconName,
    required this.colorHex,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props =>
      [categoryName, iconName, colorHex, amount, percentage];
}

class AnalyticsReport extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRatePercentage;
  final double avgDailySpend;
  final double avgDailySpendChangePct;
  final double budgetHealthPercentage;
  final String budgetHealthStatus;
  final String? topCategoryName;
  final double? topCategoryPercentage;
  final String? topCategoryDesc;
  final List<CategoryReportItem> categoryBreakdowns;
  final List<DailyFlowItem> dailyFlows;
  final String periodName;

  const AnalyticsReport({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRatePercentage,
    required this.avgDailySpend,
    this.avgDailySpendChangePct = 0.0,
    required this.budgetHealthPercentage,
    required this.budgetHealthStatus,
    this.topCategoryName,
    this.topCategoryPercentage,
    this.topCategoryDesc,
    required this.categoryBreakdowns,
    required this.dailyFlows,
    this.periodName = 'Monthly',
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        netSavings,
        savingsRatePercentage,
        avgDailySpend,
        avgDailySpendChangePct,
        budgetHealthPercentage,
        budgetHealthStatus,
        topCategoryName,
        topCategoryPercentage,
        topCategoryDesc,
        categoryBreakdowns,
        dailyFlows,
        periodName,
      ];
}
