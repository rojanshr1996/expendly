import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/biometric_auth_service.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/compact_amount_text.dart';
import 'package:expendly/core/widgets/custom_keypad.dart';
import 'package:expendly/features/analytics/domain/entities/analytics_report.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_chart_panel.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_insights_sidebar.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_type_sidebar.dart';
import 'package:expendly/features/budgets/domain/entities/budget_item.dart';
import 'package:expendly/features/budgets/presentation/widgets/budget_card_grid.dart';
import 'package:expendly/features/budgets/presentation/widgets/budget_health_sidebar.dart';
import 'package:expendly/features/dashboard/domain/entities/financial_summary.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_cash_flow_chart.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_categories_donut.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_recent_activity.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_tablet_header.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_tablet_summary_row.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'package:expendly/features/groups/presentation/widgets/group_detail_panel.dart';
import 'package:expendly/features/groups/presentation/widgets/groups_master_list.dart';
import 'package:expendly/features/profile/domain/entities/user_profile.dart';
import 'package:expendly/features/profile/domain/repositories/profile_repository.dart';
import 'package:expendly/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:expendly/features/security/presentation/pages/security_verification_page.dart';
import 'package:expendly/features/settings/presentation/widgets/settings_category_sidebar.dart';
import 'package:expendly/features/transactions/domain/entities/transaction_item.dart';
import 'package:expendly/features/transactions/presentation/widgets/transaction_detail_panel.dart';
import 'package:expendly/features/transactions/presentation/widgets/transaction_master_list.dart';
import 'package:expendly/l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expendly/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:expendly/features/dashboard/presentation/cubit/dashboard_state.dart';

class _FakeProfileRepo implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async => profile;
}

class FakeDashboardCubit extends Cubit<DashboardState> implements DashboardCubit {
  FakeDashboardCubit(super.initialState);

  @override
  Future<void> loadDashboardData({bool isSilent = false}) async {}
}

