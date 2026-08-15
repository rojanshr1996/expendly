import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/event_participant.dart';
import '../../domain/entities/expense_split.dart';
import '../../domain/entities/group_expense.dart';
import '../../domain/entities/sharing_event.dart';
import '../../domain/repositories/groups_repository.dart';

abstract class GroupsLocalDataSource {
  Future<List<SharingEvent>> getAllEvents();
  Future<SharingEvent> getEventById(int id);
  Future<int> createEvent({
    required String name,
    String description = '',
    required DateTime startDate,
    DateTime? endDate,
    String category = 'trip',
    String status = 'active',
  });
  Future<void> updateEvent({
    required int id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? status,
  });
  Future<void> deleteEvent(int id);

  Future<List<EventParticipant>> getParticipantsByEventId(int eventId);
  Future<int> addParticipant({
    required int eventId,
    required String name,
    String? email,
    bool isOwner = false,
    int colorIndex = 0,
  });
  Future<void> removeParticipant(int participantId);

  Future<List<GroupExpense>> getExpensesByEventId(int eventId);
  Future<int> addExpense({
    required int eventId,
    required String title,
    required double amount,
    required int paidByParticipantId,
    required DateTime date,
    required List<ExpenseSplitInput> splits,
  });
  Future<void> deleteExpense(int expenseId);

  Future<int> recordSettlement({
    required int eventId,
    required int fromParticipantId,
    required int toParticipantId,
    required double amount,
    String? note,
    DateTime? date,
  });
  Future<void> markEventSettled(int eventId);
}

@LazySingleton(as: GroupsLocalDataSource)
class GroupsLocalDataSourceImpl implements GroupsLocalDataSource {
  final AppDatabase _db;

  GroupsLocalDataSourceImpl(this._db);

  EventParticipant _mapParticipant(EventParticipantData data) {
    return EventParticipant(
      id: data.id,
      eventId: data.eventId,
      name: data.name,
      email: data.email,
      isOwner: data.isOwner,
      colorIndex: data.colorIndex,
    );
  }

  @override
  Future<List<SharingEvent>> getAllEvents() async {
    final eventsData = await _db.select(_db.sharingEvents).get();
    List<SharingEvent> results = [];

    for (final eventData in eventsData) {
      final participants = await getParticipantsByEventId(eventData.id);

      final expensesQuery = _db.select(_db.groupExpenses)
        ..where((tbl) => tbl.eventId.equals(eventData.id));
      final expenses = await expensesQuery.get();

      double totalSpent = 0;
      for (final exp in expenses) {
        totalSpent += exp.amountInCents / 100.0;
      }

      final userParticipant = participants.where((p) => p.isOwner).firstOrNull;
      double userShare = 0;

      if (userParticipant != null) {
        for (final exp in expenses) {
          final splitsQuery = _db.select(_db.expenseSplits)
            ..where((tbl) =>
                tbl.expenseId.equals(exp.id) &
                tbl.participantId.equals(userParticipant.id));
          final splitData = await splitsQuery.getSingleOrNull();
          if (splitData != null) {
            userShare += splitData.splitAmountInCents / 100.0;
          }
        }
      }

      results.add(SharingEvent(
        id: eventData.id,
        name: eventData.name,
        description: eventData.description,
        startDate: eventData.startDate,
        endDate: eventData.endDate,
        category: eventData.category,
        status: eventData.status,
        createdAt: eventData.createdAt,
        participants: participants,
        totalSpent: totalSpent,
        userShare: userShare,
      ));
    }

    return results;
  }

