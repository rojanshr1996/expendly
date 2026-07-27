import '../../domain/entities/financial_summary.dart';

class FinancialSummaryModel extends FinancialSummary {
  const FinancialSummaryModel({
    required super.totalBalance,
    required super.totalIncome,
    required super.totalExpense,
    super.monthlyBudgetLimit = 5000.0,
    required super.currencySymbol,
    required super.periodStart,
    required super.periodEnd,
    super.recentTransactions = const [],
    super.categoryBreakdowns = const [],
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryModel(
      totalBalance: (json['totalBalance'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      monthlyBudgetLimit:
          (json['monthlyBudgetLimit'] as num?)?.toDouble() ?? 5000.0,
      currencySymbol: json['currencySymbol'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'monthlyBudgetLimit': monthlyBudgetLimit,
      'currencySymbol': currencySymbol,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}
