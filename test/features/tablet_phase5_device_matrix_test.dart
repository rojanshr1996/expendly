import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/responsive/breakpoints.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/adaptive_navigation_rail.dart';
import 'package:expendly/features/dashboard/domain/entities/financial_summary.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_bento_grid.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_categories_donut.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_recent_activity.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_tablet_header.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_tablet_summary_row.dart';
import 'package:expendly/features/profile/domain/entities/user_profile.dart';
import 'package:expendly/features/profile/domain/repositories/profile_repository.dart';
import 'package:expendly/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:expendly/l10n/app_localizations.dart';

class _FakeProfileRepo implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async => profile;
}

class DeviceProfile {
  final String name;
  final Size logicalSize;
  final DeviceType expectedTier;
  final bool isLandscape;

  const DeviceProfile({
    required this.name,
    required this.logicalSize,
    required this.expectedTier,
    this.isLandscape = false,
  });
}

Widget _wrapTestApp(
  Widget child, {
  required Size size,
  Brightness brightness = Brightness.light,
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
      if (isTablet) return fontSize.toDouble();
      return fontSize * instance.scaleText;
    },
    builder: (context, _) => MaterialApp(
      theme: brightness == Brightness.light
          ? AppTheme.lightTheme
          : AppTheme.darkTheme,
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

  const deviceMatrix = [
    // Compact (Phones)
    DeviceProfile(
      name: 'iPhone 15',
      logicalSize: Size(393, 852),
      expectedTier: DeviceType.compact,
    ),
    DeviceProfile(
      name: 'iPhone 15 Pro Max',
      logicalSize: Size(430, 932),
      expectedTier: DeviceType.compact,
    ),

    // Medium (Small tablets / Foldables)
    DeviceProfile(
      name: 'iPad Mini',
      logicalSize: Size(744, 1133),
      expectedTier: DeviceType.medium,
    ),
    DeviceProfile(
      name: 'iPad 10th Gen Portrait',
      logicalSize: Size(820, 1180),
      expectedTier: DeviceType.medium,
    ),
    DeviceProfile(
      name: 'iPad Air / Pro 11" Portrait',
      logicalSize: Size(834, 1194),
      expectedTier: DeviceType.medium,
    ),
    DeviceProfile(
      name: 'Samsung Galaxy Tab S9 Portrait',
      logicalSize: Size(800, 1280),
      expectedTier: DeviceType.medium,
    ),

    // Expanded (Standard / Large Tablets)
    DeviceProfile(
      name: 'Google Pixel Tablet Portrait',
      logicalSize: Size(840, 1344),
      expectedTier: DeviceType.expanded,
    ),
    DeviceProfile(
      name: 'Google Pixel Tablet Landscape',
      logicalSize: Size(1344, 840),
      expectedTier: DeviceType.expanded,
      isLandscape: true,
    ),
    DeviceProfile(
      name: 'Samsung Galaxy Tab S9 Landscape',
      logicalSize: Size(1280, 800),
      expectedTier: DeviceType.expanded,
      isLandscape: true,
    ),
    DeviceProfile(
      name: 'iPad 10th Gen Landscape',
      logicalSize: Size(1180, 820),
      expectedTier: DeviceType.expanded,
      isLandscape: true,
    ),
    DeviceProfile(
      name: 'iPad Pro 12.9" Portrait',
      logicalSize: Size(1024, 1366),
      expectedTier: DeviceType.expanded,
    ),
    DeviceProfile(
      name: 'iPad Pro 12.9" Landscape',
      logicalSize: Size(1366, 1024),
      expectedTier: DeviceType.expanded,
      isLandscape: true,
    ),
  ];

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
    if (!getIt.isRegistered<ProfileRepository>()) {
      getIt.registerLazySingleton<ProfileRepository>(
        () => _FakeProfileRepo(),
      );
    }
    if (!getIt.isRegistered<ProfileCubit>()) {
      getIt.registerLazySingleton<ProfileCubit>(
        () => ProfileCubit(getIt<ProfileRepository>()),
      );
    }
  });

  tearDownAll(() async {
    await getIt.reset();
  });

  group('Phase 5.1 - 5.4: Complete Device Matrix Breakpoint & Layout Tests', () {
    for (final device in deviceMatrix) {
      testWidgets('Verify breakpoint classification for ${device.name}',
          (tester) async {
        tester.view.physicalSize = device.logicalSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        DeviceType? measuredTier;
        bool? isTablet;
        bool? isExpanded;

        await tester.pumpWidget(
          _wrapTestApp(
            Builder(
              builder: (ctx) {
                measuredTier = Breakpoints.of(ctx);
                isTablet = Breakpoints.isTablet(ctx);
                isExpanded = Breakpoints.isExpanded(ctx);
                return const SizedBox.shrink();
              },
            ),
            size: device.logicalSize,
          ),
        );
        await tester.pumpAndSettle();

        expect(measuredTier, equals(device.expectedTier),
            reason: '${device.name} tier mismatch');
        expect(isTablet, equals(device.expectedTier != DeviceType.compact),
            reason: '${device.name} isTablet mismatch');
        expect(isExpanded, equals(device.expectedTier == DeviceType.expanded),
            reason: '${device.name} isExpanded mismatch');
      });

      testWidgets(
          'AdaptiveNavigationRail adapts correctly to width for ${device.name}',
          (tester) async {
        tester.view.physicalSize = device.logicalSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final isWide = device.logicalSize.width >= 900;

        int selectedIndex = 0;

        await tester.pumpWidget(
          _wrapTestApp(
            AdaptiveNavigationRail(
              selectedIndex: selectedIndex,
              isExpanded: isWide,
              items: const [
                NavRailItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Overview',
                  index: 0,
                ),
                NavRailItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Activity',
                  index: 1,
                ),
                NavRailItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  label: 'Budgets',
                  index: 2,
                ),
              ],
              onDestinationSelected: (i) => selectedIndex = i,
              onNewEntryPressed: () {},
            ),
            size: device.logicalSize,
          ),
        );
        await tester.pumpAndSettle();

        final railFinder = find.byType(AdaptiveNavigationRail);
        expect(railFinder, findsOneWidget);

        final RenderBox railBox = tester.renderObject(railFinder);
        final expectedWidth = isWide ? 200.0 : 72.0;
        expect(railBox.size.width, equals(expectedWidth));

        if (isWide) {
          expect(find.text('Expendly'), findsOneWidget);
          expect(find.text('Overview'), findsOneWidget);
        }

        // Test destination tap
        await tester.tap(find.byIcon(Icons.receipt_long_outlined));
        await tester.pumpAndSettle();
        expect(selectedIndex, equals(1));
      });

      testWidgets('Dashboard components render without overflow on ${device.name}',
          (tester) async {
        tester.view.physicalSize = device.logicalSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final now = DateTime.now();
        final summary = FinancialSummary(
          totalBalance: 45231.89,
          totalIncome: 8450.00,
          totalExpense: 3120.45,
          currencySymbol: '\$',
          periodStart: DateTime(now.year, now.month, 1),
          periodEnd: now,
          monthlyBudgetLimit: 5000.00,
          recentTransactions: [
            DashboardTransactionItem(
              id: 1,
              title: 'Whole Foods Market',
              categoryName: 'Groceries',
              note: 'Weekly grocery run',
              iconName: 'shopping_cart',
              colorHex: '#4CAF50',
              amount: 142.50,
              date: now,
              isIncome: false,
            ),
            DashboardTransactionItem(
              id: 2,
              title: 'Stripe Inc.',
              categoryName: 'Income',
              note: 'Salary payout',
              iconName: 'attach_money',
              colorHex: '#2196F3',
              amount: 2450.00,
              date: now.subtract(const Duration(days: 1)),
              isIncome: true,
            ),
          ],
        );

        final privacyNotifier = ValueNotifier<bool>(false);

        if (device.expectedTier == DeviceType.compact) {
          // Compact: Header + Bento Grid + Recent Activity
          await tester.pumpWidget(
            _wrapTestApp(
              SingleChildScrollView(
                child: Column(
                  children: [
                    DashboardHeader(
                      isPrivacyModeNotifier: privacyNotifier,
                    ),
                    DashboardBentoGrid(
                      summary: summary,
                      isPrivacyModeNotifier: privacyNotifier,
                    ),
                    DashboardRecentActivity(
                      transactions: summary.recentTransactions,
                      currencySymbol: summary.currencySymbol,
                      isPrivacyModeNotifier: privacyNotifier,
                    ),
                  ],
                ),
              ),
              size: device.logicalSize,
            ),
          );
        } else {
          // Tablet: Tablet Header + 3-card Summary Row + Donut + Dense Recent Activity
          await tester.pumpWidget(
            _wrapTestApp(
              SingleChildScrollView(
                child: Column(
                  children: [
                    DashboardTabletHeader(
                      isPrivacyModeNotifier: privacyNotifier,
                      onNewEntryPressed: () {},
                      onRefreshPressed: () {},
                    ),
                    DashboardTabletSummaryRow(
                      summary: summary,
                      isPrivacyModeNotifier: privacyNotifier,
                    ),
                    DashboardCategoriesDonut(
                      summary: summary,
                      isPrivacyModeNotifier: privacyNotifier,
                    ),
                    DashboardRecentActivity(
                      transactions: summary.recentTransactions,
                      currencySymbol: summary.currencySymbol,
                      isPrivacyModeNotifier: privacyNotifier,
                    ),
                  ],
                ),
              ),
              size: device.logicalSize,
            ),
          );
        }

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'Dashboard overflow on ${device.name}');
      });
    }
  });
}