  @override
  Future<SharingEvent> getEventById(int id) async {
    final query = _db.select(_db.sharingEvents)
      ..where((tbl) => tbl.id.equals(id));
    final eventData = await query.getSingle();

    final participants = await getParticipantsByEventId(eventData.id);

    final expensesQuery = _db.select(_db.groupExpenses)
      ..where((tbl) => tbl.eventId.equals(eventData.id));
    final expenses = await expensesQuery.get();

    double totalSpent = 0;
    for (final exp in expenses) {
      totalSpent += exp.amountInCents / 100.0;
    }

    final userParticipant = participants.where((p) => p.isOwner).firstOrNull;
    double userShare = 0;

    if (userParticipant != null) {
      for (final exp in expenses) {
        final splitsQuery = _db.select(_db.expenseSplits)
          ..where((tbl) =>
              tbl.expenseId.equals(exp.id) &
              tbl.participantId.equals(userParticipant.id));
        final splitData = await splitsQuery.getSingleOrNull();
        if (splitData != null) {
          userShare += splitData.splitAmountInCents / 100.0;
        }
      }
    }

    return SharingEvent(
      id: eventData.id,
      name: eventData.name,
      description: eventData.description,
      startDate: eventData.startDate,
      endDate: eventData.endDate,
      category: eventData.category,
      status: eventData.status,
      createdAt: eventData.createdAt,
      participants: participants,
      totalSpent: totalSpent,
      userShare: userShare,
    );
  }

  @override
  Future<int> createEvent({
    required String name,
    String description = '',
    required DateTime startDate,
    DateTime? endDate,
    String category = 'trip',
    String status = 'active',
  }) async {
    return await _db
        .into(_db.sharingEvents)
        .insert(SharingEventsCompanion.insert(
          name: name,
          description: Value(description),
          startDate: startDate,
          endDate: Value(endDate),
          category: Value(category),
          status: Value(status),
          createdAt: Value(DateTime.now()),
        ));
  }

