import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/features/security/presentation/widgets/reset_pin_modal.dart';
import 'package:expendly/l10n/app_localizations.dart';

import '../../../../core/services/encryption_service_test.dart';

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

  group('ResetPinModal Component Tests', () {
    testWidgets('renders reset options (biometrics & secret answer)', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const ResetPinModal(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset Security PIN'), findsOneWidget);
      expect(find.text('Reset via Biometrics'), findsOneWidget);
      expect(find.text('Reset via Secret Answer'), findsOneWidget);
    });

    testWidgets('navigates to secret answer entry on selecting option', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const ResetPinModal(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset via Secret Answer'));
      await tester.pumpAndSettle();

      expect(find.text('What is your secret security key or word?'), findsOneWidget);
      expect(find.text('Verify & Reset PIN'), findsOneWidget);
    });
  });
}
