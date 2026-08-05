import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/events/transaction_events.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_state.dart';

@injectable
class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repository;
  bool _isPerformingLocalAction = false;

  TransactionCubit(this._repository) : super(TransactionInitial()) {
    TransactionEvents.transactionUpdated.addListener(_onTransactionUpdated);
  }

  List<TransactionItem> get allTransactions => state is TransactionLoaded
      ? (state as TransactionLoaded).transactions
      : const [];

  void _onTransactionUpdated() {
    if (!isClosed && !_isPerformingLocalAction) {
      loadTransactions();
    }
  }

  @override
  Future<void> close() {
    TransactionEvents.transactionUpdated.removeListener(_onTransactionUpdated);
    return super.close();
  }

  Future<void> loadTransactions({bool isSilent = false}) async {
    if (isClosed) return;
    final currentState = state;
    final currentLoaded =
        currentState is TransactionLoaded ? currentState : null;

    if (!isSilent && currentLoaded == null) {
      emit(TransactionLoading());
    }

    try {
      final transactions = await _repository.getAllTransactions();
      if (isClosed) return;
      emit(TransactionLoaded(
        transactions: transactions,
        selectedCategoryId: currentLoaded?.selectedCategoryId,
        selectedType: currentLoaded?.selectedType,
        searchQuery: currentLoaded?.searchQuery ?? '',
      ));
    } catch (e) {
      if (isClosed) return;
      if (currentLoaded == null) {
        emit(TransactionError(e.toString()));
      }
    }
  }

  void emitActionSuccess(String message) {
    if (!isClosed) {
      emit(TransactionActionSuccess(message));
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

  Future<int?> addTransactionAndReturnId({
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
      final newId = await _repository.addTransaction(
        type: type,
        amount: amount,
        categoryId: categoryId,
        timestamp: timestamp,
        note: note,
        paymentMethod: paymentMethod,
        currencyCode: currencyCode,
      );

      await loadTransactions();
      TransactionEvents.notifyUpdated();
      return newId;
    } catch (e) {
      if (!isClosed) {
        emit(TransactionError('Failed to save transaction: ${e.toString()}'));
      }
      return null;
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
      final targetTx = allTransactions.where((t) => t.id == id).firstOrNull;
      await _repository.deleteTransaction(id);

      if (targetTx?.type == TransactionType.transfer) {
        final linkedFee = allTransactions
            .where(
              (t) =>
                  t.type == TransactionType.expense &&
                  t.note?.contains('[Ref: #$id]') == true,
            )
            .firstOrNull;
        if (linkedFee != null) {
          await _repository.deleteTransaction(linkedFee.id);
        }
      }

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
        selectedType: current.selectedType,
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
        selectedType: current.selectedType,
      ));
    }
  }

  void filterType(TransactionType? type) {
    if (isClosed) return;
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      emit(TransactionLoaded(
        transactions: current.transactions,
        searchQuery: current.searchQuery,
        selectedCategoryId: current.selectedCategoryId,
        selectedType: type,
      ));
    }
  }
}
