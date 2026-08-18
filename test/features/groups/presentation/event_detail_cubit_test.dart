import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/features/groups/presentation/cubit/event_detail_cubit.dart';
import 'package:expendly/features/groups/presentation/cubit/event_detail_state.dart';
import 'package:expendly/features/groups/domain/usecases/calculate_settlements.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'package:expendly/features/groups/domain/entities/group_expense.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'fake_groups_repository.dart';

void main() {
  late FakeGroupsRepository repository;
  late CalculateSettlements calculateSettlements;
  late EventDetailCubit cubit;

  setUp(() {
    repository = FakeGroupsRepository();
    calculateSettlements = CalculateSettlements();
    cubit = EventDetailCubit(repository, calculateSettlements);
  });

  tearDown(() {
    cubit.close();
  });

  group('EventDetailCubit', () {
    test('Initial state is EventDetailInitial', () {
      expect(cubit.state, isA<EventDetailInitial>());
    });

    test('loadEventDetail success', () async {
      repository.events.add(SharingEvent(
        id: 1, name: 'Event', description: '', startDate: DateTime.now(), category: 'trip', status: 'active', createdAt: DateTime.now(), participants: const [], totalSpent: 0, userShare: 0,
      ));
      
      await cubit.loadEventDetail(1);

      expect(cubit.state, isA<EventDetailLoaded>());
      final state = cubit.state as EventDetailLoaded;
      expect(state.event.id, 1);
      expect(state.expenses.isEmpty, true);
      expect(state.settlements.isEmpty, true);
    });

    test('deleteExpense success', () async {
      repository.events.add(SharingEvent(
        id: 1, name: 'Event', description: '', startDate: DateTime.now(), category: 'trip', status: 'active', createdAt: DateTime.now(), participants: const [], totalSpent: 0, userShare: 0,
      ));
      repository.expenses.add(GroupExpense(
        id: 10, eventId: 1, title: 'Dinner', amount: 100, paidByParticipantId: 1, paidByName: 'User', date: DateTime.now(), createdAt: DateTime.now(), splits: const [],
      ));

      await cubit.loadEventDetail(1);
      
      expect(repository.expenses.length, 1);
      
      await cubit.deleteExpense(10);
      await Future.delayed(Duration.zero);
      
      expect(repository.expenses.length, 0);
      expect(cubit.state, isA<EventDetailLoaded>());
      final state = cubit.state as EventDetailLoaded;
      expect(state.expenses.isEmpty, true);
    });

    test('recordSettlement adds payment and reloads event detail', () async {
      repository.events.add(SharingEvent(
        id: 1, name: 'Event', description: '', startDate: DateTime.now(), category: 'trip', status: 'active', createdAt: DateTime.now(), participants: const [], totalSpent: 0, userShare: 0,
      ));
      repository.participants.addAll([
        const EventParticipant(id: 1, eventId: 1, name: 'You', colorIndex: 0, isOwner: true),
        const EventParticipant(id: 2, eventId: 1, name: 'Alice', colorIndex: 1, isOwner: false),
      ]);

      await cubit.loadEventDetail(1);

      await cubit.recordSettlement(
        fromParticipantId: 2,
        toParticipantId: 1,
        amount: 50.0,
        note: 'Alice paid You',
      );
      await Future.delayed(Duration.zero);

      expect(repository.expenses.length, 1);
      expect(repository.expenses.first.title, 'Alice paid You');
      expect(repository.expenses.first.amount, 50.0);
      expect(repository.expenses.first.paidByParticipantId, 2);
    });

    test('markEventSettled marks status as settled and reloads', () async {
      repository.events.add(SharingEvent(
        id: 1, name: 'Event', description: '', startDate: DateTime.now(), category: 'trip', status: 'active', createdAt: DateTime.now(), participants: const [], totalSpent: 0, userShare: 0,
      ));

      await cubit.loadEventDetail(1);
      await cubit.markEventSettled();
      await Future.delayed(Duration.zero);

      expect(repository.events.first.status, 'settled');
    });
  });
}
