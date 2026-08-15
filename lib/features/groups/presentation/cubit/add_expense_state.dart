import 'package:equatable/equatable.dart';
import '../../domain/usecases/calculate_splits.dart';
import 'groups_message.dart';

class AddExpenseState extends Equatable {
  final double amount;
  final String description;
  final int? paidByParticipantId;
  final SplitMode splitMode;
  final Map<int, bool> participantSelection;
  final Map<int, double?> customPercentages;
  final Map<int, double?> customAmounts;
  final List<SplitResult> calculatedSplits;
  final SplitCalculationResult? splitCalculationResult;
  final bool isSaving;
  final bool isSaved;
  final GroupsMessage? errorMessage;
  final String? validationMessage;

  bool get isEqualSplit => splitMode == SplitMode.equal;

  const AddExpenseState({
    this.amount = 0,
    this.description = '',
    this.paidByParticipantId,
    this.splitMode = SplitMode.equal,
    this.participantSelection = const {},
    this.customPercentages = const {},
    this.customAmounts = const {},
    this.calculatedSplits = const [],
    this.splitCalculationResult,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
    this.validationMessage,
  });

  AddExpenseState copyWith({
    double? amount,
    String? description,
    int? paidByParticipantId,
    SplitMode? splitMode,
    bool? isEqualSplit,
    Map<int, bool>? participantSelection,
    Map<int, double?>? customPercentages,
    Map<int, double?>? customAmounts,
    List<SplitResult>? calculatedSplits,
    SplitCalculationResult? splitCalculationResult,
    bool? isSaving,
    bool? isSaved,
    GroupsMessage? errorMessage,
    String? validationMessage,
    bool clearErrorMessage = false,
    bool clearValidationMessage = false,
  }) {
    SplitMode resolvedSplitMode = splitMode ?? this.splitMode;
    if (isEqualSplit != null) {
      resolvedSplitMode = isEqualSplit ? SplitMode.equal : SplitMode.percentage;
    }

    return AddExpenseState(
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paidByParticipantId: paidByParticipantId ?? this.paidByParticipantId,
      splitMode: resolvedSplitMode,
      participantSelection: participantSelection ?? this.participantSelection,
      customPercentages: customPercentages ?? this.customPercentages,
      customAmounts: customAmounts ?? this.customAmounts,
      calculatedSplits: calculatedSplits ?? this.calculatedSplits,
      splitCalculationResult:
          splitCalculationResult ?? this.splitCalculationResult,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidationMessage
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }

  @override
  List<Object?> get props => [
        amount,
        description,
        paidByParticipantId,
        splitMode,
        participantSelection,
        customPercentages,
        customAmounts,
        calculatedSplits,
        splitCalculationResult,
        isSaving,
        isSaved,
        errorMessage,
        validationMessage,
      ];
}
