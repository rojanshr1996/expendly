import 'package:expendly/features/groups/domain/repositories/groups_repository.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/domain/entities/group_expense.dart';

class FakeGroupsRepository implements GroupsRepository {
  List<SharingEvent> events = [];
  List<EventParticipant> participants = [];
  List<GroupExpense> expenses = [];
  
  bool shouldThrow = false;

  @override
  Future<List<SharingEvent>> getAllEvents() async {
    if (shouldThrow) throw Exception('Error');
    return events;
  }

  @override
  Future<SharingEvent> getEventById(int id) async {
    if (shouldThrow) throw Exception('Error');
    return events.firstWhere((e) => e.id == id);
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
    if (shouldThrow) throw Exception('Error');
    final newId = events.isEmpty ? 1 : events.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    events.add(SharingEvent(
      id: newId,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      category: category,
      status: status,
      createdAt: DateTime.now(),
      participants: const [],
      totalSpent: 0,
      userShare: 0,
    ));
    return newId;
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
    if (shouldThrow) throw Exception('Error');
    final index = events.indexWhere((e) => e.id == id);
    if (index >= 0) {
      final old = events[index];
      events[index] = SharingEvent(
        id: old.id,
        name: name ?? old.name,
        description: description ?? old.description,
        startDate: startDate ?? old.startDate,
        endDate: endDate ?? old.endDate,
        category: category ?? old.category,
        status: status ?? old.status,
        createdAt: old.createdAt,
        participants: old.participants,
        totalSpent: old.totalSpent,
        userShare: old.userShare,
      );
    }
  }

  @override
  Future<void> deleteEvent(int id) async {
    if (shouldThrow) throw Exception('Error');
    events.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<EventParticipant>> getParticipantsByEventId(int eventId) async {
    if (shouldThrow) throw Exception('Error');
    return participants.where((p) => p.eventId == eventId).toList();
  }

  @override
  Future<int> addParticipant({
    required int eventId,
    required String name,
    String? email,
    bool isOwner = false,
    int colorIndex = 0,
  }) async {
    if (shouldThrow) throw Exception('Error');
    final newId = participants.isEmpty ? 1 : participants.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    participants.add(EventParticipant(
      id: newId,
      eventId: eventId,
      name: name,
      email: email,
      isOwner: isOwner,
      colorIndex: colorIndex,
    ));
    return newId;
  }

  @override
  Future<void> updateParticipant({
    required int participantId,
    String? name,
    String? email,
  }) async {
    if (shouldThrow) throw Exception('Error');
    final index = participants.indexWhere((p) => p.id == participantId);
    if (index >= 0) {
      final old = participants[index];
      participants[index] = EventParticipant(
        id: old.id,
        eventId: old.eventId,
        name: name ?? old.name,
        email: email != null ? (email.trim().isEmpty ? null : email.trim()) : old.email,
        isOwner: old.isOwner,
        colorIndex: old.colorIndex,
      );
    }
  }

  @override
  Future<void> removeParticipant(int participantId) async {
    if (shouldThrow) throw Exception('Error');
    participants.removeWhere((p) => p.id == participantId);
  }

  @override
  Future<List<GroupExpense>> getExpensesByEventId(int eventId) async {
    if (shouldThrow) throw Exception('Error');
    return expenses.where((e) => e.eventId == eventId).toList();
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
    if (shouldThrow) throw Exception('Error');
    final newId = expenses.isEmpty ? 1 : expenses.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    expenses.add(GroupExpense(
      id: newId,
      eventId: eventId,
      title: title,
      amount: amount,
      paidByParticipantId: paidByParticipantId, paidByName: 'User',
      date: date,
      createdAt: DateTime.now(),
      splits: const [],
    ));
    return newId;
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    if (shouldThrow) throw Exception('Error');
    expenses.removeWhere((e) => e.id == expenseId);
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
    if (shouldThrow) throw Exception('Error');
    return addExpense(
      eventId: eventId,
      title: note ?? 'Settlement Payment',
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
    if (shouldThrow) throw Exception('Error');
    updateEvent(id: eventId, status: 'settled');
  }
}