  @override
  Future<void> updateEvent({
    required int id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? status,
  }) async {
    final updateStmt = _db.update(_db.sharingEvents)
      ..where((tbl) => tbl.id.equals(id));
    await updateStmt.write(SharingEventsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      description:
          description != null ? Value(description) : const Value.absent(),
      startDate: startDate != null ? Value(startDate) : const Value.absent(),
      endDate: endDate != null ? Value(endDate) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      status: status != null ? Value(status) : const Value.absent(),
    ));
  }

  @override
  Future<void> deleteEvent(int id) async {
    await _db.transaction(() async {
      final expensesQuery = _db.select(_db.groupExpenses)
        ..where((tbl) => tbl.eventId.equals(id));
      final expenses = await expensesQuery.get();

      for (final exp in expenses) {
        await (_db.delete(_db.expenseSplits)
              ..where((tbl) => tbl.expenseId.equals(exp.id)))
            .go();
      }

      await (_db.delete(_db.groupExpenses)
            ..where((tbl) => tbl.eventId.equals(id)))
          .go();

      await (_db.delete(_db.eventParticipants)
            ..where((tbl) => tbl.eventId.equals(id)))
          .go();

      await (_db.delete(_db.sharingEvents)..where((tbl) => tbl.id.equals(id)))
          .go();
    });
  }

  @override
  Future<List<EventParticipant>> getParticipantsByEventId(int eventId) async {
    final query = _db.select(_db.eventParticipants)
      ..where((tbl) => tbl.eventId.equals(eventId));
    final participantsData = await query.get();
    return participantsData.map(_mapParticipant).toList();
  }

  @override
  Future<int> addParticipant({
    required int eventId,
    required String name,
    String? email,
    bool isOwner = false,
    int colorIndex = 0,
  }) async {
    return await _db
        .into(_db.eventParticipants)
        .insert(EventParticipantsCompanion.insert(
          eventId: eventId,
          name: name,
          email: Value(email),
          isOwner: Value(isOwner),
          colorIndex: Value(colorIndex),
        ));
  }

  @override
  Future<void> removeParticipant(int participantId) async {
    await (_db.delete(_db.eventParticipants)
          ..where((tbl) => tbl.id.equals(participantId)))
        .go();
  }

  @override
  Future<List<GroupExpense>> getExpensesByEventId(int eventId) async {
    final expensesData = await (_db.select(_db.groupExpenses)
          ..where((tbl) => tbl.eventId.equals(eventId)))
        .get();

    final participantsData = await getParticipantsByEventId(eventId);
    final participantMap = {for (var p in participantsData) p.id: p};

    List<GroupExpense> results = [];

    for (final exp in expensesData) {
      final splitsData = await (_db.select(_db.expenseSplits)
            ..where((tbl) => tbl.expenseId.equals(exp.id)))
          .get();

      List<ExpenseSplit> splits = splitsData.map((s) {
        return ExpenseSplit(
          id: s.id,
          expenseId: s.expenseId,
          participantId: s.participantId,
          participantName: participantMap[s.participantId]?.name ?? 'Unknown',
          isSelected: s.isSelected,
          customPercentage: s.customPercentage,
          splitAmount: s.splitAmountInCents / 100.0,
        );
      }).toList();

      results.add(GroupExpense(
        id: exp.id,
        eventId: exp.eventId,
        title: exp.title,
        amount: exp.amountInCents / 100.0,
        paidByParticipantId: exp.paidByParticipantId,
        paidByName: participantMap[exp.paidByParticipantId]?.name ?? 'Unknown',
        date: exp.date,
        createdAt: exp.createdAt,
        splits: splits,
      ));
    }

    return results;
  }

  @override
  Future<int> addExpense({
    required int eventId,
    required String title,
    required double amount,
    required int paidByParticipantId,
    required DateTime date,
    required List<ExpenseSplitInput> splits,
  }) async {
    return await _db.transaction(() async {
      final expenseId = await _db
          .into(_db.groupExpenses)
          .insert(GroupExpensesCompanion.insert(
            eventId: eventId,
            title: title,
            amountInCents: (amount * 100).round(),
            paidByParticipantId: paidByParticipantId,
            date: date,
            createdAt: Value(DateTime.now()),
          ));

      for (final split in splits) {
        await _db.into(_db.expenseSplits).insert(ExpenseSplitsCompanion.insert(
              expenseId: expenseId,
              participantId: split.participantId,
              isSelected: Value(split.isSelected),
              customPercentage: Value(split.customPercentage),
              splitAmountInCents: Value((split.splitAmount * 100).round()),
            ));
      }

      return expenseId;
    });
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.expenseSplits)
            ..where((tbl) => tbl.expenseId.equals(expenseId)))
          .go();
      await (_db.delete(_db.groupExpenses)
            ..where((tbl) => tbl.id.equals(expenseId)))
          .go();
    });
  }

  @override
  Future<int> recordSettlement({
    required int eventId,
    required int fromParticipantId,
    required int toParticipantId,
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    final participants = await getParticipantsByEventId(eventId);
    final fromP =
        participants.where((p) => p.id == fromParticipantId).firstOrNull;
    final toP = participants.where((p) => p.id == toParticipantId).firstOrNull;

    final defaultTitle = (fromP != null && toP != null)
        ? 'Payment: ${fromP.name} → ${toP.name}'
        : 'Settlement Payment';

    return await addExpense(
      eventId: eventId,
      title:
          (note != null && note.trim().isNotEmpty) ? note.trim() : defaultTitle,
      amount: amount,
      paidByParticipantId: fromParticipantId,
      date: date ?? DateTime.now(),
      splits: [
        ExpenseSplitInput(
          participantId: toParticipantId,
          isSelected: true,
          splitAmount: amount,
          customPercentage: 100.0,
        ),
      ],
    );
  }

  @override
  Future<void> markEventSettled(int eventId) async {
    await (_db.update(_db.sharingEvents)
          ..where((tbl) => tbl.id.equals(eventId)))
        .write(const SharingEventsCompanion(
      status: Value('settled'),
    ));
  }
}
