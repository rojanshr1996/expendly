import 'package:drift/drift.dart';

import '../enums/database_enums.dart';
import 'categories.dart';
import 'recurring_transactions.dart';

@DataClassName('TransactionData')
@TableIndex(name: 'idx_transactions_timestamp', columns: {#timestamp})
@TableIndex(name: 'idx_transactions_category_id', columns: {#categoryId})
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get type => intEnum<TransactionType>()();
  IntColumn get amount =>
      integer()(); // Stored in minor units (e.g., cents/paisa)
  TextColumn get currencyCode =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('USD'))();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.restrict)();
  IntColumn get subcategoryId => integer()
      .nullable()
      .references(Subcategories, #id, onDelete: KeyAction.setNull)();
  IntColumn get recurringTransactionId => integer()
      .nullable()
      .references(RecurringTransactions, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get note => text().nullable()();
  IntColumn get paymentMethod => intEnum<PaymentMethod>().nullable()();
}
