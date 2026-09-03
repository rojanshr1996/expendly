import 'package:drift/native.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/preferences/quick_entry_preferences.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_colors.dart';
import 'package:expendly/core/theme/app_typography.dart';
import 'package:expendly/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:expendly/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expendly/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expendly/features/transactions/domain/usecases/get_quick_entry_defaults_use_case.dart';
import 'package:expendly/features/transactions/domain/usecases/update_quick_entry_defaults_use_case.dart';
import 'package:expendly/features/transactions/presentation/cubit/quick_add_cubit.dart';
import 'package:expendly/features/transactions/presentation/pages/quick_add_page.dart';
import 'package:expendly/features/transactions/presentation/widgets/quick_amount_keypad.dart';
import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrapWithApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: [
          AppCustomColors.light,
          AppCustomTypography.light,
        ],
      ),
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

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    AppConfig.initialize(
      const AppConfig(flavor: AppFlavor.dev, appName: 'Expendly Dev'),
    );

    db = AppDatabase.forTesting(NativeDatabase.memory());
    if (getIt.isRegistered<AppDatabase>()) {
      await getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(db);

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
    if (!getIt.isRegistered<QuickEntryPreferences>()) {
      getIt.registerLazySingleton<QuickEntryPreferences>(
        () => QuickEntryPreferences(),
      );
    }
    if (!getIt.isRegistered<TransactionRepository>()) {
      getIt.registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(TransactionLocalDataSourceImpl(db)),
      );
    }
    if (!getIt.isRegistered<GetQuickEntryDefaultsUseCase>()) {
      getIt.registerLazySingleton<GetQuickEntryDefaultsUseCase>(
        () => GetQuickEntryDefaultsUseCase(
          quickEntryPreferences: getIt<QuickEntryPreferences>(),
          preferenceService: getIt<PreferenceService>(),
          transactionRepository: getIt<TransactionRepository>(),
          appDatabase: db,
        ),
      );
    }
    if (!getIt.isRegistered<UpdateQuickEntryDefaultsUseCase>()) {
      getIt.registerLazySingleton<UpdateQuickEntryDefaultsUseCase>(
        () => UpdateQuickEntryDefaultsUseCase(getIt<QuickEntryPreferences>()),
      );
    }
    if (getIt.isRegistered<QuickAddCubit>()) {
      await getIt.unregister<QuickAddCubit>();
    }
    getIt.registerFactory<QuickAddCubit>(() => QuickAddCubit(
          getIt<GetQuickEntryDefaultsUseCase>(),
          getIt<UpdateQuickEntryDefaultsUseCase>(),
          getIt<TransactionRepository>(),
          db,
        ));

    // Pre-open DB and seed default categories
    await db.select(db.categories).get();

    await getIt<PreferenceService>().init();
    await getIt<PreferenceService>().setCurrency(code: 'USD', symbol: '\$');
  });

  late QuickAddCubit cubit;

  setUp(() async {
    cubit = getIt<QuickAddCubit>();
    await cubit.loadDefaults();
  });

  group('QuickAddPage Widget Tests', () {
    testWidgets('Renders top bar, hero amount, keypad, and action buttons', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrapWithApp(QuickAddPage(
        key: UniqueKey(),
        cubit: cubit,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Quick Expense'), findsOneWidget);
      expect(find.text('More Details'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('+ Add Another'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byType(QuickAmountKeypad), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tapping keypad updates amount and backspace deletes digit', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrapWithApp(QuickAddPage(
        key: UniqueKey(),
        cubit: cubit,
      )));
      await tester.pumpAndSettle();

      // Tap '5', '8' on keypad
      await tester.tap(find.text('5'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('8'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('58'), findsOneWidget);

      // Tap backspace
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump(const Duration(milliseconds: 100));

      // One in hero amount, one on keypad key
      expect(find.text('5'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    });

    testWidgets('Tapping payment method cycles payment methods and shows more options indicator', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrapWithApp(QuickAddPage(
        key: UniqueKey(),
        cubit: cubit,
      )));
      await tester.pumpAndSettle();

      // Initial method is Cash and shows unfold_more indicator
      expect(find.text('Cash'), findsOneWidget);
      expect(find.byIcon(Icons.unfold_more_rounded), findsOneWidget);

      // Tap Cash chip
      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();

      // Cash should no longer be displayed as selected method
      expect(find.text('Cash'), findsNothing);
      expect(find.byIcon(Icons.unfold_more_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('QuickAddBottomSheet renders liquid glass container with drag handle', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrapWithApp(QuickAddBottomSheet(
        key: UniqueKey(),
        cubit: cubit,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Quick Expense'), findsOneWidget);
      expect(find.text('More Details'), findsOneWidget);
      expect(find.byType(QuickAmountKeypad), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders distinguishable Recent Expenses section when recent transactions exist', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.runAsync(() async {
        final cat = (await db.select(db.categories).get()).first;
        await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                type: TransactionType.expense,
                amount: 1550, // $15.50
                categoryId: cat.id,
                timestamp: DateTime.now(),
              ),
            );
        await cubit.loadDefaults();
      });

      await tester.pumpWidget(_wrapWithApp(QuickAddBottomSheet(
        key: UniqueKey(),
        cubit: cubit,
      )));
      await tester.pumpAndSettle();

      expect(find.text('RECENT EXPENSES'), findsOneWidget);
      expect(find.text('Tap to re-fill'), findsOneWidget);
      expect(find.text('-\$15.50'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Compresses large amounts in Recent Expenses section without filling width', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.runAsync(() async {
        final cat = (await db.select(db.categories).get()).first;
        await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                type: TransactionType.expense,
                amount: 15000000, // $150,000.00 -> 150K
                categoryId: cat.id,
                timestamp: DateTime.now(),
              ),
            );
        await cubit.loadDefaults();
      });

      await tester.pumpWidget(_wrapWithApp(QuickAddBottomSheet(
        key: UniqueKey(),
        cubit: cubit,
      )));
      await tester.pumpAndSettle();

      expect(find.text('-\$150K'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Entering a large number via keypad in Quick Add scales within FittedBox without overflow', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrapWithApp(QuickAddPage(cubit: cubit)));
      await tester.pumpAndSettle();

      // Tap '9' on keypad until max digits
      final keypadNine = find.descendant(
        of: find.byType(QuickAmountKeypad),
        matching: find.text('9'),
      );
      for (int i = 0; i < 9; i++) {
        await tester.tap(keypadNine);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      expect(find.text('999999999'), findsOneWidget);
      expect(find.byType(FittedBox), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
