import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/features/analytics/domain/entities/analytics_report.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_chart_panel.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_insights_sidebar.dart';
import 'package:expendly/features/budgets/domain/entities/budget_item.dart';
import 'package:expendly/features/budgets/presentation/widgets/budget_card_grid.dart';
import 'package:expendly/features/budgets/presentation/widgets/budget_health_sidebar.dart';
import 'package:expendly/l10n/app_localizations.dart';

Widget _wrapTestApp(Widget child, {Size size = const Size(1024, 768)}) {
  return ScreenUtilInit(
    designSize: size,
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
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

  group('2-Column Tablet Layout Tests', () {
    testWidgets(
        'Budgets 2-column layout (Card List + Health Sidebar) renders on tablet without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleBudgets = [
        const BudgetItem(
          id: 1,
          categoryName: 'Food & Dining',
          targetAmount: 500.0,
          spentAmount: 250.0,
          categoryIcon: 'restaurant',
          categoryColorHex: 'FF5722',
        ),
        const BudgetItem(
          id: 2,
          categoryName: 'Transportation',
          targetAmount: 200.0,
          spentAmount: 180.0,
          categoryIcon: 'directions_car',
          categoryColorHex: '2196F3',
        ),
      ];

      await tester.pumpWidget(
        _wrapTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: BudgetCardGrid(
                      budgets: sampleBudgets,
                      onCreateBudget: () {},
                      onDeleteBudget: (_) {},
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 4,
                    child: BudgetHealthSidebar(
                      budgets: sampleBudgets,
                    ),
                  ),
                ],
              ),
            ),
          ),
          size: const Size(800, 1280),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Budget Card Grid and Health Sidebar exist side-by-side
      expect(find.byType(BudgetCardGrid), findsOneWidget);
      expect(find.byType(BudgetHealthSidebar), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Analytics 2-column layout (Chart Panel + Unified Insights Sidebar) renders on tablet without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const sampleReport = AnalyticsReport(
        totalIncome: 5000.0,
        totalExpense: 3200.0,
        netSavings: 1800.0,
        savingsRatePercentage: 36.0,
        avgDailySpend: 100.0,
        budgetHealthPercentage: 78.0,
        budgetHealthStatus: 'Healthy',
        topCategoryName: 'Rent',
        topCategoryPercentage: 40.0,
        dailyFlows: [],
        categoryBreakdowns: [],
      );

      await tester.pumpWidget(
        _wrapTestApp(
          Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 6,
                  child: ReportChartPanel(
                    report: sampleReport,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ReportInsightsSidebar(
                    report: sampleReport,
                    onExportPdf: () {},
                    onExportCsv: () {},
                  ),
                ),
              ],
            ),
          ),
          size: const Size(1024, 768),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Report Chart Panel and Insights Sidebar are rendered in 2 columns
      expect(find.byType(ReportChartPanel), findsOneWidget);
      expect(find.byType(ReportInsightsSidebar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
