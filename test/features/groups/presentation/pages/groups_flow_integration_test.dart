import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/features/groups/data/datasources/groups_local_datasource.dart';
import 'package:expendly/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:expendly/features/groups/domain/repositories/groups_repository.dart';
import 'package:expendly/features/groups/domain/usecases/calculate_settlements.dart';
import 'package:expendly/features/groups/domain/usecases/calculate_splits.dart';

void main() {
  late AppDatabase db;
  late GroupsLocalDataSource dataSource;
  late GroupsRepository repository;
  late CalculateSplits calculateSplits;
  late CalculateSettlements calculateSettlements;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = GroupsLocalDataSourceImpl(db);
    repository = GroupsRepositoryImpl(dataSource);
    calculateSplits = CalculateSplits();
    calculateSettlements = CalculateSettlements();
  });

  tearDown(() async {
    await db.close();
  });

  test('Full Expense Sharing Flow: Create Event -> Add Participants -> Add Expenses -> Settle Debts -> Mark Settled',
      () async {
    // 1. Create Event: Trip to Bali
    final eventId = await repository.createEvent(
      name: 'Trip to Bali',
      description: 'Summer holiday with friends',
      startDate: DateTime(2026, 7, 1),
      category: 'trip',
    );
    expect(eventId, isNonZero);

    // 2. Add Participants: You (Owner), Bob, Charlie
    final p1Id = await repository.addParticipant(
      eventId: eventId,
      name: 'You',
      email: 'you@expendly.app',
      isOwner: true,
      colorIndex: 0,
    );
    final p2Id = await repository.addParticipant(
      eventId: eventId,
      name: 'Bob',
      email: 'bob@example.com',
      isOwner: false,
      colorIndex: 1,
    );
    final p3Id = await repository.addParticipant(
      eventId: eventId,
      name: 'Charlie',
      email: 'charlie@example.com',
      isOwner: false,
      colorIndex: 2,
    );

    final participants = await repository.getParticipantsByEventId(eventId);
    expect(participants.length, equals(3));

    // 3. Expense 1: Villa ($300 paid by You, split equally among You, Bob, Charlie)
    final villaSplits = calculateSplits.calculate(
      totalAmount: 300.0,
      selectedParticipantIds: [p1Id, p2Id, p3Id],
    );
    expect(villaSplits.length, equals(3));
    expect(villaSplits.every((s) => s.amount == 100.0), isTrue);

    final exp1Id = await repository.addExpense(
      eventId: eventId,
      title: 'Villa Rental',
      amount: 300.0,
      paidByParticipantId: p1Id,
      date: DateTime(2026, 7, 2),
      splits: villaSplits
          .map((s) => ExpenseSplitInput(
                participantId: s.participantId,
                splitAmount: s.amount,
              ))
          .toList(),
    );
    expect(exp1Id, isNonZero);

    // 4. Expense 2: Dinner ($90 paid by Bob, Charlie pays 50%, remaining 50% split equally between You and Bob)
    final dinnerSplits = calculateSplits.calculate(
      totalAmount: 90.0,
      selectedParticipantIds: [p1Id, p2Id, p3Id],
      customPercentages: {p3Id: 50.0},
    );
    expect(dinnerSplits.firstWhere((s) => s.participantId == p3Id).amount, equals(45.0));
    expect(dinnerSplits.firstWhere((s) => s.participantId == p1Id).amount, equals(22.5));
    expect(dinnerSplits.firstWhere((s) => s.participantId == p2Id).amount, equals(22.5));

    final exp2Id = await repository.addExpense(
      eventId: eventId,
      title: 'Seafood Dinner',
      amount: 90.0,
      paidByParticipantId: p2Id,
      date: DateTime(2026, 7, 3),
      splits: dinnerSplits
          .map((s) => ExpenseSplitInput(
                participantId: s.participantId,
                customPercentage: s.participantId == p3Id ? 50.0 : 25.0,
                splitAmount: s.amount,
              ))
          .toList(),
    );
    expect(exp2Id, isNonZero);

    // 5. Verify Event Totals
    final event = await repository.getEventById(eventId);
    expect(event.totalSpent, equals(390.0));
    // User share: $100 (villa) + $22.5 (dinner) = $122.5
    expect(event.userShare, equals(122.5));

    // 6. Calculate Settlements
    final expenses = await repository.getExpensesByEventId(eventId);
    final settlements = calculateSettlements.calculate(
      expenses: expenses,
      participants: participants,
    );

    // Direct pairwise debts:
    // 1. Bob owes You: $100 (Villa) - $22.5 (Dinner) = $77.5
    // 2. Charlie owes You: $100 (Villa)
    // 3. Charlie owes Bob: $45 (Dinner)
    expect(settlements.length, equals(3));
    final bobToYou = settlements.firstWhere((s) => s.fromParticipant.id == p2Id && s.toParticipant.id == p1Id);
    expect(bobToYou.amount, equals(77.5));

    final charlieToYou = settlements.firstWhere((s) => s.fromParticipant.id == p3Id && s.toParticipant.id == p1Id);
    expect(charlieToYou.amount, equals(100.0));

    final charlieToBob = settlements.firstWhere((s) => s.fromParticipant.id == p3Id && s.toParticipant.id == p2Id);
    expect(charlieToBob.amount, equals(45.0));

    // 7. Record Settlement: Bob pays You $77.5
    final settlementPaymentId = await repository.recordSettlement(
      eventId: eventId,
      fromParticipantId: p2Id,
      toParticipantId: p1Id,
      amount: 77.5,
    );
    expect(settlementPaymentId, isNonZero);

    final expensesAfterBobSettle = await repository.getExpensesByEventId(eventId);
    final settlementsAfterBobSettle = calculateSettlements.calculate(
      expenses: expensesAfterBobSettle,
      participants: participants,
    );
    // Now Bob and You are settled. Charlie owes You $100.0 and Charlie owes Bob $45.0
    expect(settlementsAfterBobSettle.length, equals(2));
    expect(settlementsAfterBobSettle.any((s) => s.fromParticipant.id == p3Id && s.toParticipant.id == p1Id && s.amount == 100.0), isTrue);
    expect(settlementsAfterBobSettle.any((s) => s.fromParticipant.id == p3Id && s.toParticipant.id == p2Id && s.amount == 45.0), isTrue);

    // 8. Mark Event as Settled
    await repository.markEventSettled(eventId);
    final settledEvent = await repository.getEventById(eventId);
    expect(settledEvent.status, equals('settled'));

    // 9. Delete Event
    await repository.deleteEvent(eventId);
    final remainingEvents = await repository.getAllEvents();
    expect(remainingEvents, isEmpty);
  });
}
