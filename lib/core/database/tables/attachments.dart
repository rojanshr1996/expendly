import 'package:drift/drift.dart';

import 'transactions.dart';

@DataClassName('AttachmentData')
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
}
