import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';
import '../utils/app_logger.dart';

enum AppUpdateStatus {
  none,
  optionalUpdate,
  forceUpdate,
}

@lazySingleton
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Remote Config Keys
  static const String keyMinRequiredVersion = 'min_required_version';
  static const String keyLatestVersion = 'latest_version';
  static const String keyIsMaintenanceMode = 'is_maintenance_mode';
  static const String keyIsAdsEnabled = 'is_ads_enabled';

  static const String keyForceUpdateTitle = 'force_update_title';
  static const String keyForceUpdateMessage = 'force_update_message';

  static const String keyOptionalUpdateTitle = 'optional_update_title';
  static const String keyOptionalUpdateMessage = 'optional_update_message';

  static const String keyMaintenanceTitle = 'maintenance_title';
  static const String keyMaintenanceMessage = 'maintenance_message';

  static const String keyUpdateUrlAndroid = 'update_url_android';
  static const String keyUpdateUrlIos = 'update_url_ios';

  final StreamController<bool> _maintenanceStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get onMaintenanceChanged => _maintenanceStreamController.stream;

  final StreamController<AppUpdateStatus> _updateStatusStreamController =
      StreamController<AppUpdateStatus>.broadcast();
  Stream<AppUpdateStatus> get onUpdateStatusChanged =>
      _updateStatusStreamController.stream;

  final StreamController<bool> _adsEnabledStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get onAdsEnabledChanged => _adsEnabledStreamController.stream;

  /// Initializes Remote Config defaults, fetch strategy, and listeners.
  Future<void> initialize() async {
    // Unconditionally set minimumFetchInterval to Duration.zero to ensure
    // remote config is freshly fetched from the server every time.
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    // 1. Set In-App Defaults
    await _remoteConfig.setDefaults({
      keyMinRequiredVersion: AppConfig.appVersion,
      keyLatestVersion: AppConfig.appVersion,
      keyIsMaintenanceMode: false,
      keyIsAdsEnabled: true,
      keyForceUpdateTitle: 'Time for an Update!',
      keyForceUpdateMessage:
          'We’ve added important improvements and enhancements to keep your experience smooth and secure. Please update Expendly to the latest version to continue.',
      keyOptionalUpdateTitle: 'New Version Available!',
      keyOptionalUpdateMessage:
          'A new update is ready with fresh improvements and performance boosts to make managing your expenses even better. Would you like to update now?',
      keyMaintenanceTitle: 'We’ll Be Right Back!',
      keyMaintenanceMessage:
          'We’re currently performing quick scheduled maintenance to serve you better. Thank you for your patience, and please check back shortly!',
      keyUpdateUrlAndroid:
          'https://play.google.com/store/apps/details?id=com.expendly.app',
      keyUpdateUrlIos: 'https://apps.apple.com/app/expendly/id000000000',
    });

    // 2. Fetch and Activate latest Remote Config values
    await fetchAndActivate(notify: false);

    // 3. Real-time update listener for server-side config changes
    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      AppLogger.i(
          'RemoteConfig real-time config updated: ${event.updatedKeys}');
      _notifyListeners();
    });

    _notifyListeners();
  }

  /// Explicitly fetch and activate fresh Remote Config values from server.
  Future<bool> fetchAndActivate({bool notify = true}) async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      AppLogger.i(
          'RemoteConfig fetchAndActivate completed (activated: $activated, minVer: $minRequiredVersion, latestVer: $latestVersion)');
      if (notify) {
        _notifyListeners();
      }
      return activated;
    } catch (e, stackTrace) {
      AppLogger.w('RemoteConfig fetch error: $e', e, stackTrace);
      return false;
    }
  }

  void _notifyListeners() {
    _maintenanceStreamController.add(isMaintenanceMode);
    _adsEnabledStreamController.add(isAdsEnabled);
    checkUpdateStatus(fetchRemote: false).then((status) {
      _updateStatusStreamController.add(status);
    });
  }

  // --- Getters ---
  bool get isMaintenanceMode => _remoteConfig.getBool(keyIsMaintenanceMode);
  bool get isAdsEnabled => _remoteConfig.getBool(keyIsAdsEnabled);

  String get minRequiredVersion =>
      _remoteConfig.getString(keyMinRequiredVersion);
  String get latestVersion => _remoteConfig.getString(keyLatestVersion);

  String get forceUpdateTitle => _remoteConfig.getString(keyForceUpdateTitle);
  String get forceUpdateMessage =>
      _remoteConfig.getString(keyForceUpdateMessage);

  String get optionalUpdateTitle =>
      _remoteConfig.getString(keyOptionalUpdateTitle);
  String get optionalUpdateMessage =>
      _remoteConfig.getString(keyOptionalUpdateMessage);

  String get maintenanceTitle => _remoteConfig.getString(keyMaintenanceTitle);
  String get maintenanceMessage =>
      _remoteConfig.getString(keyMaintenanceMessage);

  String get updateUrlAndroid => _remoteConfig.getString(keyUpdateUrlAndroid);
  String get updateUrlIos => _remoteConfig.getString(keyUpdateUrlIos);

  /// Checks installed app version against Remote Config thresholds
  Future<AppUpdateStatus> checkUpdateStatus({bool fetchRemote = false}) async {
    try {
      if (fetchRemote) {
        await _remoteConfig.fetchAndActivate();
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final minVer = minRequiredVersion;
      final latestVer = latestVersion;

      AppLogger.i(
          'RemoteConfig checkUpdateStatus - Installed: $currentVersion, MinRequired: $minVer, Latest: $latestVer');

      if (_isVersionLower(currentVersion, minVer)) {
        AppLogger.i('RemoteConfig -> Triggering Force Update popup/screen');
        return AppUpdateStatus.forceUpdate;
      }

      if (_isVersionLower(currentVersion, latestVer)) {
        AppLogger.i('RemoteConfig -> Triggering Optional Update popup/screen');
        return AppUpdateStatus.optionalUpdate;
      }

      return AppUpdateStatus.none;
    } catch (e, stackTrace) {
      AppLogger.e('Error checking app update status', e, stackTrace);
      return AppUpdateStatus.none;
    }
  }

  /// Utility to compare semantic version strings (e.g., "1.0.0" vs "1.1.0")
  bool _isVersionLower(String versionA, String versionB) {
    try {
      final cleanA = versionA
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'^v'), '')
          .split('+')
          .first;
      final cleanB = versionB
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'^v'), '')
          .split('+')
          .first;

      final partsA = cleanA
          .split('.')
          .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
          .toList();
      final partsB = cleanB
          .split('.')
          .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
          .toList();

      for (int i = 0; i < 3; i++) {
        final valA = i < partsA.length ? partsA[i] : 0;
        final valB = i < partsB.length ? partsB[i] : 0;

        if (valA < valB) return true;
        if (valA > valB) return false;
      }
    } catch (e) {
      AppLogger.w('Version parsing error ($versionA vs $versionB): $e');
      return false;
    }
    return false;
  }

  void dispose() {
    _maintenanceStreamController.close();
    _updateStatusStreamController.close();
    _adsEnabledStreamController.close();
  }
}
