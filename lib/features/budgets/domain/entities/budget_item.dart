import 'package:equatable/equatable.dart';

class BudgetItem extends Equatable {
  final int id;
  final int? categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColorHex;
  final double targetAmount;
  final double spentAmount;

  const BudgetItem({
    required this.id,
    this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColorHex,
    required this.targetAmount,
    required this.spentAmount,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    final pct = (spentAmount / targetAmount);
    return pct > 1.0 ? 1.0 : pct;
  }

  bool get isOverBudget => spentAmount > targetAmount;
  bool get isWarning => progressPercentage >= 0.9 && !isOverBudget;

  @override
  List<Object?> get props => [
        id,
        categoryId,
        categoryName,
        categoryIcon,
        categoryColorHex,
        targetAmount,
        spentAmount,
      ];
}
