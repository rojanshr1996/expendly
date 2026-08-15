import 'package:drift/drift.dart';
import 'event_participants.dart';
import 'sharing_events.dart';

@DataClassName('GroupExpenseData')
class GroupExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get eventId => integer().references(SharingEvents, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  IntColumn get amountInCents => integer()();
  IntColumn get paidByParticipantId =>
      integer().references(EventParticipants, #id)();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
