import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/features/dashboard/domain/entities/financial_summary.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_tablet_header.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_tablet_summary_row.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_categories_donut.dart';
import 'package:expendly/features/transactions/domain/entities/transaction_item.dart';
import 'package:expendly/features/transactions/presentation/widgets/transaction_master_list.dart';
import 'package:expendly/features/transactions/presentation/widgets/transaction_detail_panel.dart';
import 'package:expendly/features/budgets/domain/entities/budget_item.dart';
import 'package:expendly/features/budgets/presentation/widgets/budget_card_grid.dart';
import 'package:expendly/features/budgets/presentation/widgets/budget_health_sidebar.dart';
import 'package:expendly/features/analytics/domain/entities/analytics_report.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_type_sidebar.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_insights_sidebar.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/presentation/widgets/groups_master_list.dart';
import 'package:expendly/features/groups/presentation/widgets/group_detail_panel.dart';
import 'package:expendly/l10n/app_localizations.dart';

Widget _wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(1024, 768),
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
  });

  tearDownAll(() async {
    await getIt.reset();
  });

  group('Phase 2 Tablet Widgets Tests', () {
    testWidgets('DashboardTabletHeader renders titles and handles taps',
        (tester) async {
      bool addPressed = false;
      bool refreshPressed = false;
      final privacyNotifier = ValueNotifier<bool>(false);

      await tester.pumpWidget(_wrapWithScreenUtil(
        DashboardTabletHeader(
          isPrivacyModeNotifier: privacyNotifier,
          onNewEntryPressed: () => addPressed = true,
          onRefreshPressed: () => refreshPressed = true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Financial Overview'), findsOneWidget);
      expect(find.text('New Entry'), findsOneWidget);

      await tester.tap(find.text('New Entry'));
      expect(addPressed, isTrue);

      await tester.tap(find.byIcon(Icons.refresh));
      expect(refreshPressed, isTrue);
    });

    testWidgets('DashboardTabletSummaryRow renders 3 financial metric cards',
        (tester) async {
      final now = DateTime.now();
      final summary = FinancialSummary(
        totalBalance: 12500.0,
        totalIncome: 4500.0,
        totalExpense: 1800.0,
        currencySymbol: '\$',
        periodStart: DateTime(now.year, now.month, 1),
        periodEnd: now,
        monthlyBudgetLimit: 3000.0,
        recentTransactions: const [],
      );
      final privacyNotifier = ValueNotifier<bool>(false);

      await tester.pumpWidget(_wrapWithScreenUtil(
        DashboardTabletSummaryRow(
          summary: summary,
          isPrivacyModeNotifier: privacyNotifier,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      expect(find.text('MONTHLY INCOME'), findsOneWidget);
      expect(find.text('MONTHLY EXPENSES'), findsOneWidget);
    });

    testWidgets('DashboardCategoriesDonut renders empty state and category titles',
        (tester) async {
      final now = DateTime.now();
      final summary = FinancialSummary(
        totalBalance: 5000.0,
        totalIncome: 2000.0,
        totalExpense: 0.0,
        currencySymbol: '\$',
        periodStart: DateTime(now.year, now.month, 1),
        periodEnd: now,
        monthlyBudgetLimit: 3000.0,
        recentTransactions: const [],
      );

      await tester.pumpWidget(_wrapWithScreenUtil(
        DashboardCategoriesDonut(summary: summary),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Top Categories'), findsOneWidget);
      expect(find.text('No Expenses'), findsOneWidget);
    });

    testWidgets('TransactionMasterList & TransactionDetailPanel render correctly',
        (tester) async {
      final item = TransactionItem(
        id: 1,
        amount: 45.0,
        currencyCode: 'USD',
        categoryId: 1,
        type: TransactionType.expense,
        categoryName: 'Groceries',
        categoryIcon: 'shopping_cart',
        categoryColorHex: '#4CAF50',
        timestamp: DateTime(2026, 8, 19, 10, 30),
        note: 'Supermarket visit',
      );

      TransactionItem? selected;

      await tester.pumpWidget(_wrapWithScreenUtil(
        SizedBox(
          width: 500,
          height: 600,
          child: TransactionMasterList(
            transactions: [item],
            selectedTransaction: item,
            onTransactionSelected: (tx) => selected = tx,
            selectedMonthNotifier: ValueNotifier(DateTime.now()),
            viewModeNotifier: ValueNotifier('daily'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Supermarket visit'), findsOneWidget);

      await tester.tap(find.text('Groceries'));
      expect(selected, isNotNull);

      // Detail Panel
      await tester.pumpWidget(_wrapWithScreenUtil(
        TransactionDetailPanel(
          transaction: item,
          onEdit: () {},
          onDelete: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsNWidgets(2)); // Header + detail tile
      expect(find.text('Supermarket visit'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('BudgetCardGrid & BudgetHealthSidebar render budget metrics',
        (tester) async {
      const budget = BudgetItem(
        id: 1,
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColorHex: '#FF5722',
        targetAmount: 500.0,
        spentAmount: 350.0,
      );

      await tester.pumpWidget(_wrapWithScreenUtil(
        BudgetCardGrid(
          budgets: const [budget],
          onCreateBudget: () {},
          onDeleteBudget: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Active Budgets (1/4)'), findsOneWidget);

      // Sidebar
      await tester.pumpWidget(_wrapWithScreenUtil(
        const BudgetHealthSidebar(
          budgets: [budget],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Total Budget Health'), findsOneWidget);
      expect(find.text('Spending Pace'), findsOneWidget);
      expect(find.text('Smart Insights'), findsOneWidget);
    });

    testWidgets('ReportTypeSidebar & ReportInsightsSidebar render analytical panels',
        (tester) async {
      const report = AnalyticsReport(
        totalIncome: 5000.0,
        totalExpense: 2000.0,
        netSavings: 3000.0,
        savingsRatePercentage: 60.0,
        avgDailySpend: 66.6,
        budgetHealthPercentage: 85.0,
        budgetHealthStatus: 'Healthy',
        topCategoryName: 'Rent',
        topCategoryPercentage: 45.0,
        categoryBreakdowns: [],
        dailyFlows: [],
      );

      await tester.pumpWidget(_wrapWithScreenUtil(
        ReportTypeSidebar(
          report: report,
          selectedPeriod: 'This Month',
          onPeriodChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Time Period'), findsOneWidget);
      expect(find.text('Savings Rate'), findsOneWidget);
      expect(find.text('60.0%'), findsOneWidget);

      // Insights Sidebar
      await tester.pumpWidget(_wrapWithScreenUtil(
        ReportInsightsSidebar(
          report: report,
          onExportPdf: () {},
          onExportCsv: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Financial Health'), findsOneWidget);
      expect(find.text('Top Spending'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Export PDF Report'), findsOneWidget);
    });

    testWidgets('GroupsMasterList & GroupDetailPanel render group events',
        (tester) async {
      final event = SharingEvent(
        id: 1,
        name: 'Weekend Roadtrip',
        description: 'Gas, snacks and cabin split',
        startDate: DateTime(2026, 8, 15),
        category: 'trip',
        status: 'active',
        createdAt: DateTime(2026, 8, 15),
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
            name: 'Sam',
            isOwner: false,
            colorIndex: 1,
          ),
        ],
        totalSpent: 320.0,
        userShare: 160.0,
      );

      await tester.pumpWidget(_wrapWithScreenUtil(
        SizedBox(
          width: 500,
          height: 600,
          child: GroupsMasterList(
            events: [event],
            selectedEvent: event,
            onEventSelected: (_) {},
            onCreateEvent: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Weekend Roadtrip'), findsOneWidget);
      expect(find.text('Split & Groups'), findsOneWidget);

      // Detail Panel
      await tester.pumpWidget(_wrapWithScreenUtil(
        GroupDetailPanel(
          event: event,
          onViewDetails: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Weekend Roadtrip'), findsOneWidget);
      expect(find.text('TOTAL SPENT'), findsOneWidget);
      expect(find.text('YOUR SHARE'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('OWNER'), findsOneWidget);
      expect(find.text('View Full Event & Expenses'), findsOneWidget);
    });
  });
}
