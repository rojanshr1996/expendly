import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'encryption_service_test.dart';

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
    fakeSecureStorage = FakeSecureStorageService();
    preferenceService = PreferenceService(fakeSecureStorage);
  });

  group('PreferenceService Tests', () {
    test('Should initialize with defaults when storage is empty', () async {
      SharedPreferences.setMockInitialValues({});
      await preferenceService.init();

      expect(preferenceService.isOnboardingCompleted, isFalse);
      expect(preferenceService.currencyCode, equals('USD'));
      expect(preferenceService.currencySymbol, equals('\$'));
      expect(preferenceService.isSecurityPinSet, isFalse);
      expect(preferenceService.securityPin, isNull);
    });

    test('Should persist non-sensitive settings in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      await preferenceService.init();

      await preferenceService.setOnboardingCompleted(true);
      await preferenceService.setCurrency(code: 'NPR', symbol: 'Rs.');
      await preferenceService.setThemeMode('light');

      expect(preferenceService.isOnboardingCompleted, isTrue);
      expect(preferenceService.currencyCode, equals('NPR'));
      expect(preferenceService.currencySymbol, equals('Rs.'));
      expect(preferenceService.themeMode, equals('light'));
    });

    test('Should persist security PIN in SecureStorageService', () async {
      SharedPreferences.setMockInitialValues({});
      await preferenceService.init();

      await preferenceService.setSecurityPin('5678');

      expect(preferenceService.isSecurityPinSet, isTrue);
      expect(preferenceService.securityPin, equals('5678'));

      final storedPinInSecureStorage = await fakeSecureStorage.getSecurityPin();
      expect(storedPinInSecureStorage, equals('5678'));
    });

    test('Should set and verify max 2 secret recovery questions & answers independently', () async {
      SharedPreferences.setMockInitialValues({});
      await preferenceService.init();

      await preferenceService.setSecurityQuestion1('What is your passphrase?');
      await preferenceService.setSecurityAnswer1(' SecretOne ');

      await preferenceService.setSecurityQuestion2('In what city were you born?');
      await preferenceService.setSecurityAnswer2(' Kathmandu ');

      final q1 = await preferenceService.getSecurityQuestion1();
      expect(q1, equals('What is your passphrase?'));

      final q2 = await preferenceService.getSecurityQuestion2();
      expect(q2, equals('In what city were you born?'));

      final isHasAnswer = await preferenceService.hasSecurityAnswer();
      expect(isHasAnswer, isTrue);

      final isQ1Correct = await preferenceService.verifySecurityAnswer1('secretone');
      expect(isQ1Correct, isTrue);

      final isQ2Correct = await preferenceService.verifySecurityAnswer2('kathmandu');
      expect(isQ2Correct, isTrue);

      final isQ1Wrong = await preferenceService.verifySecurityAnswer1('wrong');
      expect(isQ1Wrong, isFalse);
    });

    test('Should automatically migrate legacy PIN from SharedPreferences to SecureStorageService', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceService.keyLegacySecurityPin: '9999',
        PreferenceService.keyOnboardingCompleted: true,
      });

      await preferenceService.init();

      // Check in-memory state
      expect(preferenceService.isOnboardingCompleted, isTrue);
      expect(preferenceService.securityPin, equals('9999'));

      // Check PIN was migrated to SecureStorage
      final securePin = await fakeSecureStorage.getSecurityPin();
      expect(securePin, equals('9999'));

      // Check PIN was removed from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(PreferenceService.keyLegacySecurityPin), isFalse);
    });
  });
}
