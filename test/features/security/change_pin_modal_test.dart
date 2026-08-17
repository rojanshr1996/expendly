import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/features/security/presentation/widgets/change_pin_modal.dart';
import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/encryption_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );
  });

  late FakeSecureStorageService fakeSecureStorage;
  late PreferenceService preferenceService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    fakeSecureStorage = FakeSecureStorageService();
    preferenceService = PreferenceService(fakeSecureStorage);
    await preferenceService.init();
    getIt.registerSingleton<PreferenceService>(preferenceService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget wrapWithMaterial(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('ChangePinModal Widget Tests', () {
    testWidgets('Renders setup PIN flow when no PIN is configured', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithMaterial(const ChangePinModal()));
      await tester.pumpAndSettle();

      // Starts at Step 1 of 2
      expect(find.text('STEP 1 OF 2'), findsOneWidget);
      expect(find.text('Set Security PIN'), findsOneWidget);

      // Keypad numbers are visible
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('Allows entering new PIN and confirming PIN successfully', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithMaterial(const ChangePinModal()));
      await tester.pumpAndSettle();

      // Enter 1, 2, 3, 4 for Step 1
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Transitions to Step 2 of 2 (Confirm New PIN)
      expect(find.text('STEP 2 OF 2'), findsOneWidget);
      expect(find.text('Confirm New 4-Digit PIN'), findsOneWidget);

      // Enter matching 1, 2, 3, 4 for Step 2
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // PIN is saved to PreferenceService
      expect(getIt<PreferenceService>().securityPin, equals('1234'));
      expect(getIt<PreferenceService>().isSecurityPinSet, isTrue);
    });

    testWidgets('Renders Step 1 of 3 when PIN is already configured', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await getIt<PreferenceService>().setSecurityPin('5678');

      await tester.pumpWidget(wrapWithMaterial(const ChangePinModal()));
      await tester.pumpAndSettle();

      // Starts at Step 1 of 3 (Verify Current PIN)
      expect(find.text('STEP 1 OF 3'), findsOneWidget);
      expect(find.text('Enter Current PIN'), findsOneWidget);
      expect(find.text('Forgot?'), findsOneWidget);

      // Enter correct current PIN: 5, 6, 7, 8
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('6'));
      await tester.pump();
      await tester.tap(find.text('7'));
      await tester.pump();
      await tester.tap(find.text('8'));
      await tester.pumpAndSettle();

      // Transitions to Step 2 of 3 (Enter New PIN)
      expect(find.text('STEP 2 OF 3'), findsOneWidget);
      expect(find.text('Enter New 4-Digit PIN'), findsOneWidget);
    });
  });
}
