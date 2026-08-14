import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/app_button.dart';
import 'package:expendly/features/dashboard/domain/entities/financial_summary.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_bento_grid.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_recent_activity.dart';
import 'package:expendly/features/dashboard/presentation/widgets/empty_dashboard_view.dart';
import 'package:expendly/features/profile/domain/entities/user_profile.dart';
import 'package:expendly/features/profile/domain/repositories/profile_repository.dart';
import 'package:expendly/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stand-in for the real repository so [ProfileCubit] can be registered without
/// touching drift. Returning `null` leaves the cubit in [ProfileInitial], which
/// makes [DashboardHeader] fall back to the localized app name.
class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async => profile;
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

    // DashboardHeader resolves ProfileCubit from the service locator, and
    // CompactAmountText resolves PreferenceService for the active currency
    // symbol, so both must be registered for these widgets to build.
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
        () => _FakeProfileRepository(),
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

  Widget createTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  group('Dashboard Components Tests', () {
    testWidgets('DashboardHeader renders app name and privacy toggle', (tester) async {
      final isPrivacyModeNotifier = ValueNotifier<bool>(false);

      await tester.pumpWidget(createTestableWidget(
        DashboardHeader(isPrivacyModeNotifier: isPrivacyModeNotifier),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Expendly'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });

    testWidgets('EmptyDashboardView renders welcome text and add button', (tester) async {
      bool addPressed = false;

      await tester.pumpWidget(createTestableWidget(
        EmptyDashboardView(
          onAddTransaction: () {
            addPressed = true;
          },
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('Welcome to your financial journey.'), findsOneWidget);
      expect(find.text('Add Your First Transaction'), findsOneWidget);

      final btnFinder = find.byType(AppButton);
      final appButton = tester.widget<AppButton>(btnFinder);
      appButton.onPressed?.call();
      expect(addPressed, isTrue);
    });

    testWidgets('DashboardBentoGrid renders totals and hides balance in privacy mode', (tester) async {
      final isPrivacyModeNotifier = ValueNotifier<bool>(false);
      final summary = FinancialSummary(
        totalBalance: 1779.50,
        totalIncome: 5200.00,
        totalExpense: 3420.50,
        monthlyBudgetLimit: 5000.00,
        currencySymbol: '\$',
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
      );

      await tester.pumpWidget(createTestableWidget(
        DashboardBentoGrid(
          summary: summary,
          isPrivacyModeNotifier: isPrivacyModeNotifier,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('\$1,779.50'), findsOneWidget);

      // Toggle privacy mode
      isPrivacyModeNotifier.value = true;
      await tester.pumpAndSettle();

      expect(find.text('\$ •••••'), findsWidgets);
    });

    testWidgets('DashboardRecentActivity renders transaction items', (tester) async {
      final isPrivacyModeNotifier = ValueNotifier<bool>(false);
      final mockTxList = [
        DashboardTransactionItem(
          id: 1,
          title: 'Food & Dining',
          categoryName: 'Food & Dining',
          note: 'Grocery Shopping',
          iconName: 'shopping_bag',
          colorHex: '#FB7185',
          amount: 850.20,
          date: DateTime.now(),
          isIncome: false,
        ),
      ];

      await tester.pumpWidget(createTestableWidget(
        DashboardRecentActivity(
          transactions: mockTxList,
          currencySymbol: '\$',
          isPrivacyModeNotifier: isPrivacyModeNotifier,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Grocery Shopping'), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('-\$850.20'), findsOneWidget);
    });
  });
}
