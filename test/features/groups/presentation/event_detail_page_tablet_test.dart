import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/master_detail_layout.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/domain/entities/expense_split.dart';
import 'package:expendly/features/groups/domain/entities/group_expense.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'package:expendly/features/groups/domain/usecases/calculate_settlements.dart';
import 'package:expendly/features/groups/presentation/cubit/event_detail_cubit.dart';
import 'package:expendly/features/groups/presentation/pages/event_detail_page.dart';
import 'package:expendly/features/groups/presentation/widgets/balances_tab_view.dart';
import 'package:expendly/features/groups/presentation/widgets/expenses_tab_view.dart';
import 'package:expendly/l10n/app_localizations.dart';

import 'fake_groups_repository.dart';

Widget _wrapTestApp(Widget child, {Size size = const Size(1024, 768)}) {
  return ScreenUtilInit(
    designSize: size,
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeGroupsRepository repository;
  late CalculateSettlements calculateSettlements;
  late EventDetailCubit cubit;

  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );

    if (!getIt.isRegistered<SecureStorageService>()) {
      getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
      );
    }
    if (!getIt.isRegistered<PreferenceService>()) {
      getIt.registerLazySingleton<PreferenceService>(
        () => PreferenceService(getIt<SecureStorageService>()),
      );
    }
  });

  setUp(() {
    repository = FakeGroupsRepository();
    calculateSettlements = CalculateSettlements();
    cubit = EventDetailCubit(repository, calculateSettlements);

    if (getIt.isRegistered<EventDetailCubit>()) {
      getIt.unregister<EventDetailCubit>();
    }
    getIt.registerSingleton<EventDetailCubit>(cubit);
  });

  tearDown(() {
    cubit.close();
  });

  testWidgets('EventDetailPage renders MasterDetailLayout on tablet without layout exceptions', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final participants = [
      const EventParticipant(id: 1, eventId: 1, name: 'You', colorIndex: 0, isOwner: true),
      const EventParticipant(id: 2, eventId: 1, name: 'Alice', colorIndex: 1, isOwner: false),
    ];

    final event = SharingEvent(
      id: 1,
      name: 'Weekend Trip',
      description: 'Trip with friends',
      startDate: DateTime.now(),
      category: 'trip',
      status: 'active',
      createdAt: DateTime.now(),
      participants: participants,
      totalSpent: 120.0,
      userShare: 60.0,
    );

    final expenses = [
      GroupExpense(
        id: 10,
        eventId: 1,
        title: 'Dinner',
        amount: 120.0,
        paidByParticipantId: 1,
        paidByName: 'You',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        splits: const [],
      ),
    ];

    repository.events.add(event);
    repository.participants.addAll(participants);
    repository.expenses.addAll(expenses);

    await cubit.loadEventDetail(1);

    await tester.pumpWidget(
      _wrapTestApp(
        const EventDetailPage(eventId: 1),
        size: const Size(1024, 768),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify MasterDetailLayout is present on tablet
    expect(find.byType(MasterDetailLayout), findsOneWidget);
    expect(find.byType(BalancesTabView), findsOneWidget);
    expect(find.byType(ExpensesTabView), findsOneWidget);
    expect(find.text('Weekend Trip'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EventDetailPage renders settlements and group overview without text squeezing on tablet', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final participants = [
      const EventParticipant(id: 1, eventId: 1, name: 'You', colorIndex: 0, isOwner: true),
      const EventParticipant(id: 2, eventId: 1, name: 'test', colorIndex: 1, isOwner: false),
      const EventParticipant(id: 3, eventId: 1, name: 'test2', colorIndex: 2, isOwner: false),
    ];

    final event = SharingEvent(
      id: 1,
      name: 'test',
      description: 'Test Event',
      startDate: DateTime.now(),
      category: 'general',
      status: 'active',
      createdAt: DateTime.now(),
      participants: participants,
      totalSpent: 5300.0,
      userShare: 1766.67,
    );

    final expenses = [
      GroupExpense(
        id: 10,
        eventId: 1,
        title: 'food',
        amount: 5300.0,
        paidByParticipantId: 1,
        paidByName: 'You',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        splits: const [
          ExpenseSplit(
            id: 1,
            expenseId: 10,
            participantId: 1,
            participantName: 'You',
            splitAmount: 1766.66,
            isSelected: true,
          ),
          ExpenseSplit(
            id: 2,
            expenseId: 10,
            participantId: 2,
            participantName: 'test',
            splitAmount: 1766.67,
            isSelected: true,
          ),
          ExpenseSplit(
            id: 3,
            expenseId: 10,
            participantId: 3,
            participantName: 'test2',
            splitAmount: 1766.67,
            isSelected: true,
          ),
        ],
      ),
    ];

    repository.events.add(event);
    repository.participants.addAll(participants);
    repository.expenses.addAll(expenses);

    await cubit.loadEventDetail(1);

    await tester.pumpWidget(
      _wrapTestApp(
        const EventDetailPage(eventId: 1),
        size: const Size(1024, 768),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MasterDetailLayout), findsOneWidget);
    expect(find.text('GROUP BALANCES OVERVIEW'), findsOneWidget);
    expect(find.text('Remind'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
