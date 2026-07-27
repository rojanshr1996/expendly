import 'package:equatable/equatable.dart';
import '../../../../core/database/enums/database_enums.dart';

class TransactionItem extends Equatable {
  final int id;
  final TransactionType type;
  final double amount; // Amount in major units (e.g. 45.50)
  final String currencyCode;
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColorHex;
  final DateTime timestamp;
  final String? note;

  const TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.currencyCode,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColorHex,
    required this.timestamp,
    this.note,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        currencyCode,
        categoryId,
        categoryName,
        categoryIcon,
        categoryColorHex,
        timestamp,
        note,
      ];
}
