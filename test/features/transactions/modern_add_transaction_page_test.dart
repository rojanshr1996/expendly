import 'package:drift/native.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:expendly/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expendly/features/transactions/domain/entities/transaction_item.dart';
import 'package:expendly/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:expendly/features/transactions/presentation/pages/modern_add_transaction_page.dart';
import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWithApp(Widget child, {Size size = const Size(1024, 768)}) {
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

  setUpAll(() async {
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
    final ds = TransactionLocalDataSourceImpl(db);
    final repo = TransactionRepositoryImpl(ds);
    if (!getIt.isRegistered<TransactionCubit>()) {
      getIt.registerLazySingleton<TransactionCubit>(
        () => TransactionCubit(repo),
      );
    }
  });

  testWidgets('ModernAddTransactionPage renders properly on phone and tablet', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapWithApp(const ModernAddTransactionPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ModernAddTransactionPage), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Save Transaction'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ModernAddTransactionPage renders edit transfer mode and fields', (tester) async {
    final transferTx = TransactionItem(
      id: 1,
      amount: 150.0,
      type: TransactionType.transfer,
      timestamp: DateTime.now(),
      categoryId: 1,
      categoryName: 'Transfer',
      categoryIcon: 'swap_horiz',
      categoryColorHex: '#4F46E5',
      currencyCode: 'USD',
      paymentMethod: PaymentMethod.cash,
      note: 'Transfer: Cash → Account | Rent',
    );

    await tester.pumpWidget(_wrapWithApp(
      ModernAddTransactionPage(initialTransaction: transferTx),
      size: const Size(800, 1280),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ModernAddTransactionPage), findsOneWidget);
    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(find.widgetWithText(TextField, '150'), findsOneWidget);
    expect(find.text('From Payment Type'), findsOneWidget);
    expect(find.text('To Payment Type'), findsOneWidget);
    expect(find.text('Update Transaction'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ModernAddTransactionPage renders properly on phone screen', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapWithApp(const ModernAddTransactionPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ModernAddTransactionPage), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Entering a large number scales within FittedBox without RenderFlex overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapWithApp(const ModernAddTransactionPage()));
    await tester.pumpAndSettle();

    // Enter a very large amount that would previously overflow
    final textFieldFinder = find.byType(TextField).first;
    await tester.enterText(textFieldFinder, '9999999999.99');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '9999999999.99'), findsOneWidget);
    expect(find.byType(FittedBox), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
