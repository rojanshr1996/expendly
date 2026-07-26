import 'package:equatable/equatable.dart';

/// Entity representing overall financial overview for the current period.
class FinancialSummary extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final String currencySymbol;
  final DateTime periodStart;
  final DateTime periodEnd;

  const FinancialSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.currencySymbol,
    required this.periodStart,
    required this.periodEnd,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        totalIncome,
        totalExpense,
        currencySymbol,
        periodStart,
        periodEnd,
      ];
}
