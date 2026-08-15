import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:expendly/features/groups/presentation/cubit/groups_state.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'fake_groups_repository.dart';

void main() {
  late FakeGroupsRepository repository;
  late GroupsCubit cubit;

  setUp(() {
    repository = FakeGroupsRepository();
    cubit = GroupsCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('GroupsCubit', () {
    test('Initial state is GroupsInitial', () {
      expect(cubit.state, isA<GroupsInitial>());
    });

    test('loadEvents success', () async {
      repository.events = [
        SharingEvent(
          id: 1,
          name: 'Test Event',
          description: '',
          startDate: DateTime.now(),
          category: 'trip',
          status: 'active',
          createdAt: DateTime.now(),
          participants: const [],
          totalSpent: 0,
          userShare: 0,
        )
      ];

      await cubit.loadEvents();

      expect(cubit.state, isA<GroupsLoaded>());
      final state = cubit.state as GroupsLoaded;
      expect(state.events.length, 1);
      expect(state.events[0].name, 'Test Event');
    });

    test('loadEvents failure', () async {
      repository.shouldThrow = true;
      await cubit.loadEvents();
      expect(cubit.state, isA<GroupsError>());
    });

    test('createEvent success', () async {
      await cubit.createEvent(
        name: 'New Event',
        startDate: DateTime.now(),
      );
      await Future.delayed(Duration.zero);

      // it should emit GroupsActionSuccess then loadEvents which will emit GroupsLoaded
      expect(cubit.state, isA<GroupsLoaded>());
      final state = cubit.state as GroupsLoaded;
      expect(state.events.length, 1);
      expect(state.events[0].name, 'New Event');
    });

    test('createEvent failure', () async {
      repository.shouldThrow = true;
      await cubit.createEvent(
        name: 'New Event',
        startDate: DateTime.now(),
      );
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<GroupsError>());
    });

    test('updateEvent success', () async {
      repository.events.add(SharingEvent(
        id: 1, name: 'Old', description: '', startDate: DateTime.now(), category: 'trip', status: 'active', createdAt: DateTime.now(), participants: const [], totalSpent: 0, userShare: 0,
      ));

      await cubit.updateEvent(id: 1, name: 'Updated');
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<GroupsLoaded>());
      final state = cubit.state as GroupsLoaded;
      expect(state.events.first.name, 'Updated');
    });

    test('deleteEvent success', () async {
      repository.events.add(SharingEvent(
        id: 1, name: 'Old', description: '', startDate: DateTime.now(), category: 'trip', status: 'active', createdAt: DateTime.now(), participants: const [], totalSpent: 0, userShare: 0,
      ));

      await cubit.deleteEvent(1);
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<GroupsLoaded>());
      final state = cubit.state as GroupsLoaded;
      expect(state.events.isEmpty, true);
    });
  });
}
