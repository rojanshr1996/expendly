import 'package:injectable/injectable.dart';

import '../../domain/entities/event_participant.dart';
import '../../domain/entities/group_expense.dart';
import '../../domain/entities/sharing_event.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_local_datasource.dart';

@LazySingleton(as: GroupsRepository)
class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsLocalDataSource _localDataSource;

  GroupsRepositoryImpl(this._localDataSource);

  @override
  Future<List<SharingEvent>> getAllEvents() {
    return _localDataSource.getAllEvents();
  }

  @override
  Future<SharingEvent> getEventById(int id) {
    return _localDataSource.getEventById(id);
  }

  @override
  Future<int> createEvent({
    required String name,
    String description = '',
    required DateTime startDate,
    DateTime? endDate,
    String category = 'trip',
    String status = 'active',
  }) {
    return _localDataSource.createEvent(
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      category: category,
      status: status,
    );
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
  }) {
    return _localDataSource.updateEvent(
      id: id,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      category: category,
      status: status,
    );
  }

  @override
  Future<void> deleteEvent(int id) {
    return _localDataSource.deleteEvent(id);
  }

  @override
  Future<List<EventParticipant>> getParticipantsByEventId(int eventId) {
    return _localDataSource.getParticipantsByEventId(eventId);
  }

  @override
  Future<int> addParticipant({
    required int eventId,
    required String name,
    String? email,
    bool isOwner = false,
    int colorIndex = 0,
  }) {
    return _localDataSource.addParticipant(
      eventId: eventId,
      name: name,
      email: email,
      isOwner: isOwner,
      colorIndex: colorIndex,
    );
  }

  @override
  Future<void> removeParticipant(int participantId) {
    return _localDataSource.removeParticipant(participantId);
  }

  @override
  Future<List<GroupExpense>> getExpensesByEventId(int eventId) {
    return _localDataSource.getExpensesByEventId(eventId);
  }

  @override
  Future<int> addExpense({
    required int eventId,
    required String title,
    required double amount,
    required int paidByParticipantId,
    required DateTime date,
    required List<ExpenseSplitInput> splits,
  }) {
    return _localDataSource.addExpense(
      eventId: eventId,
      title: title,
      amount: amount,
      paidByParticipantId: paidByParticipantId,
      date: date,
      splits: splits,
    );
  }

  @override
  Future<void> deleteExpense(int expenseId) {
    return _localDataSource.deleteExpense(expenseId);
  }

  @override
  Future<int> recordSettlement({
    required int eventId,
    required int fromParticipantId,
    required int toParticipantId,
    required double amount,
    String? note,
    DateTime? date,
  }) {
    return _localDataSource.recordSettlement(
      eventId: eventId,
      fromParticipantId: fromParticipantId,
      toParticipantId: toParticipantId,
      amount: amount,
      note: note,
      date: date,
    );
  }

  @override
  Future<void> markEventSettled(int eventId) {
    return _localDataSource.markEventSettled(eventId);
  }
}
