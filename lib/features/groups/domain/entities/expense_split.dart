import 'package:equatable/equatable.dart';

class ExpenseSplit extends Equatable {
  final int id;
  final int expenseId;
  final int participantId;
  final String participantName;
  final bool isSelected;
  final double? customPercentage;
  final double splitAmount;

  const ExpenseSplit({
    required this.id,
    required this.expenseId,
    required this.participantId,
    required this.participantName,
    required this.isSelected,
    this.customPercentage,
    required this.splitAmount,
  });

  @override
  List<Object?> get props => [
        id,
        expenseId,
        participantId,
        participantName,
        isSelected,
        customPercentage,
        splitAmount,
      ];
}
