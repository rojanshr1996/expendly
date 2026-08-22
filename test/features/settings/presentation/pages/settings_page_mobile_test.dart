import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/biometric_auth_service.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/remote_config_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/widgets/liquid_glass_app_bar.dart';
import 'package:expendly/features/profile/domain/entities/user_profile.dart';
import 'package:expendly/features/profile/domain/repositories/profile_repository.dart';
import 'package:expendly/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:expendly/features/settings/presentation/pages/settings_page.dart';
import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async => profile;
}

class _FakeBiometricAuthService implements BiometricAuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<bool> isBiometricAvailable() async => false;
}

class _FakeRemoteConfigService implements RemoteConfigService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  bool get isAdsEnabled => false;

  @override
  Stream<bool> get onAdsEnabledChanged => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late SecureStorageService secureStorageService;
  late PreferenceService preferenceService;

  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );

    secureStorageService = SecureStorageService();
    preferenceService = PreferenceService(secureStorageService);

    if (!getIt.isRegistered<SecureStorageService>()) {
      getIt.registerLazySingleton<SecureStorageService>(() => secureStorageService);
    }
    if (!getIt.isRegistered<PreferenceService>()) {
      getIt.registerLazySingleton<PreferenceService>(() => preferenceService);
    }
    if (!getIt.isRegistered<ProfileRepository>()) {
      getIt.registerLazySingleton<ProfileRepository>(() => _FakeProfileRepository());
    }
    if (!getIt.isRegistered<ProfileCubit>()) {
      getIt.registerLazySingleton<ProfileCubit>(() => ProfileCubit(getIt<ProfileRepository>()));
    }
    if (!getIt.isRegistered<BiometricAuthService>()) {
      getIt.registerLazySingleton<BiometricAuthService>(() => _FakeBiometricAuthService());
    }
    if (!getIt.isRegistered<RemoteConfigService>()) {
      getIt.registerLazySingleton<RemoteConfigService>(() => _FakeRemoteConfigService());
    }
  });

  tearDownAll(() async {
    await getIt.reset();
  });

  Widget buildTestApp() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => const MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: SettingsPage(),
      ),
    );
  }

  testWidgets('SettingsPage renders all sections when PIN is not set', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassAppBar), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('SECURITY'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('DATA MANAGEMENT'), findsOneWidget);
    expect(find.text('SUPPORT & LEGAL'), findsOneWidget);
  });

  testWidgets('SettingsPage renders all sections AND logout button when PIN is configured', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await preferenceService.setSecurityPin('1234');

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassAppBar), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('SECURITY'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('DATA MANAGEMENT'), findsOneWidget);
    expect(find.text('SUPPORT & LEGAL'), findsOneWidget);

    // Verify Log Out button is rendered
    expect(find.text('Log Out'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

    await preferenceService.setSecurityPin(null);
  });
}
