import '../entities/event_participant.dart';
import '../entities/group_expense.dart';
import '../entities/sharing_event.dart';

class ExpenseSplitInput {
  final int participantId;
  final bool isSelected;
  final double? customPercentage;
  final double splitAmount;

  const ExpenseSplitInput({
    required this.participantId,
    this.isSelected = true,
    this.customPercentage,
    required this.splitAmount,
  });
}

abstract class GroupsRepository {
  // Events
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

  // Participants
  Future<List<EventParticipant>> getParticipantsByEventId(int eventId);
  Future<int> addParticipant({
    required int eventId,
    required String name,
    String? email,
    bool isOwner = false,
    int colorIndex = 0,
  });
  Future<void> updateParticipant({
    required int participantId,
    String? name,
    String? email,
  });
  Future<void> removeParticipant(int participantId);

  // Expenses
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

  // Settlements
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
