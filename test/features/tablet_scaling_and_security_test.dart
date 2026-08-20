import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/biometric_auth_service.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/theme/app_typography.dart';
import 'package:expendly/core/widgets/adaptive_navigation_rail.dart';
import 'package:expendly/core/widgets/custom_keypad.dart';
import 'package:expendly/features/dashboard/presentation/widgets/empty_dashboard_view.dart';
import 'package:expendly/features/security/presentation/pages/security_verification_page.dart';
import 'package:expendly/features/settings/presentation/widgets/settings_category_sidebar.dart';
import 'package:expendly/features/transactions/presentation/widgets/transaction_master_list.dart';
import 'package:expendly/l10n/app_localizations.dart';

Widget _wrapTestApp(
  Widget child, {
  Size size = const Size(800, 1280),
}) {
  final isTablet = size.width >= 600;
  final isLandscape = size.width > size.height;

  final designSize = isTablet
      ? (isLandscape ? const Size(1024, 768) : const Size(768, 1024))
      : const Size(375, 812);

  return ScreenUtilInit(
    designSize: designSize,
    minTextAdapt: true,
    splitScreenMode: true,
    fontSizeResolver: (num fontSize, ScreenUtil instance) {
      if (isTablet) {
        return fontSize.toDouble();
      }
      return fontSize * instance.scaleText;
    },
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    if (!getIt.isRegistered<BiometricAuthService>()) {
      getIt.registerLazySingleton<BiometricAuthService>(
        () => BiometricAuthService(),
      );
    }
  });

  group('Tablet Font Scaling & Typography Tests', () {
    test('AppTypography returns unblown fixed logical pixel sizes', () {
      expect(AppTypography.headlineLarge.fontSize, 32.0);
      expect(AppTypography.headlineMedium.fontSize, 24.0);
      expect(AppTypography.headlineSmall.fontSize, 20.0);
      expect(AppTypography.titleLarge.fontSize, 22.0);
      expect(AppTypography.titleMedium.fontSize, 18.0);
      expect(AppTypography.titleSmall.fontSize, 14.0);
      expect(AppTypography.bodyLarge.fontSize, 16.0);
      expect(AppTypography.bodyMedium.fontSize, 14.0);
      expect(AppTypography.bodySmall.fontSize, 12.0);
      expect(AppTypography.labelLarge.fontSize, 14.0);
      expect(AppTypography.labelMedium.fontSize, 12.0);
      expect(AppTypography.labelSmall.fontSize, 10.0);
      expect(AppTypography.amountDisplay.fontSize, 24.0);
      expect(AppTypography.amountLarge.fontSize, 36.0);
    });

    testWidgets('AdaptiveNavigationRail adapts width on tablet portrait vs landscape',
        (tester) async {
      // 1. Tablet Portrait (800 x 1280) -> compact rail (72.0)
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapTestApp(
          AdaptiveNavigationRail(
            selectedIndex: 0,
            isExpanded: false,
            items: const [
              NavRailItem(
                label: 'Overview',
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                index: 0,
              ),
            ],
            onDestinationSelected: (_) {},
            onNewEntryPressed: () {},
          ),
          size: const Size(800, 1280),
        ),
      );
      await tester.pumpAndSettle();

      final railFinder = find.byType(AdaptiveNavigationRail);
      expect(railFinder, findsOneWidget);
      final RenderBox boxPortrait = tester.renderObject(railFinder);
      expect(boxPortrait.size.width, 72.0);

      // 2. Tablet Landscape (1280 x 800) -> expanded rail (200.0)
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpWidget(
        _wrapTestApp(
          AdaptiveNavigationRail(
            selectedIndex: 0,
            isExpanded: true,
            items: const [
              NavRailItem(
                label: 'Overview',
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                index: 0,
              ),
            ],
            onDestinationSelected: (_) {},
            onNewEntryPressed: () {},
          ),
          size: const Size(1280, 800),
        ),
      );
      await tester.pumpAndSettle();

      final RenderBox boxLandscape = tester.renderObject(railFinder);
      expect(boxLandscape.size.width, 200.0);
      expect(find.text('Expendly'), findsOneWidget);
    });

    testWidgets('SecurityVerificationPage renders cleanly in tablet portrait (800x1280)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapTestApp(
          const SecurityVerificationPage(),
          size: const Size(800, 1280),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomKeypad), findsOneWidget);
      expect(find.byType(SecurityVerificationPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SecurityVerificationPage renders split 2-column layout in tablet landscape (1280x800)',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapTestApp(
          const SecurityVerificationPage(),
          size: const Size(1280, 800),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomKeypad), findsOneWidget);
      expect(find.byType(SecurityVerificationPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CustomKeypad keypad buttons emit correct values', (tester) async {
      String pressedKey = '';
      bool deleted = false;

      await tester.pumpWidget(
        _wrapTestApp(
          CustomKeypad(
            showDecimal: true,
            onKeyPress: (val) => pressedKey = val,
            onDeletePress: () => deleted = true,
          ),
          size: const Size(800, 1280),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('5'));
      expect(pressedKey, '5');

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      expect(deleted, isTrue);
    });

    testWidgets('SettingsCategorySidebar and EmptyDashboardView render without overflow on tablet portrait',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1. Sidebar
      await tester.pumpWidget(
        _wrapTestApp(
          SizedBox(
            width: 260,
            child: SettingsCategorySidebar(
              selectedCategoryIndex: 0,
              onCategorySelected: (_) {},
            ),
          ),
          size: const Size(800, 1280),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SettingsCategorySidebar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Empty Dashboard View
      await tester.pumpWidget(
        _wrapTestApp(
          EmptyDashboardView(onAddTransaction: () {}),
          size: const Size(800, 1280),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Private & Secure'), findsOneWidget);
      expect(find.text('Offline Ready'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. Transaction Master List
      await tester.pumpWidget(
        _wrapTestApp(
          SizedBox(
            width: 320,
            child: TransactionMasterList(
              transactions: const [],
              onTransactionSelected: (_) {},
              selectedMonthNotifier: ValueNotifier<DateTime>(DateTime.now()),
              viewModeNotifier: ValueNotifier<String>('Monthly'),
            ),
          ),
          size: const Size(800, 1280),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
