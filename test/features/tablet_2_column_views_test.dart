import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/features/analytics/data/datasources/analytics_local_datasource.dart';
import 'package:expendly/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:expendly/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:expendly/features/analytics/presentation/pages/refined_reports_page.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_chart_panel.dart';
import 'package:expendly/features/analytics/presentation/widgets/report_insights_sidebar.dart';
import 'package:expendly/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expendly/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:expendly/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:expendly/features/budgets/presentation/pages/budgets_overview_page.dart';
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
  late AppDatabase db;

  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );

    db = AppDatabase.forTesting(NativeDatabase.memory());
    if (!getIt.isRegistered<AppDatabase>()) {
      getIt.registerSingleton<AppDatabase>(db);
    }
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
    if (!getIt.isRegistered<BudgetCubit>()) {
      final ds = BudgetLocalDataSourceImpl(db);
      final repo = BudgetRepositoryImpl(ds);
      getIt.registerLazySingleton<BudgetCubit>(
        () => BudgetCubit(repo),
      );
    }
    if (!getIt.isRegistered<AnalyticsCubit>()) {
      final ds = AnalyticsLocalDataSourceImpl(db);
      final repo = AnalyticsRepositoryImpl(ds);
      getIt.registerLazySingleton<AnalyticsCubit>(
        () => AnalyticsCubit(repo),
      );
    }
  });

  tearDownAll(() async {
    await db.close();
    await getIt.reset();
  });

  group('2-Column Tablet Layout Tests', () {
    testWidgets(
        'BudgetsOverviewPage renders 2-column layout (Card List + Health Sidebar) on tablet without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapTestApp(
          const Scaffold(
            body: BudgetsOverviewPage(),
          ),
          size: const Size(800, 1280),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Budget Card Grid and Health Sidebar exist side-by-side
      expect(find.byType(BudgetCardGrid), findsOneWidget);
      expect(find.byType(BudgetHealthSidebar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'RefinedReportsPage renders 2-column layout (Chart Panel + Unified Insights Sidebar) on tablet without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapTestApp(
          const Scaffold(
            body: RefinedReportsPage(),
          ),
          size: const Size(1024, 768),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Report Chart Panel and Insights Sidebar are rendered in 2 columns
      expect(find.byType(ReportChartPanel), findsOneWidget);
      expect(find.byType(ReportInsightsSidebar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
