import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_item.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionItem> transactions;
  final String searchQuery;
  final int? selectedCategoryId;

  const TransactionLoaded({
    required this.transactions,
    this.searchQuery = '',
    this.selectedCategoryId,
  });

  List<TransactionItem> get filteredTransactions {
    return transactions.where((tx) {
      final matchesSearch = searchQuery.isEmpty ||
          tx.categoryName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (tx.note != null &&
              tx.note!.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesCategory =
          selectedCategoryId == null || tx.categoryId == selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  List<Object?> get props => [transactions, searchQuery, selectedCategoryId];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionActionSuccess extends TransactionState {
  final String message;

  const TransactionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
