import 'package:flutter/foundation.dart';

enum AppFlavor {
  dev,
  qa,
  prod,
}

/// Offline-first environment configuration model based on active application flavor.
class AppConfig {
  /// Single source of truth for the application version across the entire app.
  static const String appVersion = '1.2.0';
  static const String buildNumber = '5';
  static const String fullVersion = '$appVersion+$buildNumber';
  static const String formattedVersion = 'v$appVersion';
  static const String versionDisplay = 'VER $appVersion';
  static const String aboutVersionDisplay = 'Version $appVersion';

  final AppFlavor flavor;
  final String appName;
  final bool enableLogging;
  final bool showFlavorBanner;

  const AppConfig({
    required this.flavor,
    required this.appName,
    this.enableLogging = true,
    this.showFlavorBanner = true,
  });

  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) {
      return const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly',
        enableLogging: kDebugMode,
        showFlavorBanner: false,
      );
    }
    return _instance!;
  }

  static void initialize(AppConfig config) {
    _instance = config;
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isQa => flavor == AppFlavor.qa;
  bool get isProd => flavor == AppFlavor.prod;
}
