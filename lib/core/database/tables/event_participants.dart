import 'package:drift/drift.dart';
import 'sharing_events.dart';

@DataClassName('EventParticipantData')
class EventParticipants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get eventId => integer().references(SharingEvents, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().nullable()();
  BoolColumn get isOwner => boolean().withDefault(const Constant(false))();
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
}
