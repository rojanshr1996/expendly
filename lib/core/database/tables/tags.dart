import 'package:drift/drift.dart';

import 'transactions.dart';

@DataClassName('TagData')
@TableIndex(name: 'idx_tags_name', columns: {#name})
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DataClassName('TransactionTagData')
class TransactionTags extends Table {
  IntColumn get transactionId => integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {transactionId, tagId};
}
