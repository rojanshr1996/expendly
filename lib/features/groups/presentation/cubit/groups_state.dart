import 'package:equatable/equatable.dart';
import '../../domain/entities/sharing_event.dart';
import 'groups_message.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();
  @override
  List<Object?> get props => [];
}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<SharingEvent> events;
  const GroupsLoaded(this.events);
  @override
  List<Object?> get props => [events];
}

class GroupsError extends GroupsState {
  final GroupsMessage message;
  const GroupsError(this.message);
  @override
  List<Object?> get props => [message];
}

class GroupsActionSuccess extends GroupsState {
  final GroupsMessage message;
  const GroupsActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
