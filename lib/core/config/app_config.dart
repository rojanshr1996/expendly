import 'package:flutter/foundation.dart';

enum AppFlavor {
  dev,
  qa,
  prod,
}

/// Offline-first environment configuration model based on active application flavor.
class AppConfig {
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
