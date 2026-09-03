import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/remote_config_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/animated_hero_illustration.dart';
import 'package:expendly/core/widgets/app_update_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapTestWidget(Widget child, {Size size = const Size(390, 844)}) {
  return ScreenUtilInit(
    designSize: size,
    builder: (context, _) => MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    ),
  );
}

class FakeRemoteConfigService extends Fake implements RemoteConfigService {
  @override
  bool isMaintenanceMode = false;

  @override
  String maintenanceTitle = 'We’ll Be Right Back!';

  @override
  String maintenanceMessage =
      'We’re currently performing quick scheduled maintenance to serve you better. Thank you for your patience, and please check back shortly!';

  @override
  String forceUpdateTitle = 'Time for an Update!';

  @override
  String forceUpdateMessage =
      'We’ve added important improvements and enhancements to keep your experience smooth and secure. Please update Expendly to the latest version to continue.';

  @override
  String optionalUpdateTitle = 'New Version Available!';

  @override
  String optionalUpdateMessage =
      'A new update is ready with fresh improvements and performance boosts to make managing your expenses even better. Would you like to update now?';

  @override
  String updateUrlIos = 'https://apps.apple.com';

  @override
  String updateUrlAndroid = 'https://play.google.com';

  @override
  bool isAdsEnabled = true;

  @override
  String latestVersion = '1.0.0';

  @override
  String minRequiredVersion = '1.0.0';

  @override
  Stream<bool> get onMaintenanceChanged => const Stream.empty();

  @override
  Stream<AppUpdateStatus> get onUpdateStatusChanged => const Stream.empty();

  @override
  Stream<bool> get onAdsEnabledChanged => const Stream.empty();

  AppUpdateStatus currentStatus = AppUpdateStatus.none;

  @override
  Future<AppUpdateStatus> checkUpdateStatus({bool fetchRemote = false}) async {
    return currentStatus;
  }

  @override
  Future<bool> fetchAndActivate({bool notify = true}) async {
    return true;
  }

  @override
  Future<void> initialize() async {}

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeRemoteConfigService fakeRemoteConfig;

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
    fakeRemoteConfig = FakeRemoteConfigService();
    if (getIt.isRegistered<RemoteConfigService>()) {
      getIt.unregister<RemoteConfigService>();
    }
    getIt.registerSingleton<RemoteConfigService>(fakeRemoteConfig);
  });

  testWidgets('AnimatedHeroIllustration renders properly and animates', (tester) async {
    await tester.pumpWidget(
      _wrapTestWidget(
        const Scaffold(
          body: Center(
            child: AnimatedHeroIllustration(
              size: 200,
              mainIcon: Icons.system_update_rounded,
              topBadgeIcon: Icons.auto_awesome_rounded,
              bottomBadgeIcon: Icons.download_rounded,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedHeroIllustration), findsOneWidget);
    expect(find.byIcon(Icons.system_update_rounded), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));
  });

  testWidgets('AppUpdateGuard renders Force Update screen with AnimatedHeroIllustration and AppButton', (tester) async {
    fakeRemoteConfig.currentStatus = AppUpdateStatus.forceUpdate;

    await tester.pumpWidget(
      _wrapTestWidget(
        const AppUpdateGuard(
          child: Text('App Content'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Time for an Update!'), findsOneWidget);
    expect(
        find.text(
            'We’ve added important improvements and enhancements to keep your experience smooth and secure. Please update Expendly to the latest version to continue.'),
        findsOneWidget);
    expect(find.byType(AnimatedHeroIllustration), findsOneWidget);
    expect(find.byIcon(Icons.system_update_rounded), findsOneWidget);
    expect(find.text('Update Now'), findsOneWidget);
  });

  testWidgets('AppUpdateGuard renders Optional Update dialog with AnimatedHeroIllustration and allows dismissing',
      (tester) async {
    fakeRemoteConfig.currentStatus = AppUpdateStatus.optionalUpdate;

    await tester.pumpWidget(
      _wrapTestWidget(
        const AppUpdateGuard(
          child: Text('App Content'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('New Version Available!'), findsOneWidget);
    expect(find.byType(AnimatedHeroIllustration), findsOneWidget);
    expect(find.byIcon(Icons.new_releases_rounded), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);

    // Tap Later to dismiss dialog
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.text('New Version Available!'), findsNothing);
    expect(find.text('App Content'), findsOneWidget);
  });

  testWidgets('AppUpdateGuard renders Maintenance screen with AnimatedHeroIllustration', (tester) async {
    fakeRemoteConfig.isMaintenanceMode = true;

    await tester.pumpWidget(
      _wrapTestWidget(
        const AppUpdateGuard(
          child: Text('App Content'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('We’ll Be Right Back!'), findsOneWidget);
    expect(
        find.text(
            'We’re currently performing quick scheduled maintenance to serve you better. Thank you for your patience, and please check back shortly!'),
        findsOneWidget);
    expect(find.byType(AnimatedHeroIllustration), findsOneWidget);
    expect(find.byIcon(Icons.build_circle_rounded), findsOneWidget);
  });
}
