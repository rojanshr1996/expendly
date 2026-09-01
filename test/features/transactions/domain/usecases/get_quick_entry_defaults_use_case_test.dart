import 'package:drift/native.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/preferences/quick_entry_preferences.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:expendly/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expendly/features/transactions/domain/usecases/get_quick_entry_defaults_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PreferenceService preferenceService;
  late QuickEntryPreferences quickEntryPreferences;
  late TransactionLocalDataSource dataSource;
  late TransactionRepositoryImpl repository;
  late GetQuickEntryDefaultsUseCase useCase;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    preferenceService = PreferenceService(SecureStorageService());
    await preferenceService.init();
    await preferenceService.setCurrency(code: 'USD', symbol: '\$');

    quickEntryPreferences = QuickEntryPreferences();
    dataSource = TransactionLocalDataSourceImpl(db);
    repository = TransactionRepositoryImpl(dataSource);

    useCase = GetQuickEntryDefaultsUseCase(
      quickEntryPreferences: quickEntryPreferences,
      preferenceService: preferenceService,
      transactionRepository: repository,
      appDatabase: db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('GetQuickEntryDefaultsUseCase Tests', () {
    test('Returns default fallback when no preferences or transactions exist',
        () async {
      final defaults = await useCase(const QuickEntryDefaultsParams());

      expect(defaults.currencyCode, equals('USD'));
      expect(defaults.currencySymbol, equals('\$'));
      expect(defaults.paymentMethod, equals(PaymentMethod.cash));
      expect(defaults.categoryId, isNotNull);
      expect(defaults.categoryName, isNotEmpty);
    });

    test('Explicit parameters take highest precedence', () async {
      await quickEntryPreferences.setLastUsedCategoryId(2);
      await quickEntryPreferences
          .setLastUsedPaymentMethod(PaymentMethod.account);

      final explicitDate = DateTime(2026, 8, 15);
      final defaults = await useCase(QuickEntryDefaultsParams(
        explicitCategoryId: 3,
        explicitPaymentMethod: PaymentMethod.card,
        explicitDate: explicitDate,
        sessionCategoryId: 4,
        sessionPaymentMethod: PaymentMethod.cash,
      ));

      expect(defaults.categoryId, equals(3));
      expect(defaults.paymentMethod, equals(PaymentMethod.card));
      expect(defaults.date, equals(explicitDate));
    });

    test('Session parameters take precedence over preferences and recent items',
        () async {
      await quickEntryPreferences.setLastUsedCategoryId(2);
      await quickEntryPreferences
          .setLastUsedPaymentMethod(PaymentMethod.account);

      final sessionDate = DateTime(2026, 8, 18);
      final defaults = await useCase(QuickEntryDefaultsParams(
        sessionCategoryId: 5,
        sessionPaymentMethod: PaymentMethod.card,
        sessionDate: sessionDate,
      ));

      expect(defaults.categoryId, equals(5));
      expect(defaults.paymentMethod, equals(PaymentMethod.card));
      expect(defaults.date, equals(sessionDate));
    });

    test('Learned preferences take precedence over recent transactions',
        () async {
      final categories = await db.select(db.categories).get();
      final cat1 = categories.first.id;
      final cat2 = categories[1].id;

      // Add a recent transaction with cat1 and PaymentMethod.cash
      await dataSource.addTransaction(
        type: TransactionType.expense,
        amount: 20.0,
        categoryId: cat1,
        timestamp: DateTime.now(),
        paymentMethod: PaymentMethod.cash,
      );

      // Save preferences pointing to cat2 and PaymentMethod.account
      await quickEntryPreferences.setLastUsedCategoryId(cat2);
      await quickEntryPreferences
          .setLastUsedPaymentMethod(PaymentMethod.account);

      final defaults = await useCase(const QuickEntryDefaultsParams());

      expect(defaults.categoryId, equals(cat2));
      expect(defaults.paymentMethod, equals(PaymentMethod.account));
    });

    test('Falls back to most recent transaction if preferences are null',
        () async {
      final categories = await db.select(db.categories).get();
      final cat2 = categories[1];

      await dataSource.addTransaction(
        type: TransactionType.expense,
        amount: 55.0,
        categoryId: cat2.id,
        timestamp: DateTime.now(),
        paymentMethod: PaymentMethod.card,
      );

      final defaults = await useCase(const QuickEntryDefaultsParams());

      expect(defaults.categoryId, equals(cat2.id));
      expect(defaults.categoryName, equals(cat2.name));
      expect(defaults.paymentMethod, equals(PaymentMethod.card));
    });
  });
}
