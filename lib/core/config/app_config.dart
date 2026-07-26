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
    assert(
      _instance != null,
      'AppConfig must be initialized in main_[flavor].dart before accessing instance.',
    );
    return _instance!;
  }

  static void initialize(AppConfig config) {
    _instance = config;
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isQa => flavor == AppFlavor.qa;
  bool get isProd => flavor == AppFlavor.prod;
}
