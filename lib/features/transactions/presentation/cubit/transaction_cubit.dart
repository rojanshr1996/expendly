import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_state.dart';

@injectable
class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repository;

  TransactionCubit(this._repository) : super(TransactionInitial());

  Future<void> loadTransactions() async {
    emit(TransactionLoading());
    try {
      final transactions = await _repository.getAllTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    String currencyCode = 'USD',
  }) async {
    try {
      await _repository.addTransaction(
        type: type,
        amount: amount,
        categoryId: categoryId,
        timestamp: timestamp,
        note: note,
        currencyCode: currencyCode,
      );
      emit(const TransactionActionSuccess('Transaction saved successfully'));
      await loadTransactions();
    } catch (e) {
      emit(TransactionError('Failed to save transaction: ${e.toString()}'));
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _repository.deleteTransaction(id);
      emit(const TransactionActionSuccess('Transaction deleted'));
      await loadTransactions();
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: ${e.toString()}'));
    }
  }

  void filterSearch(String query) {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      emit(TransactionLoaded(
        transactions: current.transactions,
        searchQuery: query,
        selectedCategoryId: current.selectedCategoryId,
      ));
    }
  }

  void filterCategory(int? categoryId) {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      emit(TransactionLoaded(
        transactions: current.transactions,
        searchQuery: current.searchQuery,
        selectedCategoryId: categoryId,
      ));
    }
  }
}
