import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/groups_repository.dart';
import '../../domain/usecases/calculate_settlements.dart';
import 'event_detail_state.dart';
import 'groups_message.dart';

@injectable
class EventDetailCubit extends Cubit<EventDetailState> {
  final GroupsRepository _repository;
  final CalculateSettlements _calculateSettlements;

  int? _currentEventId;

  EventDetailCubit(this._repository, this._calculateSettlements)
      : super(EventDetailInitial());

  Future<void> loadEventDetail(int eventId) async {
    _currentEventId = eventId;
    if (isClosed) return;
    emit(EventDetailLoading());
    try {
      final event = await _repository.getEventById(eventId);

      final expenses = await _repository.getExpensesByEventId(eventId);
      final participants = await _repository.getParticipantsByEventId(eventId);

      final settlements = _calculateSettlements.calculate(
        expenses: expenses,
        participants: participants,
      );

      if (isClosed) return;
      emit(EventDetailLoaded(
        event: event,
        expenses: expenses,
        settlements: settlements,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(const EventDetailError(GroupsMessage.loadFailed));
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    if (isClosed) return;
    if (_currentEventId == null) return;
    try {
      await _repository.deleteExpense(expenseId);
      if (isClosed) return;
      emit(const EventDetailActionSuccess(GroupsMessage.expenseDeleted));
      loadEventDetail(_currentEventId!);
    } catch (e) {
      if (isClosed) return;
      emit(const EventDetailError(GroupsMessage.deleteFailed));
      loadEventDetail(_currentEventId!);
    }
  }

  Future<void> recordSettlement({
    required int fromParticipantId,
    required int toParticipantId,
    required double amount,
    String? note,
  }) async {
    if (isClosed) return;
    if (_currentEventId == null) return;
    try {
      await _repository.recordSettlement(
        eventId: _currentEventId!,
        fromParticipantId: fromParticipantId,
        toParticipantId: toParticipantId,
        amount: amount,
        note: note,
      );
      if (isClosed) return;
      emit(const EventDetailActionSuccess(GroupsMessage.settlementRecorded));
      await loadEventDetail(_currentEventId!);
    } catch (e) {
      if (isClosed) return;
      emit(const EventDetailError(GroupsMessage.saveFailed));
      await loadEventDetail(_currentEventId!);
    }
  }

  Future<void> markEventSettled() async {
    if (isClosed) return;
    if (_currentEventId == null) return;
    try {
      await _repository.markEventSettled(_currentEventId!);
      if (isClosed) return;
      emit(const EventDetailActionSuccess(GroupsMessage.eventSettled));
      loadEventDetail(_currentEventId!);
    } catch (e) {
      if (isClosed) return;
      emit(const EventDetailError(GroupsMessage.saveFailed));
      loadEventDetail(_currentEventId!);
    }
  }
}
