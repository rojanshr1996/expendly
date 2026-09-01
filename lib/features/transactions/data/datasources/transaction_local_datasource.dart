import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/preference_service.dart';
import '../../domain/entities/transaction_item.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionItem>> getAllTransactions();
  Future<List<TransactionItem>> getTransactionsByType(TransactionType type);
  Future<List<TransactionItem>> getRecentTransactions({
    int limit = 10,
    TransactionType? type,
  });
  Future<List<TransactionItem>> getRecentDistinctExpenses({
    int limit = 5,
  });
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

@LazySingleton(as: TransactionLocalDataSource)
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase _db;

  TransactionLocalDataSourceImpl(this._db);

  @override
  Future<List<TransactionItem>> getAllTransactions() async {
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..orderBy([
        OrderingTerm(
            expression: _db.transactions.timestamp, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.transactions.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();

    return rows.map((row) {
      final tx = row.readTable(_db.transactions);
      final cat = row.readTable(_db.categories);

      return TransactionItem(
        id: tx.id,
        type: tx.type,
        amount: tx.amount / 100.0,
        currencyCode: tx.currencyCode,
        categoryId: cat.id,
        categoryName: cat.name,
        categoryIcon: cat.icon,
        categoryColorHex: cat.color,
        timestamp: tx.timestamp,
        note: tx.note,
        paymentMethod: tx.paymentMethod,
      );
    }).toList();
  }

  @override
  Future<List<TransactionItem>> getTransactionsByType(
      TransactionType type) async {
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..where(_db.transactions.type.equals(type.index))
      ..orderBy([
        OrderingTerm(
            expression: _db.transactions.timestamp, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.transactions.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();

    return rows.map((row) {
      final tx = row.readTable(_db.transactions);
      final cat = row.readTable(_db.categories);

      return TransactionItem(
        id: tx.id,
        type: tx.type,
        amount: tx.amount / 100.0,
        currencyCode: tx.currencyCode,
        categoryId: cat.id,
        categoryName: cat.name,
        categoryIcon: cat.icon,
        categoryColorHex: cat.color,
        timestamp: tx.timestamp,
        note: tx.note,
        paymentMethod: tx.paymentMethod,
      );
    }).toList();
  }

  @override
  Future<List<TransactionItem>> getRecentTransactions({
    int limit = 10,
    TransactionType? type,
  }) async {
    final baseQuery = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ]);

    if (type != null) {
      baseQuery.where(_db.transactions.type.equals(type.index));
    }

    baseQuery
      ..orderBy([
        OrderingTerm(
            expression: _db.transactions.timestamp, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.transactions.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final rows = await baseQuery.get();

    return rows.map((row) {
      final tx = row.readTable(_db.transactions);
      final cat = row.readTable(_db.categories);

      return TransactionItem(
        id: tx.id,
        type: tx.type,
        amount: tx.amount / 100.0,
        currencyCode: tx.currencyCode,
        categoryId: cat.id,
        categoryName: cat.name,
        categoryIcon: cat.icon,
        categoryColorHex: cat.color,
        timestamp: tx.timestamp,
        note: tx.note,
        paymentMethod: tx.paymentMethod,
      );
    }).toList();
  }

  @override
  Future<List<TransactionItem>> getRecentDistinctExpenses({
    int limit = 5,
  }) async {
    // Fetch a larger chunk to ensure we can find distinct ones
    final baseQuery = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..where(_db.transactions.type.equals(TransactionType.expense.index))
      ..orderBy([
        OrderingTerm(
            expression: _db.transactions.timestamp, mode: OrderingMode.desc),
      ])
      ..limit(50); // Hard limit to prevent memory issues

    final rows = await baseQuery.get();

    final allRecent = rows.map((row) {
      final tx = row.readTable(_db.transactions);
      final cat = row.readTable(_db.categories);

      return TransactionItem(
        id: tx.id,
        type: tx.type,
        amount: tx.amount / 100.0,
        currencyCode: tx.currencyCode,
        categoryId: cat.id,
        categoryName: cat.name,
        categoryIcon: cat.icon,
        categoryColorHex: cat.color,
        timestamp: tx.timestamp,
        note: tx.note,
        paymentMethod: tx.paymentMethod,
      );
    }).toList();

    // Deduplicate by categoryId and amount
    final distinctItems = <TransactionItem>[];
    final seenSignatures = <String>{};

    for (final item in allRecent) {
      // Signature: categoryId_amount
      final sig = '${item.categoryId}_${item.amount}';
      if (!seenSignatures.contains(sig)) {
        seenSignatures.add(sig);
        distinctItems.add(item);
        if (distinctItems.length >= limit) {
          break;
        }
      }
    }

    return distinctItems;
  }

  @override
  Future<int> addTransaction({
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    PaymentMethod? paymentMethod,
    String currencyCode = 'USD',
  }) async {
    final minorUnits = (amount * 100).round();
    final effectiveCurrencyCode = currencyCode == 'USD'
        ? (getIt.isRegistered<PreferenceService>()
            ? getIt<PreferenceService>().currencyCode
            : currencyCode)
        : currencyCode;

    final companion = TransactionsCompanion.insert(
      type: type,
      amount: minorUnits,
      currencyCode: Value(effectiveCurrencyCode),
      categoryId: categoryId,
      timestamp: timestamp,
      note: Value(note),
      paymentMethod: Value(paymentMethod),
    );
    return await _db.into(_db.transactions).insert(companion);
  }

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
  }) async {
    final minorUnits = (amount * 100).round();
    final effectiveCurrencyCode = currencyCode == 'USD'
        ? (getIt.isRegistered<PreferenceService>()
            ? getIt<PreferenceService>().currencyCode
            : currencyCode)
        : currencyCode;

    final companion = TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(minorUnits),
      currencyCode: Value(effectiveCurrencyCode),
      categoryId: Value(categoryId),
      timestamp: Value(timestamp),
      note: Value(note),
      paymentMethod: Value(paymentMethod),
    );
    await _db.update(_db.transactions).replace(companion);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
