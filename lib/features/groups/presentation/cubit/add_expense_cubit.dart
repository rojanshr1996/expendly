import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/event_participant.dart';
import '../../domain/repositories/groups_repository.dart';
import '../../domain/usecases/calculate_splits.dart';
import 'add_expense_state.dart';
import 'groups_message.dart';

class AddExpenseCubit extends Cubit<AddExpenseState> {
  final GroupsRepository _repository;
  final CalculateSplits _calculateSplits;
  final int _eventId;
  final List<EventParticipant> _participants;

  AddExpenseCubit(
    this._repository,
    this._calculateSplits,
    this._eventId,
    this._participants,
  ) : super(const AddExpenseState()) {
    initializeParticipants(_participants);
  }

  void initializeParticipants(List<EventParticipant> participants) {
    if (isClosed) return;
    Map<int, bool> selection = {};
    for (var p in participants) {
      selection[p.id] = true;
    }

    final owner = participants.where((p) => p.isOwner).firstOrNull;
    final defaultPaidById =
        owner?.id ?? (participants.isNotEmpty ? participants.first.id : null);

    emit(state.copyWith(
      participantSelection: selection,
      paidByParticipantId: defaultPaidById,
      clearValidationMessage: true,
    ));
    _recalculateSplits();
  }

  void setAmount(double amount) {
    if (isClosed) return;
    emit(state.copyWith(
      amount: amount,
      clearValidationMessage: true,
    ));
    _recalculateSplits();
  }

  void setDescription(String desc) {
    if (isClosed) return;
    emit(state.copyWith(
      description: desc,
      clearValidationMessage: true,
    ));
  }

  void setPaidBy(int participantId) {
    if (isClosed) return;
    emit(state.copyWith(
      paidByParticipantId: participantId,
      clearValidationMessage: true,
    ));
  }

  void toggleParticipant(int participantId) {
    if (isClosed) return;
    final newSelection = Map<int, bool>.from(state.participantSelection);
    newSelection[participantId] = !(newSelection[participantId] ?? false);

    final newCustomPct = Map<int, double?>.from(state.customPercentages);
    final newCustomAmt = Map<int, double?>.from(state.customAmounts);
    if (newSelection[participantId] == false) {
      newCustomPct.remove(participantId);
      newCustomAmt.remove(participantId);
    }

    emit(state.copyWith(
      participantSelection: newSelection,
      customPercentages: newCustomPct,
      customAmounts: newCustomAmt,
      clearValidationMessage: true,
    ));
    _recalculateSplits();
  }

  void setSplitMode(SplitMode mode) {
    if (isClosed) return;

    emit(state.copyWith(
      splitMode: mode,
      customAmounts: {},
      customPercentages: {},
      clearValidationMessage: true,
    ));
    _recalculateSplits();
  }

  void setSplitModeBool(bool isEqual) {
    setSplitMode(isEqual ? SplitMode.equal : SplitMode.percentage);
  }

  void setCustomPercentage(int participantId, double? percentage) {
    if (isClosed) return;
    final newCustom = Map<int, double?>.from(state.customPercentages);
    if (percentage == null) {
      newCustom.remove(participantId);
    } else {
      newCustom[participantId] = percentage;
    }
    emit(state.copyWith(
      customPercentages: newCustom,
      clearValidationMessage: true,
    ));
    _recalculateSplits();
  }

  void setCustomAmount(int participantId, double? amount) {
    if (isClosed) return;
    final newCustom = Map<int, double?>.from(state.customAmounts);
    if (amount == null) {
      newCustom.remove(participantId);
    } else {
      newCustom[participantId] = amount;
    }
    emit(state.copyWith(
      customAmounts: newCustom,
      clearValidationMessage: true,
    ));
    _recalculateSplits();
  }

  void _recalculateSplits() {
    if (isClosed) return;
    final selectedIds = state.participantSelection.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    Map<int, double> customPercentages = {};
    for (var entry in state.customPercentages.entries) {
      if (entry.value != null && selectedIds.contains(entry.key)) {
        customPercentages[entry.key] = entry.value!;
      }
    }

    Map<int, double> customAmounts = {};
    for (var entry in state.customAmounts.entries) {
      if (entry.value != null && selectedIds.contains(entry.key)) {
        customAmounts[entry.key] = entry.value!;
      }
    }

    final detailedResult = _calculateSplits.calculateDetailed(
      totalAmount: state.amount,
      selectedParticipantIds: selectedIds,
      mode: state.splitMode,
      customAmounts: customAmounts,
      customPercentages: customPercentages,
    );

    emit(state.copyWith(
      calculatedSplits: detailedResult.splits,
      splitCalculationResult: detailedResult,
      clearValidationMessage: true,
    ));
  }

  Future<void> saveExpense() async {
    if (isClosed) return;

    if (state.amount <= 0) {
      emit(state.copyWith(
        validationMessage: 'Please enter a valid expense amount',
      ));
      return;
    }

    if (state.description.trim().isEmpty) {
      emit(state.copyWith(
        validationMessage: 'Please enter an expense description',
      ));
      return;
    }

    if (state.paidByParticipantId == null) {
      emit(state.copyWith(
        validationMessage: 'Please select who paid for the expense',
      ));
      return;
    }

    final selectedIds =
        state.participantSelection.entries.where((e) => e.value).toList();
    if (selectedIds.isEmpty) {
      emit(state.copyWith(
        validationMessage:
            'Please select at least one participant to split with',
      ));
      return;
    }

    if (state.splitCalculationResult?.isValid == false) {
      emit(state.copyWith(
        validationMessage: state.splitCalculationResult?.errorMessage ??
            'Splits must equal the total amount',
      ));
      return;
    }

    emit(state.copyWith(
        isSaving: true, clearErrorMessage: true, clearValidationMessage: true));

    try {
      List<ExpenseSplitInput> splitInputs = state.calculatedSplits.map((res) {
        return ExpenseSplitInput(
          participantId: res.participantId,
          isSelected: true,
          customPercentage: state.splitMode == SplitMode.percentage
              ? state.customPercentages[res.participantId]
              : null,
          splitAmount: res.amount,
        );
      }).toList();

      await _repository.addExpense(
        eventId: _eventId,
        title: state.description.trim(),
        amount: state.amount,
        paidByParticipantId: state.paidByParticipantId!,
        date: DateTime.now(),
        splits: splitInputs,
      );

      if (isClosed) return;
      emit(state.copyWith(isSaving: false, isSaved: true));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isSaving: false,
        errorMessage: GroupsMessage.saveFailed,
      ));
    }
  }
}
