import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/domain/entities/expense_split.dart';
import 'package:expendly/features/groups/domain/entities/group_expense.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'package:expendly/features/groups/presentation/pages/expense_details_page.dart';
import 'package:expendly/l10n/app_localizations.dart';

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

  final event = SharingEvent(
    id: 1,
    name: 'Road Trip',
    description: 'Road trip to mountains',
    startDate: DateTime.now(),
    category: 'trip',
    status: 'active',
    createdAt: DateTime.now(),
    participants: const [
      EventParticipant(id: 1, eventId: 1, name: 'You', colorIndex: 0, isOwner: true),
      EventParticipant(id: 2, eventId: 1, name: 'Bob', colorIndex: 1, isOwner: false),
    ],
    totalSpent: 200.0,
    userShare: 100.0,
  );

  final expense = GroupExpense(
    id: 10,
    eventId: 1,
    title: 'Fuel Station',
    amount: 100.0,
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
        splitAmount: 50.0,
        isSelected: true,
      ),
      ExpenseSplit(
        id: 2,
        expenseId: 10,
        participantId: 2,
        participantName: 'Bob',
        splitAmount: 50.0,
        isSelected: true,
      ),
    ],
  );

  testWidgets('ExpenseDetailsPage renders 2-column layout on tablet without errors', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrapTestApp(
        ExpenseDetailsPage(
          expense: expense,
          event: event,
        ),
        size: const Size(1024, 768),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Fuel Station'), findsWidgets);
    expect(find.text('Road Trip'), findsOneWidget);
    expect(find.text('Delete Expense'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ExpenseDetailsPage renders single-column layout on mobile without errors', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrapTestApp(
        ExpenseDetailsPage(
          expense: expense,
          event: event,
        ),
        size: const Size(390, 844),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Fuel Station'), findsWidgets);
    expect(find.text('Road Trip'), findsOneWidget);
    expect(find.text('Delete Expense'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
