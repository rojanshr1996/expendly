import 'package:equatable/equatable.dart';
import 'event_participant.dart';

class Settlement extends Equatable {
  final EventParticipant fromParticipant;
  final EventParticipant toParticipant;
  final double amount;
  final List<String> reasons;

  const Settlement({
    required this.fromParticipant,
    required this.toParticipant,
    required this.amount,
    required this.reasons,
  });

  @override
  List<Object?> get props => [fromParticipant, toParticipant, amount, reasons];
}
