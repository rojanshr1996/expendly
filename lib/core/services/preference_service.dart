import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';
import 'secure_storage_service.dart';

/// Preference Service for persisting non-sensitive user preferences via SharedPreferences
/// and sensitive information (Security PIN, tokens) via SecureStorageService.
@lazySingleton
class PreferenceService {
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyCurrencyCode = 'primary_currency_code';
  static const String keyCurrencySymbol = 'currency_symbol';
  static const String keyLegacySecurityPin = 'security_pin';
  static const String keyBiometricsEnabled = 'biometrics_enabled';
  static const String keyThemeMode = 'theme_mode';
  static const String keyActivityViewMode = 'activity_view_mode';
  static const String keyLastSnapshotAt = 'last_snapshot_at';
  static const String keyLastSnapshotCount = 'last_snapshot_count';
  static const String keyLastSnapshotError = 'last_snapshot_error';
  static const String keyPendingRestoreSetup = 'pending_restore_setup';
  static const String keyBackupPromptShown = 'backup_prompt_shown';

  final SecureStorageService _secureStorage;
  SharedPreferences? _prefs;

  PreferenceService(this._secureStorage);

  // Reactive ValueNotifiers for app-wide instant UI updates
  final ValueNotifier<String> currencyCodeNotifier =
      ValueNotifier<String>('USD');
  final ValueNotifier<String> currencySymbolNotifier =
      ValueNotifier<String>('\$');
  final ValueNotifier<String> themeModeNotifier =
      ValueNotifier<String>('light');

  // In-memory cache for fast sync access
  bool _onboardingCompleted = false;
  String _currencyCode = 'USD';
  String _currencySymbol = '\$';
  String? _securityPin;
  bool _biometricsEnabled = false;
  String _themeMode = 'light';
  String _activityViewMode = 'calendar';
  String? _lastSnapshotAt;
  int _lastSnapshotCount = 0;
  String? _lastSnapshotError;
  bool _pendingRestoreSetup = false;
  bool _backupPromptShown = false;

  bool get isOnboardingCompleted => _onboardingCompleted;
  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  String? get securityPin => _securityPin;
  bool get isSecurityPinSet => _securityPin != null && _securityPin!.isNotEmpty;
  bool get canLogout => isSecurityPinSet;
  bool get isBiometricsEnabled => _biometricsEnabled;
  String get themeMode => _themeMode;
  String get activityViewMode => _activityViewMode;
  String? get lastSnapshotAt => _lastSnapshotAt;
  int get lastSnapshotCount => _lastSnapshotCount;
  String? get lastSnapshotError => _lastSnapshotError;
  bool get isPendingRestoreSetup => _pendingRestoreSetup;
  bool get isBackupPromptShown => _backupPromptShown;

  /// Initialize preference cache from persistent SharedPreferences and SecureStorage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = _prefs?.getBool(keyOnboardingCompleted) ?? false;
    _currencyCode = _prefs?.getString(keyCurrencyCode) ?? 'USD';
    _currencySymbol = _prefs?.getString(keyCurrencySymbol) ?? '\$';
    currencyCodeNotifier.value = _currencyCode;
    currencySymbolNotifier.value = _currencySymbol;
    _biometricsEnabled = _prefs?.getBool(keyBiometricsEnabled) ?? false;
    _themeMode = _prefs?.getString(keyThemeMode) ?? 'light';
    themeModeNotifier.value = _themeMode;
    _activityViewMode = _prefs?.getString(keyActivityViewMode) ?? 'calendar';
    _lastSnapshotAt = _prefs?.getString(keyLastSnapshotAt);
    _lastSnapshotCount = _prefs?.getInt(keyLastSnapshotCount) ?? 0;
    _lastSnapshotError = _prefs?.getString(keyLastSnapshotError);
    _pendingRestoreSetup = _prefs?.getBool(keyPendingRestoreSetup) ?? false;
    _backupPromptShown = _prefs?.getBool(keyBackupPromptShown) ?? false;

    // Check for legacy security PIN in SharedPreferences & migrate to SecureStorage
    final legacyPin = _prefs?.getString(keyLegacySecurityPin);
    if (legacyPin != null && legacyPin.isNotEmpty) {
      AppLogger.i(
          'Migrating legacy security PIN from SharedPreferences to SecureStorage');
      await _secureStorage.setSecurityPin(legacyPin);
      await _prefs?.remove(keyLegacySecurityPin);
      _securityPin = legacyPin;
    } else {
      _securityPin = await _secureStorage.getSecurityPin();
    }