Widget _wrapTestApp(
  Widget child, {
  Size size = const Size(1024, 768),
}) {
  return ScreenUtilInit(
    designSize: size,
    minTextAdapt: true,
    splitScreenMode: true,
    fontSizeResolver: (num fontSize, ScreenUtil instance) => fontSize.toDouble(),
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

  group('Phase 5 Screen-by-Screen Tablet Verification Tests', () {
    testWidgets('5.1 Dashboard Overview: Header, Summary Row, Donut & Activity render correctly',
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
        recentTransactions: [
          DashboardTransactionItem(
            id: 1,
            title: 'Whole Foods Market',
            categoryName: 'Groceries',
            note: 'Weekly organic groceries',
            iconName: 'shopping_cart',
            colorHex: '#4CAF50',
            amount: 142.50,
            date: now,
            isIncome: false,
          ),
        ],
      );

      final privacyNotifier = ValueNotifier<bool>(false);
      bool newEntryTriggered = false;
      bool refreshTriggered = false;

      await tester.pumpWidget(
        _wrapTestApp(
          BlocProvider<DashboardCubit>.value(
            value: FakeDashboardCubit(DashboardLoaded(summary)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardTabletHeader(
                    isPrivacyModeNotifier: privacyNotifier,
                    onNewEntryPressed: () => newEntryTriggered = true,
                    onRefreshPressed: () => refreshTriggered = true,
                  ),
                  DashboardTabletSummaryRow(
                    summary: summary,
                    isPrivacyModeNotifier: privacyNotifier,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        flex: 5,
                        child: DashboardCashFlowChart(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: DashboardCategoriesDonut(
                          summary: summary,
                          isPrivacyModeNotifier: privacyNotifier,
                        ),
                      ),
                    ],
                  ),
                  DashboardRecentActivity(
                    transactions: summary.recentTransactions,
                    currencySymbol: summary.currencySymbol,
                    isPrivacyModeNotifier: privacyNotifier,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('Financial Overview'), findsOneWidget);
      expect(find.text('Quick add'), findsOneWidget);

      await tester.tap(find.text('Quick add'));
      expect(newEntryTriggered, isTrue);

      await tester.tap(find.byIcon(Icons.refresh));
      expect(refreshTriggered, isTrue);

      // Summary Row verification
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      expect(find.text('MONTHLY INCOME'), findsOneWidget);
      expect(find.text('MONTHLY EXPENSES'), findsOneWidget);
      expect(find.byType(CompactAmountText), findsWidgets);

      // Donut Chart & Cash Flow verification
      expect(find.text('Top Categories'), findsOneWidget);
      expect(find.byType(DashboardCashFlowChart), findsOneWidget);

      // Recent Activity verification
      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('Weekly organic groceries'), findsOneWidget);
      expect(find.byType(DashboardRecentActivity), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '5.2 Transactions: Master-Detail interactive selection updates detail pane without navigation push',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final tx1 = TransactionItem(
        id: 1,
        amount: 142.50,
        currencyCode: '\$',
        categoryId: 1,
        type: TransactionType.expense,
        categoryName: 'Groceries',
        categoryIcon: 'shopping_cart',
        categoryColorHex: '#4CAF50',
        timestamp: DateTime(2026, 8, 20, 14, 30),
        note: 'Whole Foods organic run',
      );

      final tx2 = TransactionItem(
        id: 2,
        amount: 2450.00,
        currencyCode: '\$',
        categoryId: 2,
        type: TransactionType.income,
        categoryName: 'Salary',
        categoryIcon: 'attach_money',
        categoryColorHex: '#2196F3',
        timestamp: DateTime(2026, 8, 21, 9, 0),
        note: 'Bi-weekly payroll',
      );

      TransactionItem selectedTx = tx1;

      await tester.pumpWidget(
        _wrapTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: TransactionMasterList(
                      transactions: [tx1, tx2],
                      selectedTransaction: selectedTx,
                      onTransactionSelected: (tx) {
                        setState(() {
                          selectedTx = tx;
                        });
                      },
                      selectedMonthNotifier: ValueNotifier(DateTime.now()),
                      viewModeNotifier: ValueNotifier('all'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: TransactionDetailPanel(
                      transaction: selectedTx,
                      onEdit: () {},
                      onDelete: () {},
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially tx1 details are showing
      expect(find.text('Whole Foods organic run'), findsWidgets);
      expect(find.text('-\$142.50'), findsWidgets);

      // Tap on tx2 in the master list
      await tester.tap(find.text('Salary'));
      await tester.pumpAndSettle();

      // Detail pane reactively switches to tx2
      expect(find.text('Bi-weekly payroll'), findsWidgets);
      expect(find.text('+\$2,450.00'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('5.3 Budgets: 2-Column Grid and persistent Health Sidebar render metrics',
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

      bool addBudgetTriggered = false;

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
                    onCreateBudget: () => addBudgetTriggered = true,
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
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Dining Out'), findsOneWidget);
      expect(find.text('Active Budgets (2/4)'), findsOneWidget);
      expect(find.text('Total Budget Health'), findsOneWidget);
      expect(find.text('Spending Pace'), findsOneWidget);
      expect(find.text('Smart Insights'), findsOneWidget);

      await tester.tap(find.text('Set New Budget').first);
      expect(addBudgetTriggered, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('5.4 Analytics: 3-Panel Layout renders sidebar, charts, and export actions',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const report = AnalyticsReport(
        totalIncome: 8450.0,
        totalExpense: 3120.0,
        netSavings: 5330.0,
        savingsRatePercentage: 63.0,
        avgDailySpend: 104.0,
        budgetHealthPercentage: 88.0,
        budgetHealthStatus: 'Excellent',
        topCategoryName: 'Housing',
        topCategoryPercentage: 45.0,
        dailyFlows: [],
        categoryBreakdowns: [],
      );

      bool pdfExported = false;
      bool csvExported = false;
      String currentPeriod = 'This Month';

      await tester.pumpWidget(
        _wrapTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 220,
                    child: ReportTypeSidebar(
                      report: report,
                      selectedPeriod: currentPeriod,
                      onPeriodChanged: (p) {
                        setState(() {
                          currentPeriod = p;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 5,
                    child: ReportChartPanel(report: report),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 260,
                    child: ReportInsightsSidebar(
                      report: report,
                      onExportPdf: () => pdfExported = true,
                      onExportCsv: () => csvExported = true,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Time Period'), findsOneWidget);
      expect(find.text('Savings Rate'), findsWidgets);
      expect(find.text('63.0%'), findsWidgets);
      expect(find.text('Financial Health'), findsOneWidget);
      expect(find.text('Export PDF Report'), findsOneWidget);
      expect(find.text('Export CSV Sheet'), findsOneWidget);

      await tester.tap(find.text('Export PDF Report'));
      expect(pdfExported, isTrue);

      await tester.tap(find.text('Export CSV Sheet'));
      expect(csvExported, isTrue);

      expect(tester.takeException(), isNull);
    });

    testWidgets('5.5 Groups: Master List & Group Detail Panel render participants and totals',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final event = SharingEvent(
        id: 1,
        name: 'Lake Tahoe Trip',
        description: 'Cabin, ski passes, and shared dinners',
        startDate: DateTime(2026, 8, 10),
        category: 'trip',
        status: 'active',
        createdAt: DateTime(2026, 8, 10),
        participants: const [
          EventParticipant(
            id: 1,
            eventId: 1,
            name: 'Alex',
            isOwner: true,
            colorIndex: 0,
          ),
          EventParticipant(
            id: 2,
            eventId: 1,
            name: 'Sarah',
            isOwner: false,
            colorIndex: 1,
          ),
        ],
        totalSpent: 1850.0,
        userShare: 925.0,
      );

      bool viewDetailsTriggered = false;

      await tester.pumpWidget(
        _wrapTestApp(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 340,
                child: GroupsMasterList(
                  events: [event],
                  selectedEvent: event,
                  onEventSelected: (_) {},
                  onCreateEvent: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GroupDetailPanel(
                  event: event,
                  onViewDetails: () => viewDetailsTriggered = true,
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lake Tahoe Trip'), findsWidgets);
      expect(find.text('TOTAL SPENT'), findsOneWidget);
      expect(find.text('YOUR SHARE'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Sarah'), findsOneWidget);
      expect(find.text('OWNER'), findsOneWidget);

      await tester.tap(find.text('View Full Event & Expenses'));
      expect(viewDetailsTriggered, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('5.6 Settings: Category Sidebar navigates cleanly between categories',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int activeCategory = 0;

      await tester.pumpWidget(
        _wrapTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                children: [
                  SizedBox(
                    width: 260,
                    child: SettingsCategorySidebar(
                      selectedCategoryIndex: activeCategory,
                      onCategorySelected: (idx) {
                        setState(() {
                          activeCategory = idx;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Center(
                      child: Text('Active Category: $activeCategory'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Active Category: 0'), findsOneWidget);

      // Select Security (index 1)
      await tester.tap(find.byIcon(Icons.lock_rounded));
      await tester.pumpAndSettle();
      expect(activeCategory, equals(1));
      expect(find.text('Active Category: 1'), findsOneWidget);

      // Select Data & Backup (index 3)
      await tester.tap(find.byIcon(Icons.backup_rounded));
      await tester.pumpAndSettle();
      expect(activeCategory, equals(3));
      expect(find.text('Active Category: 3'), findsOneWidget);
    });

    testWidgets(
        '5.14 Security: SecurityVerificationPage renders split 2-column layout in landscape with CustomKeypad',
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

      expect(find.byType(SecurityVerificationPage), findsOneWidget);
      expect(find.byType(CustomKeypad), findsOneWidget);

      // Tap numeric keypad keys without full submit
      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
