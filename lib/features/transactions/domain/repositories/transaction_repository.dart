import '../../../../core/database/enums/database_enums.dart';
import '../entities/transaction_item.dart';

abstract class TransactionRepository {
  Future<List<TransactionItem>> getAllTransactions();
  Future<List<TransactionItem>> getTransactionsByType(TransactionType type);
  Future<int> addTransaction({
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    PaymentMethod? paymentMethod,
    String currencyCode = 'USD',
  });

  Future<void> updateTransaction({
    required int id,
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    PaymentMethod? paymentMethod,
    String currencyCode = 'USD',
  });

  Future<void> deleteTransaction(int id);
}
