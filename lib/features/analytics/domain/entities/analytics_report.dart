import 'package:equatable/equatable.dart';

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
  final List<CategoryReportItem> categoryBreakdowns;

  const AnalyticsReport({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRatePercentage,
    required this.categoryBreakdowns,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        netSavings,
        savingsRatePercentage,
        categoryBreakdowns,
      ];
}
