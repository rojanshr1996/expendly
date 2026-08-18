import 'package:drift/drift.dart';
import 'event_participants.dart';
import 'group_expenses.dart';

@DataClassName('ExpenseSplitData')
class ExpenseSplits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get expenseId => integer().references(GroupExpenses, #id)();
  IntColumn get participantId => integer().references(EventParticipants, #id)();
  BoolColumn get isSelected => boolean().withDefault(const Constant(true))();
  RealColumn get customPercentage => real().nullable()();
  IntColumn get splitAmountInCents =>
      integer().withDefault(const Constant(0))();
}
