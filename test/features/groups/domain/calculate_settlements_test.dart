import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/features/groups/domain/usecases/calculate_settlements.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/domain/entities/group_expense.dart';
import 'package:expendly/features/groups/domain/entities/expense_split.dart';

void main() {
  late CalculateSettlements calculateSettlements;

  setUp(() {
    calculateSettlements = CalculateSettlements();
  });

  EventParticipant createParticipant(int id, String name) {
    return EventParticipant(
      id: id,
      eventId: 1,
      name: name, isOwner: false,
      colorIndex: 0,
    );
  }

  group('CalculateSettlements', () {
    test('2 participants, 1 expense (\$100 paid by A, split equally with B -> B owes A \$50)', () {
      final p1 = createParticipant(1, 'A');
      final p2 = createParticipant(2, 'B');
      
      final expense = GroupExpense(
        id: 1,
        eventId: 1,
        title: 'Dinner',
        amount: 100.0,
        paidByParticipantId: 1,
        paidByName: 'A',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        splits: const [
          ExpenseSplit(id: 1, expenseId: 1, participantId: 1, splitAmount: 50.0, participantName: 'A', isSelected: true, customPercentage: 50.0),
          ExpenseSplit(id: 2, expenseId: 1, participantId: 2, splitAmount: 50.0, participantName: 'B', isSelected: true, customPercentage: 50.0),
        ],
      );

      final settlements = calculateSettlements.calculate(
        expenses: [expense],
        participants: [p1, p2],
      );

      expect(settlements.length, 1);
      expect(settlements[0].fromParticipant.id, 2); // B owes
      expect(settlements[0].toParticipant.id, 1);   // A gets
      expect(settlements[0].amount, 50.0);
    });

    test('3 participants, multiple expenses with direct pairwise settlement', () {
      final p1 = createParticipant(1, 'A');
      final p2 = createParticipant(2, 'B');
      final p3 = createParticipant(3, 'C');
      
      final expense1 = GroupExpense(
        id: 1, eventId: 1, title: 'Lunch', amount: 90.0, paidByParticipantId: 1, paidByName: 'A', date: DateTime.now(), createdAt: DateTime.now(),
        splits: const [
          ExpenseSplit(id: 1, expenseId: 1, participantId: 1, splitAmount: 30.0, participantName: 'A', isSelected: true, customPercentage: 33.3),
          ExpenseSplit(id: 2, expenseId: 1, participantId: 2, splitAmount: 30.0, participantName: 'B', isSelected: true, customPercentage: 33.3),
          ExpenseSplit(id: 3, expenseId: 1, participantId: 3, splitAmount: 30.0, participantName: 'C', isSelected: true, customPercentage: 33.3),
        ],
      );
      
      final expense2 = GroupExpense(
        id: 2, eventId: 1, title: 'Snacks', amount: 30.0, paidByParticipantId: 2, paidByName: 'B', date: DateTime.now(), createdAt: DateTime.now(),
        splits: const [
          ExpenseSplit(id: 4, expenseId: 2, participantId: 1, splitAmount: 10.0, participantName: 'A', isSelected: true, customPercentage: 33.3),
          ExpenseSplit(id: 5, expenseId: 2, participantId: 2, splitAmount: 10.0, participantName: 'B', isSelected: true, customPercentage: 33.3),
          ExpenseSplit(id: 6, expenseId: 2, participantId: 3, splitAmount: 10.0, participantName: 'C', isSelected: true, customPercentage: 33.3),
        ],
      );

      final settlements = calculateSettlements.calculate(
        expenses: [expense1, expense2],
        participants: [p1, p2, p3],
      );

      expect(settlements.length, 3);
      // C owes A 30 (from Lunch)
      final cToA = settlements.firstWhere((s) => s.fromParticipant.id == 3 && s.toParticipant.id == 1);
      expect(cToA.amount, 30.0);
      
      // C owes B 10 (from Snacks)
      final cToB = settlements.firstWhere((s) => s.fromParticipant.id == 3 && s.toParticipant.id == 2);
      expect(cToB.amount, 10.0);

      // B owes A 20 (Lunch 30 - Snacks 10)
      final bToA = settlements.firstWhere((s) => s.fromParticipant.id == 2 && s.toParticipant.id == 1);
      expect(bToA.amount, 20.0);
    });

    test('4 participants, A and B pay \$100 each, C and D owe both A and B', () {
      final p1 = createParticipant(1, 'A');
      final p2 = createParticipant(2, 'B');
      final p3 = createParticipant(3, 'C');
      final p4 = createParticipant(4, 'D');

      final expense1 = GroupExpense(
        id: 1, eventId: 1, title: 'Dinner A', amount: 100.0, paidByParticipantId: 1, paidByName: 'A', date: DateTime.now(), createdAt: DateTime.now(),
        splits: const [
          ExpenseSplit(id: 1, expenseId: 1, participantId: 1, splitAmount: 25.0, participantName: 'A', isSelected: true, customPercentage: 25.0),
          ExpenseSplit(id: 2, expenseId: 1, participantId: 2, splitAmount: 25.0, participantName: 'B', isSelected: true, customPercentage: 25.0),
          ExpenseSplit(id: 3, expenseId: 1, participantId: 3, splitAmount: 25.0, participantName: 'C', isSelected: true, customPercentage: 25.0),
          ExpenseSplit(id: 4, expenseId: 1, participantId: 4, splitAmount: 25.0, participantName: 'D', isSelected: true, customPercentage: 25.0),
        ],
      );

      final expense2 = GroupExpense(
        id: 2, eventId: 1, title: 'Dinner B', amount: 100.0, paidByParticipantId: 2, paidByName: 'B', date: DateTime.now(), createdAt: DateTime.now(),
        splits: const [
          ExpenseSplit(id: 5, expenseId: 2, participantId: 1, splitAmount: 25.0, participantName: 'A', isSelected: true, customPercentage: 25.0),
          ExpenseSplit(id: 6, expenseId: 2, participantId: 2, splitAmount: 25.0, participantName: 'B', isSelected: true, customPercentage: 25.0),
          ExpenseSplit(id: 7, expenseId: 2, participantId: 3, splitAmount: 25.0, participantName: 'C', isSelected: true, customPercentage: 25.0),
          ExpenseSplit(id: 8, expenseId: 2, participantId: 4, splitAmount: 25.0, participantName: 'D', isSelected: true, customPercentage: 25.0),
        ],
      );

      final settlements = calculateSettlements.calculate(
        expenses: [expense1, expense2],
        participants: [p1, p2, p3, p4],
      );

      // Total 4 settlements: C owes A (25), C owes B (25), D owes A (25), D owes B (25)
      expect(settlements.length, 4);

      final dSettlements = settlements.where((s) => s.fromParticipant.id == 4).toList();
      expect(dSettlements.length, 2);
      expect(dSettlements.any((s) => s.toParticipant.id == 1 && s.amount == 25.0), isTrue);
      expect(dSettlements.any((s) => s.toParticipant.id == 2 && s.amount == 25.0), isTrue);

      final cSettlements = settlements.where((s) => s.fromParticipant.id == 3).toList();
      expect(cSettlements.length, 2);
      expect(cSettlements.any((s) => s.toParticipant.id == 1 && s.amount == 25.0), isTrue);
      expect(cSettlements.any((s) => s.toParticipant.id == 2 && s.amount == 25.0), isTrue);
    });

    test('Recording a settlement payment clears the debt', () {
      final p1 = createParticipant(1, 'A');
      final p2 = createParticipant(2, 'B');

      // Expense: A paid $100 for B
      final expense = GroupExpense(
        id: 1,
        eventId: 1,
        title: 'Dinner',
        amount: 100.0,
        paidByParticipantId: 1,
        paidByName: 'A',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        splits: const [
          ExpenseSplit(
              id: 1,
              expenseId: 1,
              participantId: 2,
              splitAmount: 100.0,
              participantName: 'B',
              isSelected: true,
              customPercentage: 100.0),
        ],
      );

      final initialSettlements = calculateSettlements.calculate(
        expenses: [expense],
        participants: [p1, p2],
      );
      expect(initialSettlements.length, 1);
      expect(initialSettlements.first.fromParticipant.id, 2);
      expect(initialSettlements.first.amount, 100.0);

      // Payment: B pays A $100
      final payment = GroupExpense(
        id: 2,
        eventId: 1,
        title: 'Payment: B to A',
        amount: 100.0,
        paidByParticipantId: 2,
        paidByName: 'B',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        splits: const [
          ExpenseSplit(
              id: 2,
              expenseId: 2,
              participantId: 1,
              splitAmount: 100.0,
              participantName: 'A',
              isSelected: true,
              customPercentage: 100.0),
        ],
      );

      final afterPaymentSettlements = calculateSettlements.calculate(
        expenses: [expense, payment],
        participants: [p1, p2],
      );
      expect(afterPaymentSettlements.isEmpty, true);
    });

    test('Edge cases: empty expenses', () {
      final settlements = calculateSettlements.calculate(
        expenses: [],
        participants: [createParticipant(1, 'A')],
      );
      expect(settlements.isEmpty, true);
    });

    test('Edge cases: empty participants', () {
      final settlements = calculateSettlements.calculate(
        expenses: [],
        participants: [],
      );
      expect(settlements.isEmpty, true);
    });

    test('Edge cases: everyone even', () {
      final p1 = createParticipant(1, 'A');
      final p2 = createParticipant(2, 'B');
      final expense = GroupExpense(
        id: 1, eventId: 1, title: '1', amount: 100.0, paidByParticipantId: 1, paidByName: 'A', date: DateTime.now(), createdAt: DateTime.now(),
        splits: const [ExpenseSplit(id: 1, expenseId: 1, participantId: 1, splitAmount: 100.0, participantName: 'A', isSelected: true, customPercentage: 100.0)],
      );
      
      final settlements = calculateSettlements.calculate(
        expenses: [expense],
        participants: [p1, p2],
      );
      
      expect(settlements.isEmpty, true);
    });
  });
}
