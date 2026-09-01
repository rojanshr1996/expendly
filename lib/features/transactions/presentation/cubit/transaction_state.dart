import 'package:equatable/equatable.dart';
import '../../../../core/database/enums/database_enums.dart';
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
  final TransactionType? selectedType;

  const TransactionLoaded({
    required this.transactions,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.selectedType,
  });

  List<TransactionItem> get filteredTransactions {
    return transactions.where((tx) {
      final matchesSearch = searchQuery.isEmpty ||
          tx.categoryName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (tx.note != null &&
              tx.note!.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesCategory =
          selectedCategoryId == null || tx.categoryId == selectedCategoryId;
      final matchesType = selectedType == null || tx.type == selectedType;
      return matchesSearch && matchesCategory && matchesType;
    }).toList();
  }

  @override
  List<Object?> get props =>
      [transactions, searchQuery, selectedCategoryId, selectedType];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionActionSuccess extends TransactionState {
  final String message;
  final int? transactionId;

  const TransactionActionSuccess(this.message, {this.transactionId});

  @override
  List<Object?> get props => [message, transactionId];
}