    AppLogger.d(
        'PreferenceService initialized. OnboardingCompleted = $_onboardingCompleted, SecurityPinSet = $isSecurityPinSet');
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    _onboardingCompleted = completed;
    await _prefs?.setBool(keyOnboardingCompleted, completed);
    AppLogger.i('Preference persisted: OnboardingCompleted = $completed');
  }

  Future<void> setCurrency(
      {required String code, required String symbol}) async {
    _currencyCode = code;
    _currencySymbol = symbol;
    currencyCodeNotifier.value = code;
    currencySymbolNotifier.value = symbol;
    await _prefs?.setString(keyCurrencyCode, code);
    await _prefs?.setString(keyCurrencySymbol, symbol);
    AppLogger.i('Preference persisted: Currency set to $code ($symbol)');
  }

  Future<void> setSecurityPin(String? pin) async {
    _securityPin = pin;
    await _secureStorage.setSecurityPin(pin);
    // Ensure clean removal from SharedPreferences if legacy key remained
    if (_prefs?.containsKey(keyLegacySecurityPin) ?? false) {
      await _prefs?.remove(keyLegacySecurityPin);
    }
    AppLogger.i('Preference persisted to SecureStorage: Security PIN updated');
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    _biometricsEnabled = enabled;
    await _prefs?.setBool(keyBiometricsEnabled, enabled);
    AppLogger.i('Preference persisted: BiometricsEnabled = $enabled');
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    themeModeNotifier.value = mode;
    await _prefs?.setString(keyThemeMode, mode);
    AppLogger.i('Preference persisted: ThemeMode set to $mode');
  }

  Future<void> setActivityViewMode(String mode) async {
    _activityViewMode = mode;
    await _prefs?.setString(keyActivityViewMode, mode);
    AppLogger.i('Preference persisted: ActivityViewMode set to $mode');
  }

  /// Lock session logging out user to security verification screen
  Future<void> logout() async {
    AppLogger.i('User logged out. Session locked via Security PIN.');
  }

  // Security Recovery Question & Answer helpers
  Future<String?> getSecurityQuestion() => _secureStorage.getSecurityQuestion();
  Future<void> setSecurityQuestion(String question) =>
      _secureStorage.setSecurityQuestion(question);
  Future<void> setSecurityAnswer(String answer) =>
      _secureStorage.setSecurityAnswer(answer);
  Future<bool> verifySecurityAnswer(String answer) =>
      _secureStorage.verifySecurityAnswer(answer);

  Future<String?> getSecurityQuestion1() =>
      _secureStorage.getSecurityQuestion1();
  Future<void> setSecurityQuestion1(String question) =>
      _secureStorage.setSecurityQuestion1(question);
  Future<void> setSecurityAnswer1(String answer) =>
      _secureStorage.setSecurityAnswer1(answer);
  Future<bool> verifySecurityAnswer1(String answer) =>
      _secureStorage.verifySecurityAnswer1(answer);

  Future<String?> getSecurityQuestion2() =>
      _secureStorage.getSecurityQuestion2();
  Future<void> setSecurityQuestion2(String question) =>
      _secureStorage.setSecurityQuestion2(question);
  Future<void> setSecurityAnswer2(String answer) =>
      _secureStorage.setSecurityAnswer2(answer);
  Future<bool> verifySecurityAnswer2(String answer) =>
      _secureStorage.verifySecurityAnswer2(answer);

  Future<bool> hasSecurityAnswer() => _secureStorage.hasSecurityAnswer();

  Future<void> setLastSnapshotAt(String? value) async {
    _lastSnapshotAt = value;
    if (value != null) {
      await _prefs?.setString(keyLastSnapshotAt, value);
    } else {
      await _prefs?.remove(keyLastSnapshotAt);
    }
  }

  Future<void> setLastSnapshotCount(int count) async {
    _lastSnapshotCount = count;
    await _prefs?.setInt(keyLastSnapshotCount, count);
  }

  Future<void> setLastSnapshotError(String? error) async {
    _lastSnapshotError = error;
    if (error != null) {
      await _prefs?.setString(keyLastSnapshotError, error);
    } else {
      await _prefs?.remove(keyLastSnapshotError);
    }
  }

  Future<void> setPendingRestoreSetup(bool pending) async {
    _pendingRestoreSetup = pending;
    await _prefs?.setBool(keyPendingRestoreSetup, pending);
  }

  Future<void> setBackupPromptShown(bool shown) async {
    _backupPromptShown = shown;
    await _prefs?.setBool(keyBackupPromptShown, shown);
  }
}
