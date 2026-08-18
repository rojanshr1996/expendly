import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/groups_repository.dart';
import 'groups_state.dart';
import 'groups_message.dart';

@lazySingleton
class GroupsCubit extends Cubit<GroupsState> {
  final GroupsRepository _repository;

  GroupsCubit(this._repository) : super(GroupsInitial());

  Future<void> loadEvents({bool isSilent = false}) async {
    if (isClosed) return;
    if (!isSilent && state is! GroupsLoaded) {
      emit(GroupsLoading());
    }
    try {
      final events = await _repository.getAllEvents();
      if (isClosed) return;
      emit(GroupsLoaded(events));
    } catch (e) {
      if (isClosed) return;
      if (state is! GroupsLoaded) {
        emit(const GroupsError(GroupsMessage.loadFailed));
      }
    }
  }

  Future<void> createEvent({
    required String name,
    String description = '',
    required DateTime startDate,
    DateTime? endDate,
    String category = 'trip',
  }) async {
    if (isClosed) return;
    try {
      await _repository.createEvent(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        category: category,
      );
      if (isClosed) return;
      emit(const GroupsActionSuccess(GroupsMessage.eventCreated));
      loadEvents();
    } catch (e) {
      if (isClosed) return;
      emit(const GroupsError(GroupsMessage.saveFailed));
      loadEvents();
    }
  }

  Future<void> updateEvent({
    required int id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? status,
  }) async {
    if (isClosed) return;
    try {
      await _repository.updateEvent(
        id: id,
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        category: category,
        status: status,
      );
      if (isClosed) return;
      emit(const GroupsActionSuccess(GroupsMessage.eventUpdated));
      loadEvents();
    } catch (e) {
      if (isClosed) return;
      emit(const GroupsError(GroupsMessage.saveFailed));
      loadEvents();
    }
  }

  Future<void> deleteEvent(int id) async {
    if (isClosed) return;
    try {
      await _repository.deleteEvent(id);
      if (isClosed) return;
      emit(const GroupsActionSuccess(GroupsMessage.eventDeleted));
      loadEvents();
    } catch (e) {
      if (isClosed) return;
      emit(const GroupsError(GroupsMessage.deleteFailed));
      loadEvents();
    }
  }

  Future<void> markEventSettled(int id) async {
    if (isClosed) return;
    try {
      await _repository.markEventSettled(id);
      if (isClosed) return;
      emit(const GroupsActionSuccess(GroupsMessage.eventSettled));
      loadEvents();
    } catch (e) {
      if (isClosed) return;
      emit(const GroupsError(GroupsMessage.saveFailed));
      loadEvents();
    }
  }
}
