import 'package:injectable/injectable.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;

  TransactionRepositoryImpl(this._localDataSource);

  @override
  Future<List<TransactionItem>> getAllTransactions() =>
      _localDataSource.getAllTransactions();

  @override
  Future<List<TransactionItem>> getTransactionsByType(TransactionType type) =>
      _localDataSource.getTransactionsByType(type);

  @override
  Future<List<TransactionItem>> getRecentTransactions({
    int limit = 10,
    TransactionType? type,
  }) =>
      _localDataSource.getRecentTransactions(
        limit: limit,
        type: type,
      );

  @override
  Future<List<TransactionItem>> getRecentDistinctExpenses({
    int limit = 5,
  }) =>
      _localDataSource.getRecentDistinctExpenses(
        limit: limit,
      );

  @override
  Future<int> addTransaction({
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    PaymentMethod? paymentMethod,
    String currencyCode = 'USD',
  }) =>
      _localDataSource.addTransaction(
        type: type,
        amount: amount,
        categoryId: categoryId,
        timestamp: timestamp,
        note: note,
        paymentMethod: paymentMethod,
        currencyCode: currencyCode,
      );

  @override
  Future<void> updateTransaction({
    required int id,
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    PaymentMethod? paymentMethod,
    String currencyCode = 'USD',
  }) =>
      _localDataSource.updateTransaction(
        id: id,
        type: type,
        amount: amount,
        categoryId: categoryId,
        timestamp: timestamp,
        note: note,
        paymentMethod: paymentMethod,
        currencyCode: currencyCode,
      );

  @override
  Future<void> deleteTransaction(int id) =>
      _localDataSource.deleteTransaction(id);
}
