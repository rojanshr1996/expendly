import 'package:equatable/equatable.dart';
import '../../domain/entities/sharing_event.dart';
import '../../domain/entities/group_expense.dart';
import '../../domain/entities/settlement.dart';
import 'groups_message.dart';

abstract class EventDetailState extends Equatable {
  const EventDetailState();
  @override
  List<Object?> get props => [];
}

class EventDetailInitial extends EventDetailState {}

class EventDetailLoading extends EventDetailState {}

class EventDetailLoaded extends EventDetailState {
  final SharingEvent event;
  final List<GroupExpense> expenses;
  final List<Settlement> settlements;

  const EventDetailLoaded(
      {required this.event, required this.expenses, required this.settlements});

  @override
  List<Object?> get props => [event, expenses, settlements];
}

class EventDetailError extends EventDetailState {
  final GroupsMessage message;
  const EventDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class EventDetailActionSuccess extends EventDetailState {
  final GroupsMessage message;
  const EventDetailActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
