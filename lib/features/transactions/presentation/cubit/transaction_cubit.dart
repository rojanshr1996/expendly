import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/events/transaction_events.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_state.dart';

@injectable
class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repository;
  bool _isPerformingLocalAction = false;

  TransactionCubit(this._repository) : super(TransactionInitial()) {
    TransactionEvents.transactionUpdated.addListener(_onTransactionUpdated);
  }

  void _onTransactionUpdated() {
    if (!isClosed && !_isPerformingLocalAction) {
      loadTransactions();
    }
  }

  @override
  Future<void> close() {
    TransactionEvents.transactionUpdated
        .removeListener(_onTransactionUpdated);
    return super.close();
  }

  Future<void> loadTransactions() async {
    if (isClosed) return;
    emit(TransactionLoading());
    try {
      final transactions = await _repository.getAllTransactions();
      if (isClosed) return;
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      if (isClosed) return;
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    PaymentMethod? paymentMethod,
    String currencyCode = 'USD',
  }) async {
    _isPerformingLocalAction = true;
    try {
      await _repository.addTransaction(
        type: type,
        amount: amount,
        categoryId: categoryId,
        timestamp: timestamp,
        note: note,
        paymentMethod: paymentMethod,
        currencyCode: currencyCode,
      );

      if (isClosed) return;
      emit(const TransactionActionSuccess('Transaction saved successfully'));
      await loadTransactions();
      TransactionEvents.notifyUpdated();
    } catch (e) {
      if (isClosed) return;
      emit(TransactionError('Failed to save transaction: ${e.toString()}'));
    } finally {
      _isPerformingLocalAction = false;
    }
  }

  Future<void> updateTransaction({
    required int id,
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    PaymentMethod? paymentMethod,
    String currencyCode = 'USD',
  }) async {
    _isPerformingLocalAction = true;
    try {
      await _repository.updateTransaction(
        id: id,
        type: type,
        amount: amount,
        categoryId: categoryId,
        timestamp: timestamp,
        note: note,
        paymentMethod: paymentMethod,
        currencyCode: currencyCode,
      );

      if (isClosed) return;
      emit(const TransactionActionSuccess('Transaction updated successfully'));
      await loadTransactions();
      TransactionEvents.notifyUpdated();
    } catch (e) {
      if (isClosed) return;
      emit(TransactionError('Failed to update transaction: ${e.toString()}'));
    } finally {
      _isPerformingLocalAction = false;
    }
  }

  Future<void> deleteTransaction(int id) async {
    _isPerformingLocalAction = true;
    try {
      await _repository.deleteTransaction(id);
      if (isClosed) return;
      emit(const TransactionActionSuccess('Transaction deleted'));
      await loadTransactions();
      TransactionEvents.notifyUpdated();
    } catch (e) {
      if (isClosed) return;
      emit(TransactionError('Failed to delete transaction: ${e.toString()}'));
    } finally {
      _isPerformingLocalAction = false;
    }
  }

  void filterSearch(String query) {
    if (isClosed) return;
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
    if (isClosed) return;
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
