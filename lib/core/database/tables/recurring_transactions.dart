import 'package:drift/drift.dart';

import '../enums/database_enums.dart';
import 'categories.dart';

@DataClassName('RecurringTransactionData')
class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get type => intEnum<TransactionType>()();
  IntColumn get amount => integer()(); // Stored in minor units (cents)
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.restrict)();
  IntColumn get subcategoryId => integer()
      .nullable()
      .references(Subcategories, #id, onDelete: KeyAction.setNull)();
  TextColumn get note => text().nullable()();
  IntColumn get frequency => intEnum<RecurrenceFrequency>()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get isAutoCreate => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastProcessedDate => dateTime().nullable()();
}
