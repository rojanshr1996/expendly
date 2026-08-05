import 'package:drift/drift.dart';

import '../enums/database_enums.dart';
import 'categories.dart';

@DataClassName('BudgetData')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer()
      .nullable()
      .references(Categories, #id, onDelete: KeyAction.cascade)();
  IntColumn get targetAmount => integer()(); // Stored in minor units (cents)
  IntColumn get period => intEnum<BudgetPeriod>()();
  IntColumn get year => integer().nullable()();
  IntColumn get month => integer().nullable()();
  TextColumn get currencyCode =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('USD'))();
  BoolColumn get notifyAtThreshold =>
      boolean().withDefault(const Constant(true))();
  IntColumn get thresholdPercentage =>
      integer().withDefault(const Constant(80))();
}
