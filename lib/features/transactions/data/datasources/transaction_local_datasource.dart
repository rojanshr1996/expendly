import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../domain/entities/transaction_item.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionItem>> getAllTransactions();
  Future<List<TransactionItem>> getTransactionsByType(TransactionType type);
  Future<int> addTransaction({
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
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
            expression: _db.transactions.timestamp, mode: OrderingMode.desc)
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
            expression: _db.transactions.timestamp, mode: OrderingMode.desc)
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
      );
    }).toList();
  }

  @override
  Future<int> addTransaction({
    required TransactionType type,
    required double amount,
    required int categoryId,
    required DateTime timestamp,
    String? note,
    String currencyCode = 'USD',
  }) async {
    final minorUnits = (amount * 100).round();
    final companion = TransactionsCompanion.insert(
      type: type,
      amount: minorUnits,
      currencyCode: Value(currencyCode),
      categoryId: categoryId,
      timestamp: timestamp,
      note: Value(note),
    );
    return await _db.into(_db.transactions).insert(companion);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
