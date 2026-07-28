import 'package:equatable/equatable.dart';

import '../../../../core/database/enums/database_enums.dart';

class BudgetItem extends Equatable {
  final int id;
  final int? categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColorHex;
  final double targetAmount;
  final double spentAmount;
  final BudgetPeriod period;
  final bool notifyAtThreshold;
  final int thresholdPercentage;

  const BudgetItem({
    required this.id,
    this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColorHex,
    required this.targetAmount,
    required this.spentAmount,
    this.period = BudgetPeriod.monthly,
    this.notifyAtThreshold = true,
    this.thresholdPercentage = 80,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    final pct = (spentAmount / targetAmount);
    return pct > 1.0 ? 1.0 : pct;
  }

  bool get isOverBudget => spentAmount > targetAmount;
  bool get isWarning =>
      progressPercentage >= (thresholdPercentage / 100.0) && !isOverBudget;

  @override
  List<Object?> get props => [
        id,
        categoryId,
        categoryName,
        categoryIcon,
        categoryColorHex,
        targetAmount,
        spentAmount,
        period,
        notifyAtThreshold,
        thresholdPercentage,
      ];
}
