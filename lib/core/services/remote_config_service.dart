import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
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

  /// Initializes Remote Config defaults, fetch strategy, and listeners.
  Future<void> initialize() async {
    final isDevOrQa = AppConfig.instance.isDev || AppConfig.instance.isQa;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            isDevOrQa ? Duration.zero : const Duration(hours: 1),
      ),
    );

    // 1. Set In-App Defaults
    await _remoteConfig.setDefaults(const {
      keyMinRequiredVersion: '1.0.0',
      keyLatestVersion: '1.0.0',
      keyIsMaintenanceMode: false,
      keyForceUpdateTitle: 'Update Required',
      keyForceUpdateMessage:
          'A mandatory update is required to continue using Expendly.',
      keyOptionalUpdateTitle: 'Update Available',
      keyOptionalUpdateMessage:
          'A new update is available with performance improvements and feature updates.',
      keyMaintenanceTitle: 'Under Scheduled Maintenance',
      keyMaintenanceMessage:
          'Expendly is currently undergoing maintenance to serve you better. Please try again shortly.',
      keyUpdateUrlAndroid:
          'https://play.google.com/store/apps/details?id=com.expendly.app',
      keyUpdateUrlIos: 'https://apps.apple.com/app/expendly/id000000000',
    });

    // 2. Fetch and Activate latest Remote Config values
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      AppLogger.i('RemoteConfig fetched and activated (updated: $activated)');
    } catch (e, stackTrace) {
      AppLogger.w('RemoteConfig fetch error: $e', e, stackTrace);
    }

    // 3. Real-time update listener for server-side config changes
    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      AppLogger.i(
          'RemoteConfig real-time config updated: ${event.updatedKeys}');
      _notifyListeners();
    });

    _notifyListeners();
  }

  void _notifyListeners() {
    _maintenanceStreamController.add(isMaintenanceMode);
    checkUpdateStatus().then((status) {
      _updateStatusStreamController.add(status);
    });
  }

  // --- Getters ---
  bool get isMaintenanceMode => _remoteConfig.getBool(keyIsMaintenanceMode);

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
  Future<AppUpdateStatus> checkUpdateStatus() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isVersionLower(currentVersion, minRequiredVersion)) {
        return AppUpdateStatus.forceUpdate;
      }

      if (_isVersionLower(currentVersion, latestVersion)) {
        return AppUpdateStatus.optionalUpdate;
      }

      return AppUpdateStatus.none;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking app update status: $e');
      }
      return AppUpdateStatus.none;
    }
  }

  /// Utility to compare semantic version strings (e.g., "1.0.0" vs "1.1.0")
  bool _isVersionLower(String versionA, String versionB) {
    try {
      final partsA = versionA
          .split('.')
          .map((e) => int.parse(e.split('+').first))
          .toList();
      final partsB = versionB
          .split('.')
          .map((e) => int.parse(e.split('+').first))
          .toList();

      for (int i = 0; i < 3; i++) {
        final valA = i < partsA.length ? partsA[i] : 0;
        final valB = i < partsB.length ? partsB[i] : 0;

        if (valA < valB) return true;
        if (valA > valB) return false;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  void dispose() {
    _maintenanceStreamController.close();
    _updateStatusStreamController.close();
  }
}
