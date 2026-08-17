import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/features/groups/domain/usecases/calculate_splits.dart';

void main() {
  late CalculateSplits calculateSplits;

  setUp(() {
    calculateSplits = CalculateSplits();
  });

  group('CalculateSplits', () {
    test('Equal split among 2 people', () {
      final results = calculateSplits.calculate(
        totalAmount: 100.0,
        selectedParticipantIds: [1, 2],
      );

      expect(results.length, 2);
      expect(results.firstWhere((r) => r.participantId == 1).amount, 50.0);
      expect(results.firstWhere((r) => r.participantId == 2).amount, 50.0);
      expect(results.firstWhere((r) => r.participantId == 1).percentage, 50.0);
    });

    test('Equal split with cents remainder (100 among 3)', () {
      final results = calculateSplits.calculate(
        totalAmount: 100.0,
        selectedParticipantIds: [1, 2, 3],
      );

      expect(results.length, 3);
      final amounts = results.map((r) => r.amount).toList();
      amounts.sort(); // 33.33, 33.33, 33.34
      expect(amounts[0], 33.33);
      expect(amounts[1], 33.33);
      expect(amounts[2], 33.34);
    });

    test('Custom percentages (60% to A, 40% to B)', () {
      final results = calculateSplits.calculate(
        totalAmount: 100.0,
        selectedParticipantIds: [1, 2],
        customPercentages: {1: 60.0, 2: 40.0},
      );

      expect(results.firstWhere((r) => r.participantId == 1).amount, 60.0);
      expect(results.firstWhere((r) => r.participantId == 2).amount, 40.0);
    });

    test('Partial custom percentages (40% to A, remaining 60% split equally as 30% each to B and C)', () {
      final results = calculateSplits.calculate(
        totalAmount: 100.0,
        selectedParticipantIds: [1, 2, 3],
        customPercentages: {1: 40.0},
      );

      expect(results.firstWhere((r) => r.participantId == 1).amount, 40.0);
      expect(results.firstWhere((r) => r.participantId == 2).amount, 30.0);
      expect(results.firstWhere((r) => r.participantId == 3).amount, 30.0);
    });

    test('Exact amounts split mode with valid total', () {
      final detailed = calculateSplits.calculateDetailed(
        totalAmount: 100.0,
        selectedParticipantIds: [1, 2, 3],
        mode: SplitMode.exact,
        customAmounts: {1: 45.0, 2: 30.0, 3: 25.0},
      );

      expect(detailed.isValid, true);
      expect(detailed.totalAllocated, 100.0);
      expect(detailed.remainingAmount, 0.0);
      expect(detailed.splits.firstWhere((s) => s.participantId == 1).amount, 45.0);
      expect(detailed.splits.firstWhere((s) => s.participantId == 2).amount, 30.0);
      expect(detailed.splits.firstWhere((s) => s.participantId == 3).amount, 25.0);
    });

    test('Exact amounts split mode with unbalanced under-allocation', () {
      final detailed = calculateSplits.calculateDetailed(
        totalAmount: 100.0,
        selectedParticipantIds: [1, 2],
        mode: SplitMode.exact,
        customAmounts: {1: 40.0, 2: 30.0},
      );

      expect(detailed.isValid, false);
      expect(detailed.totalAllocated, 70.0);
      expect(detailed.remainingAmount, 30.0);
      expect(detailed.errorMessage, contains('remaining'));
    });

    test('Partial exact amounts (40 to A, remaining 60 split equally as 30 each to B and C)', () {
      final detailed = calculateSplits.calculateDetailed(
        totalAmount: 100.0,
        selectedParticipantIds: [1, 2, 3],
        mode: SplitMode.exact,
        customAmounts: {1: 40.0},
      );

      expect(detailed.isValid, true);
      expect(detailed.totalAllocated, 100.0);
      expect(detailed.remainingAmount, 0.0);
      expect(detailed.splits.firstWhere((s) => s.participantId == 1).amount, 40.0);
      expect(detailed.splits.firstWhere((s) => s.participantId == 2).amount, 30.0);
      expect(detailed.splits.firstWhere((s) => s.participantId == 3).amount, 30.0);
    });

    test('Percentage split mode validation', () {
      final valid = calculateSplits.calculateDetailed(
        totalAmount: 120.0,
        selectedParticipantIds: [1, 2],
        mode: SplitMode.percentage,
        customPercentages: {1: 70.0, 2: 30.0},
      );
      expect(valid.isValid, true);
      expect(valid.splits.firstWhere((s) => s.participantId == 1).amount, 84.0);
      expect(valid.splits.firstWhere((s) => s.participantId == 2).amount, 36.0);

      final invalid = calculateSplits.calculateDetailed(
        totalAmount: 120.0,
        selectedParticipantIds: [1, 2],
        mode: SplitMode.percentage,
        customPercentages: {1: 70.0, 2: 40.0},
      );
      expect(invalid.isValid, false);
      expect(invalid.errorMessage, contains('over 100%'));
    });

    test('Edge cases: \$0 total', () {
      final results = calculateSplits.calculate(
        totalAmount: 0.0,
        selectedParticipantIds: [1, 2],
      );

      expect(results.length, 2);
      expect(results[0].amount, 0.0);
      expect(results[1].amount, 0.0);
    });

    test('Edge cases: 1 participant', () {
      final results = calculateSplits.calculate(
        totalAmount: 100.0,
        selectedParticipantIds: [1],
      );

      expect(results.length, 1);
      expect(results[0].amount, 100.0);
    });

    test('Edge cases: empty list', () {
      final results = calculateSplits.calculate(
        totalAmount: 100.0,
        selectedParticipantIds: [],
      );

      expect(results.isEmpty, true);
    });
  });
}
