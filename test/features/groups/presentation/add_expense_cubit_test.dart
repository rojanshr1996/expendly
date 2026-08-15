import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/features/groups/presentation/cubit/add_expense_cubit.dart';
import 'package:expendly/features/groups/domain/usecases/calculate_splits.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'fake_groups_repository.dart';

void main() {
  late FakeGroupsRepository repository;
  late CalculateSplits calculateSplits;
  late AddExpenseCubit cubit;
  late List<EventParticipant> participants;

  setUp(() {
    repository = FakeGroupsRepository();
    calculateSplits = CalculateSplits();
    
    participants = [
      const EventParticipant(id: 1, eventId: 1, name: 'Alice', colorIndex: 0, isOwner: true),
      const EventParticipant(id: 2, eventId: 1, name: 'Bob', colorIndex: 1, isOwner: false),
    ];

    cubit = AddExpenseCubit(repository, calculateSplits, 1, participants);
  });

  tearDown(() {
    cubit.close();
  });

  group('AddExpenseCubit', () {
    test('Initial state with all participants selected', () {
      expect(cubit.state.participantSelection.length, 2);
      expect(cubit.state.participantSelection[1], true);
      expect(cubit.state.participantSelection[2], true);
      expect(cubit.state.paidByParticipantId, 1);
    });

    test('Setting amount recalculates splits', () {
      cubit.setAmount(100.0);
      expect(cubit.state.amount, 100.0);
      
      final splits = cubit.state.calculatedSplits;
      expect(splits.length, 2);
      expect(splits[0].amount, 50.0);
      expect(splits[1].amount, 50.0);
    });

    test('Toggling participant selection updates calculated splits', () {
      cubit.setAmount(100.0);
      cubit.toggleParticipant(2); // Deselect Bob

      expect(cubit.state.participantSelection[2], false);
      final splits = cubit.state.calculatedSplits;
      expect(splits.length, 1);
      expect(splits[0].participantId, 1);
      expect(splits[0].amount, 100.0);
    });

    test('Setting split mode to percentage and setting custom percentages', () {
      cubit.setAmount(100.0);
      cubit.setSplitMode(SplitMode.percentage);
      
      cubit.setCustomPercentage(1, 60.0);
      cubit.setCustomPercentage(2, 40.0);

      final splits = cubit.state.calculatedSplits;
      expect(splits.length, 2);
      expect(splits.firstWhere((s) => s.participantId == 1).amount, 60.0);
      expect(splits.firstWhere((s) => s.participantId == 2).amount, 40.0);
    });

    test('Setting split mode to exact and setting custom amounts', () {
      cubit.setAmount(100.0);
      cubit.setSplitMode(SplitMode.exact);
      
      cubit.setCustomAmount(1, 65.0);
      cubit.setCustomAmount(2, 35.0);

      final splits = cubit.state.calculatedSplits;
      expect(splits.length, 2);
      expect(splits.firstWhere((s) => s.participantId == 1).amount, 65.0);
      expect(splits.firstWhere((s) => s.participantId == 2).amount, 35.0);
      expect(cubit.state.splitCalculationResult?.isValid, true);
    });

    test('Saving valid expense calls repository and emits isSaved', () async {
      cubit.setAmount(100.0);
      cubit.setDescription('Dinner');
      cubit.setPaidBy(1);

      await cubit.saveExpense();

      expect(cubit.state.isSaving, false);
      expect(cubit.state.isSaved, true);
      expect(repository.expenses.length, 1);
      expect(repository.expenses.first.title, 'Dinner');
      expect(repository.expenses.first.amount, 100.0);
    });
  });
}
