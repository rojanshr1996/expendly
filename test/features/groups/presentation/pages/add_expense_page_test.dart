import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/app_text_field.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/domain/repositories/groups_repository.dart';
import 'package:expendly/features/groups/domain/usecases/calculate_splits.dart';
import 'package:expendly/features/groups/presentation/pages/add_expense_page.dart';
import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_groups_repository.dart';

Widget _wrapTestApp(Widget child, {Size size = const Size(390, 844)}) {
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
    if (!getIt.isRegistered<CalculateSplits>()) {
      getIt.registerLazySingleton<CalculateSplits>(
        () => CalculateSplits(),
      );
    }
  });

  setUp(() {
    repository = FakeGroupsRepository();

    if (getIt.isRegistered<GroupsRepository>()) {
      getIt.unregister<GroupsRepository>();
    }
    getIt.registerSingleton<GroupsRepository>(repository);
  });

  const participants = [
    EventParticipant(id: 1, eventId: 1, name: 'You', isOwner: true, colorIndex: 0),
    EventParticipant(id: 2, eventId: 1, name: 'Bob', email: 'bob@example.com', isOwner: false, colorIndex: 1),
  ];

  testWidgets('AddExpensePage renders without overflow and handles description input', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrapTestApp(
        const AddExpensePage(
          eventId: 1,
          participants: participants,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.byType(AppTextField), findsOneWidget);

    // Enter description
    await tester.enterText(find.byType(AppTextField), 'Dinner at Italian Place');
    await tester.pumpAndSettle();

    expect(find.text('Dinner at Italian Place'), findsOneWidget);
  });

  testWidgets('AddExpensePage saves successfully and pops without TextEditingController disposed error',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrapTestApp(
        const AddExpensePage(
          eventId: 1,
          participants: participants,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Enter amount
    final amountField = find.widgetWithText(TextField, '0');
    expect(amountField, findsOneWidget);
    await tester.enterText(amountField, '100');
    await tester.pumpAndSettle();

    // Enter description
    await tester.enterText(find.byType(AppTextField), 'Team Lunch');
    await tester.pumpAndSettle();

    // Tap Save Expense button
    final saveButton = find.text('Save Expense →');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));

    // Verify no exception was thrown and repository recorded the expense
    final expenses = await repository.getExpensesByEventId(1);
    expect(expenses.length, equals(1));
    expect(expenses.first.title, equals('Team Lunch'));
    expect(expenses.first.amount, equals(100.0));
  });
}
