import 'package:expendly/features/groups/domain/repositories/groups_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/features/groups/data/datasources/groups_local_datasource.dart';

void main() {
  late AppDatabase database;
  late GroupsLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = GroupsLocalDataSourceImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('GroupsLocalDataSourceImpl', () {
    test('Create event, get all events, get event by id', () async {
      final eventId = await dataSource.createEvent(
        name: 'Test Event',
        description: 'Test Description',
        startDate: DateTime.now(),
        category: 'trip',
        status: 'active',
      );

      expect(eventId, isNotNull);

      final events = await dataSource.getAllEvents();
      expect(events.length, 1);
      expect(events[0].name, 'Test Event');

      final event = await dataSource.getEventById(eventId);
      expect(event.name, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.category, 'trip');
      expect(event.status, 'active');
    });

    test('Add participants, retrieve by event id', () async {
      final eventId = await dataSource.createEvent(
        name: 'Test Event',
        startDate: DateTime.now(),
      );

      await dataSource.addParticipant(
        eventId: eventId,
        name: 'Alice',
        isOwner: true,
      );
      await dataSource.addParticipant(
        eventId: eventId,
        name: 'Bob',
      );

      final participants = await dataSource.getParticipantsByEventId(eventId);
      expect(participants.length, 2);
      expect(participants.any((p) => p.name == 'Alice' && p.isOwner), isTrue);
      expect(participants.any((p) => p.name == 'Bob' && !p.isOwner), isTrue);
    });

    test('Add expense with splits, verify calculation of totalSpent and userShare', () async {
      final eventId = await dataSource.createEvent(
        name: 'Test Event',
        startDate: DateTime.now(),
      );

      final p1Id = await dataSource.addParticipant(eventId: eventId, name: 'Alice', isOwner: true);
      final p2Id = await dataSource.addParticipant(eventId: eventId, name: 'Bob');

      await dataSource.addExpense(
        eventId: eventId,
        title: 'Dinner',
        amount: 100.0,
        paidByParticipantId: p1Id,
        date: DateTime.now(),
        splits: [
          ExpenseSplitInput(participantId: p1Id, splitAmount: 60.0),
          ExpenseSplitInput(participantId: p2Id, splitAmount: 40.0),
        ],
      );

      final event = await dataSource.getEventById(eventId);
      expect(event.totalSpent, 100.0);
      expect(event.userShare, 60.0); // Alice is owner, share is 60.

      final expenses = await dataSource.getExpensesByEventId(eventId);
      expect(expenses.length, 1);
      expect(expenses[0].title, 'Dinner');
      expect(expenses[0].splits.length, 2);
    });

    test('Mark event settled', () async {
      final eventId = await dataSource.createEvent(
        name: 'Test Event',
        startDate: DateTime.now(),
      );

      await dataSource.markEventSettled(eventId);

      final event = await dataSource.getEventById(eventId);
      expect(event.status, 'settled');
    });

    test('Delete event verifies cascading cleanup', () async {
      final eventId = await dataSource.createEvent(
        name: 'Test Event',
        startDate: DateTime.now(),
      );

      final p1Id = await dataSource.addParticipant(eventId: eventId, name: 'Alice', isOwner: true);

      await dataSource.addExpense(
        eventId: eventId,
        title: 'Dinner',
        amount: 100.0,
        paidByParticipantId: p1Id,
        date: DateTime.now(),
        splits: [
          ExpenseSplitInput(participantId: p1Id, splitAmount: 100.0),
        ],
      );

      await dataSource.deleteEvent(eventId);

      // Check events
      final events = await dataSource.getAllEvents();
      expect(events.isEmpty, true);

      // We don't have direct methods to fetch missing participants or expenses, but we can verify through Drift
      final pCount = await database.select(database.eventParticipants).get();
      expect(pCount.isEmpty, true);

      final eCount = await database.select(database.groupExpenses).get();
      expect(eCount.isEmpty, true);

      final sCount = await database.select(database.expenseSplits).get();
      expect(sCount.isEmpty, true);
    });
  });
}
