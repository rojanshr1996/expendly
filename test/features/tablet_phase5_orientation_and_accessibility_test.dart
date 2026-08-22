import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/adaptive_navigation_rail.dart';
import 'package:expendly/core/widgets/compact_amount_text.dart';
import 'package:expendly/core/widgets/custom_keypad.dart';
import 'package:expendly/features/budgets/domain/entities/budget_item.dart';
import 'package:expendly/features/budgets/presentation/widgets/budget_card_grid.dart';
import 'package:expendly/features/budgets/presentation/widgets/budget_health_sidebar.dart';
import 'package:expendly/features/dashboard/domain/entities/financial_summary.dart';
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

Widget _wrapTestApp(
  Widget child, {
  Size size = const Size(1024, 768),
  double textScaleFactor = 1.0,
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
    fontSizeResolver: (num fontSize, ScreenUtil instance) => fontSize.toDouble(),
    builder: (context, _) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: MaterialApp(
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

  group('Phase 5.6: Tablet Orientation Switching & Dynamic Reflow Tests', () {
    testWidgets(
        'Dynamic viewport rotation preserves selection state and adapts rail width',
        (tester) async {
      // 1. Start in Tablet Portrait (800 x 1280)
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int selectedTab = 0;

      await tester.pumpWidget(
        _wrapTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              final isWide = MediaQuery.sizeOf(context).width >= 900;
              return Row(
                children: [
                  AdaptiveNavigationRail(
                    selectedIndex: selectedTab,
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
                    onDestinationSelected: (i) {
                      setState(() {
                        selectedTab = i;
                      });
                    },
                    onNewEntryPressed: () {},
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Current Tab: $selectedTab'),
                    ),
                  ),
                ],
              );
            },
          ),
          size: const Size(800, 1280),
        ),
      );
      await tester.pumpAndSettle();

      // Portrait: Rail width is collapsed 72.0
      RenderBox railBox =
          tester.renderObject(find.byType(AdaptiveNavigationRail));
      expect(railBox.size.width, equals(72.0));

      // Select Tab 2 (Budgets)
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      expect(selectedTab, equals(2));
      expect(find.text('Current Tab: 2'), findsOneWidget);

      // 2. Rotate to Tablet Landscape (1280 x 800)
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpAndSettle();

      // Landscape: Rail width is expanded 200.0, Tab 2 is still selected!
      railBox = tester.renderObject(find.byType(AdaptiveNavigationRail));
      expect(railBox.size.width, equals(200.0));
      expect(selectedTab, equals(2));
      expect(find.text('Current Tab: 2'), findsOneWidget);
      expect(find.text('Expendly'), findsOneWidget);

      // 3. Rotate back to Portrait (800 x 1280)
      tester.view.physicalSize = const Size(800, 1280);
      await tester.pumpAndSettle();

      railBox = tester.renderObject(find.byType(AdaptiveNavigationRail));
      expect(railBox.size.width, equals(72.0));
      expect(selectedTab, equals(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('Phase 5.7: Tablet Accessibility & Dynamic Type Scaling Tests', () {
    const textScaleFactors = [1.0, 1.5, 2.0];

    for (final scale in textScaleFactors) {
      testWidgets('Dashboard Summary Row renders without overflow at ${scale}x text scale',
          (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
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
          recentTransactions: const [],
        );

        final privacyNotifier = ValueNotifier<bool>(false);

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
                ],
              ),
            ),
            size: const Size(1024, 768),
            textScaleFactor: scale,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Financial Overview'), findsOneWidget);
        expect(find.text('TOTAL BALANCE'), findsOneWidget);
        expect(find.byType(CompactAmountText), findsWidgets);
        expect(tester.takeException(), isNull,
            reason: 'Overflow at ${scale}x scale in Dashboard Summary');
      });

      testWidgets('Budgets 2-Column Grid renders without overflow at ${scale}x text scale',
          (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final budgets = [
          const BudgetItem(
            id: 1,
            categoryName: 'Groceries',
            categoryIcon: 'shopping_cart',
            categoryColorHex: '#4CAF50',
            targetAmount: 500.0,
            spentAmount: 480.0,
          ),
          const BudgetItem(
            id: 2,
            categoryName: 'Dining Out',
            categoryIcon: 'restaurant',
            categoryColorHex: '#FF5722',
            targetAmount: 300.0,
            spentAmount: 120.50,
          ),
        ];

        await tester.pumpWidget(
          _wrapTestApp(
            SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: BudgetCardGrid(
                      budgets: budgets,
                      onCreateBudget: () {},
                      onDeleteBudget: (_) {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: BudgetHealthSidebar(
                      budgets: budgets,
                    ),
                  ),
                ],
              ),
            ),
            size: const Size(1024, 768),
            textScaleFactor: scale,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Groceries'), findsOneWidget);
        expect(find.text('Total Budget Health'), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'Overflow at ${scale}x scale in Budgets Grid');
      });

      testWidgets('CustomKeypad keypad buttons render cleanly at ${scale}x text scale',
          (tester) async {
        tester.view.physicalSize = const Size(800, 1280);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapTestApp(
            CustomKeypad(
              showDecimal: true,
              onKeyPress: (_) {},
              onDeletePress: () {},
            ),
            size: const Size(800, 1280),
            textScaleFactor: scale,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);
        expect(find.text('9'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'Overflow at ${scale}x scale in CustomKeypad');
      });
    }
  });
}
