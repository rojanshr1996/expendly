import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/adaptive_sheet.dart';
import 'package:expendly/core/widgets/compact_amount_text.dart';
import 'package:expendly/features/dashboard/domain/entities/financial_summary.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_bento_grid.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_recent_activity.dart';
import 'package:expendly/features/dashboard/presentation/widgets/dashboard_recent_groups.dart';
import 'package:expendly/features/profile/domain/entities/user_profile.dart';
import 'package:expendly/features/profile/domain/repositories/profile_repository.dart';
import 'package:expendly/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:expendly/l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expendly/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:expendly/features/groups/presentation/cubit/groups_state.dart';

class _FakeProfileRepo implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async => profile;
}

class FakeGroupsCubit extends Cubit<GroupsState> implements GroupsCubit {
  FakeGroupsCubit(super.initialState);

  @override
  Future<void> loadEvents({bool isSilent = false}) async {}

  @override
  Future<void> createEvent({
    required String name,
    String description = '',
    required DateTime startDate,
    DateTime? endDate,
    String category = 'trip',
  }) async {}

  @override
  Future<void> updateEvent({
    required int id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? status,
  }) async {}

  @override
  Future<void> deleteEvent(int id) async {}

  @override
  Future<void> markEventSettled(int id) async {}
}

Widget _wrapPhoneApp(
  Widget child, {
  Size size = const Size(393, 852),
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
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

  group('Phase 5.5: Phone (Compact Tier) Zero-Regression Tests', () {
    const phoneSizes = [
      Size(393, 852), // iPhone 15
      Size(430, 932), // iPhone 15 Pro Max
    ];

    for (final size in phoneSizes) {
      testWidgets('Verify phone layout on ${size.width}x${size.height}',
          (tester) async {
        tester.view.physicalSize = size;
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

        await tester.pumpWidget(
          _wrapPhoneApp(
            BlocProvider<GroupsCubit>.value(
              value: FakeGroupsCubit(const GroupsLoaded([])),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DashboardHeader(
                      isPrivacyModeNotifier: privacyNotifier,
                    ),
                    DashboardBentoGrid(
                      summary: summary,
                      isPrivacyModeNotifier: privacyNotifier,
                    ),
                    DashboardRecentGroups(
                      onSeeAllPressed: () {},
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
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        // Check phone header
        expect(find.text('Expendly'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

        // Check Bento grid
        expect(find.byType(DashboardBentoGrid), findsOneWidget);
        expect(find.byType(CompactAmountText), findsWidgets);

        // Check Recent Groups & Activity on phone
        expect(find.text('SPLIT BILLS & EXPENSES'), findsOneWidget);
        expect(find.text('Groceries'), findsWidgets);
        expect(find.text('Weekly organic groceries'), findsOneWidget);
        expect(find.byType(DashboardRecentActivity), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
        'AdaptiveSheet renders BottomSheet (not Dialog) on compact phone viewport',
        (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapPhoneApp(
          Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () {
                  AdaptiveSheet.show(
                    context: ctx,
                    builder: (_) => const Text('Phone Bottom Sheet Content'),
                  );
                },
                child: const Text('Open Phone Sheet'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Phone Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Phone Bottom Sheet Content'), findsOneWidget);
    });
  });
}
