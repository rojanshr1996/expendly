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
  Future<int> addTransaction({
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    String currencyCode = 'USD',
  }) =>
      _localDataSource.addTransaction(
        type: type,
        amount: amount,
        categoryId: categoryId,
        timestamp: timestamp,
        note: note,
        currencyCode: currencyCode,
      );

  @override
  Future<void> deleteTransaction(int id) =>
      _localDataSource.deleteTransaction(id);
}
