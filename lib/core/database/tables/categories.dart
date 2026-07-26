import 'package:drift/drift.dart';

import '../enums/database_enums.dart';

@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  IntColumn get type => intEnum<TransactionType>()();
}

@DataClassName('SubcategoryData')
class Subcategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentCategoryId => integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
}
