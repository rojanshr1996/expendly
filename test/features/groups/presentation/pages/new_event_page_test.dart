import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/app_button.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'package:expendly/features/groups/domain/repositories/groups_repository.dart';
import 'package:expendly/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:expendly/features/groups/presentation/pages/new_event_page.dart';
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
  });

  setUp(() {
    repository = FakeGroupsRepository();

    if (getIt.isRegistered<GroupsRepository>()) {
      getIt.unregister<GroupsRepository>();
    }
    getIt.registerSingleton<GroupsRepository>(repository);

    if (getIt.isRegistered<GroupsCubit>()) {
      getIt.unregister<GroupsCubit>();
    }
    getIt.registerSingleton<GroupsCubit>(GroupsCubit(repository));
  });

  testWidgets('NewEventPage in Edit Mode displays remove button and allows removing newly added participants',
      (tester) async {
    final event = SharingEvent(
      id: 1,
      name: 'Trip to Tokyo',
      description: 'Vacation',
      startDate: DateTime(2026, 7, 1),
      category: 'trip',
      status: 'active',
      createdAt: DateTime(2026, 7, 1),
      participants: const [
        EventParticipant(id: 1, eventId: 1, name: 'You', isOwner: true, colorIndex: 0),
        EventParticipant(id: 2, eventId: 1, name: 'Bob', email: 'bob@example.com', isOwner: false, colorIndex: 1),
      ],
      totalSpent: 0,
      userShare: 0,
    );

    await tester.pumpWidget(_wrapTestApp(NewEventPage(event: event)));
    await tester.pumpAndSettle();

    // Verify Bob has a remove button (Icons.close_rounded)
    expect(find.text('Bob'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Add a new participant "Charlie"
    final nameField = find.widgetWithText(TextField, 'e.g. Sarah');
    await tester.ensureVisible(nameField);
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Charlie');
    await tester.pumpAndSettle();

    final addBtn = find.text('+ Add Participant');
    await tester.ensureVisible(addBtn);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Now Charlie should be added and have a close button
    expect(find.text('Charlie'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNWidgets(2)); // Bob and Charlie

    // Remove Charlie
    final charlieRemoveBtn = find.byIcon(Icons.close_rounded).last;
    await tester.tap(charlieRemoveBtn);
    await tester.pumpAndSettle();

    // Charlie is removed
    expect(find.text('Charlie'), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget); // Only Bob left
  });

  testWidgets('NewEventPage does not show duplicate edit buttons and has clean list UI without unpleasant dividers',
      (tester) async {
    final event = SharingEvent(
      id: 1,
      name: 'Trip to Tokyo',
      description: 'Vacation',
      startDate: DateTime(2026, 7, 1),
      category: 'trip',
      status: 'active',
      createdAt: DateTime(2026, 7, 1),
      participants: const [
        EventParticipant(id: 1, eventId: 1, name: 'You', isOwner: true, colorIndex: 0),
        EventParticipant(id: 2, eventId: 1, name: 'Alice', email: 'alice@example.com', isOwner: false, colorIndex: 1),
      ],
      totalSpent: 0,
      userShare: 0,
    );

    await tester.pumpWidget(_wrapTestApp(NewEventPage(event: event)));
    await tester.pumpAndSettle();

    // No trailing edit button exists; there is only the remove button for Alice
    expect(find.byIcon(Icons.edit_outlined), findsNothing);

    // There should be NO Dividers inside the card
    expect(find.byType(Divider), findsNothing);

    // The section header exists
    expect(find.text('EVENT PARTICIPANTS'), findsOneWidget);
    expect(find.text('2 members'), findsOneWidget);
  });

  testWidgets('Tapping participant opens edit participant bottom sheet and allows updating details', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final event = SharingEvent(
      id: 1,
      name: 'Trip to Tokyo',
      description: 'Vacation',
      startDate: DateTime(2026, 7, 1),
      category: 'trip',
      status: 'active',
      createdAt: DateTime(2026, 7, 1),
      participants: const [
        EventParticipant(id: 1, eventId: 1, name: 'You', isOwner: true, colorIndex: 0),
        EventParticipant(id: 2, eventId: 1, name: 'Alice', email: 'alice@example.com', isOwner: false, colorIndex: 1),
      ],
      totalSpent: 0,
      userShare: 0,
    );

    await tester.pumpWidget(_wrapTestApp(NewEventPage(event: event)));
    await tester.pumpAndSettle();

    // Tap Alice to open edit sheet
    final aliceFinder = find.text('Alice');
    expect(aliceFinder, findsOneWidget);
    await tester.ensureVisible(aliceFinder);
    await tester.tap(aliceFinder);
    await tester.pumpAndSettle();

    // Verify Edit Participant sheet is open
    expect(find.text('Edit Participant'), findsOneWidget);
    expect(find.text('Update details for Alice'), findsOneWidget);
    expect(find.text('Clear Email'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Update name to "Alicia"
    final nameField = find.widgetWithText(TextField, 'Alice');
    await tester.enterText(nameField, 'Alicia');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify updated name is displayed in the list
    expect(find.text('Alicia'), findsOneWidget);
  });

  testWidgets('Edit participant bottom sheet handles keyboard display without RenderFlex overflow', (tester) async {
    final event = SharingEvent(
      id: 1,
      name: 'Trip to Tokyo',
      description: 'Vacation',
      startDate: DateTime(2026, 7, 1),
      category: 'trip',
      status: 'active',
      createdAt: DateTime(2026, 7, 1),
      participants: const [
        EventParticipant(id: 1, eventId: 1, name: 'You', isOwner: true, colorIndex: 0),
        EventParticipant(id: 2, eventId: 1, name: 'Alice', email: 'alice@example.com', isOwner: false, colorIndex: 1),
      ],
      totalSpent: 0,
      userShare: 0,
    );

    await tester.pumpWidget(_wrapTestApp(NewEventPage(event: event)));
    await tester.pumpAndSettle();

    final aliceFinder = find.text('Alice');
    expect(aliceFinder, findsOneWidget);
    await tester.ensureVisible(aliceFinder);
    await tester.pumpAndSettle();
    await tester.tap(aliceFinder);
    await tester.pumpAndSettle();

    // Verify modal is open
    expect(find.text('Edit Participant'), findsOneWidget);

    // Simulate keyboard popping up by drastically reducing available vertical space
    tester.view.physicalSize = const Size(800, 320);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pump();

    // Verify modal content is rendered and scrollable without RenderFlex overflow
    expect(find.text('Edit Participant'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets(
      'Category field and picker sheet render with befitting icons, search filter, and selection',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapTestApp(const NewEventPage()));
    await tester.pumpAndSettle();

    // Verify initial category is Trip and has flight icon
    expect(find.text('Trip'), findsOneWidget);
    expect(find.byIcon(Icons.flight_takeoff_rounded), findsOneWidget);

    // Tap category field to open picker
    await tester.tap(find.text('Trip'));
    await tester.pumpAndSettle();

    // Verify category picker sheet is displayed with search bar and categories
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Party'), findsOneWidget);
    expect(find.byIcon(Icons.celebration_rounded), findsOneWidget);

    // Search for "Dinner"
    final searchField = find.byType(TextField).last;
    await tester.enterText(searchField, 'Dinner');
    await tester.pumpAndSettle();

    // Verify only dinner matches in the grid
    final dinnerItem =
        find.descendant(of: find.byType(GridView), matching: find.text('Dinner'));
    expect(dinnerItem, findsOneWidget);
    expect(find.text('Party'), findsNothing);

    // Tap Dinner to select it
    await tester.tap(dinnerItem);
    await tester.pumpAndSettle();

    // Verify category field on page is updated to Dinner with restaurant icon
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
  });

  testWidgets(
      'Add Participant button has proper green styling and adds participant',
      (tester) async {
    await tester.pumpWidget(_wrapTestApp(const NewEventPage()));
    await tester.pumpAndSettle();

    final addBtnFinder = find.widgetWithText(AppButton, '+ Add Participant');
    expect(addBtnFinder, findsOneWidget);

    final appButton = tester.widget<AppButton>(addBtnFinder);
    expect(appButton.backgroundColor, const Color(0xFF15803D));
    expect(appButton.foregroundColor, Colors.white);

    // Enter participant name and tap button
    final nameField = find.widgetWithText(TextField, 'e.g. Sarah');
    await tester.enterText(nameField, 'Diana');
    await tester.pumpAndSettle();

    await tester.ensureVisible(addBtnFinder);
    await tester.pumpAndSettle();

    await tester.tap(addBtnFinder);
    await tester.pumpAndSettle();

    expect(find.text('Diana'), findsOneWidget);
  });
}
