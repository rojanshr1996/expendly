import '../../domain/entities/financial_summary.dart';

class FinancialSummaryModel extends FinancialSummary {
  const FinancialSummaryModel({
    required super.totalBalance,
    required super.totalIncome,
    required super.totalExpense,
    required super.currencySymbol,
    required super.periodStart,
    required super.periodEnd,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryModel(
      totalBalance: (json['totalBalance'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
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
      'currencySymbol': currencySymbol,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}
