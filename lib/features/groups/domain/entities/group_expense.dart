import 'package:equatable/equatable.dart';
import 'expense_split.dart';

class GroupExpense extends Equatable {
  final int id;
  final int eventId;
  final String title;
  final double amount;
  final int paidByParticipantId;
  final String paidByName;
  final DateTime date;
  final DateTime createdAt;
  final List<ExpenseSplit> splits;

  const GroupExpense({
    required this.id,
    required this.eventId,
    required this.title,
    required this.amount,
    required this.paidByParticipantId,
    required this.paidByName,
    required this.date,
    required this.createdAt,
    required this.splits,
  });

  @override
  List<Object?> get props => [
        id,
        eventId,
        title,
        amount,
        paidByParticipantId,
        paidByName,
        date,
        createdAt,
        splits,
      ];
}
