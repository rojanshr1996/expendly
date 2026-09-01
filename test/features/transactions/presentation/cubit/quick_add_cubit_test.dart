import 'package:drift/native.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/preferences/quick_entry_preferences.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:expendly/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expendly/features/transactions/domain/entities/category_item.dart';
import 'package:expendly/features/transactions/domain/usecases/get_quick_entry_defaults_use_case.dart';
import 'package:expendly/features/transactions/domain/usecases/update_quick_entry_defaults_use_case.dart';
import 'package:expendly/features/transactions/presentation/cubit/quick_add_cubit.dart';
import 'package:expendly/features/transactions/presentation/cubit/quick_add_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PreferenceService preferenceService;
  late QuickEntryPreferences quickEntryPreferences;
  late TransactionLocalDataSource dataSource;
  late TransactionRepositoryImpl repository;
  late GetQuickEntryDefaultsUseCase getDefaultsUseCase;
  late UpdateQuickEntryDefaultsUseCase updateDefaultsUseCase;
  late QuickAddCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    preferenceService = PreferenceService(SecureStorageService());
    await preferenceService.init();
    await preferenceService.setCurrency(code: 'USD', symbol: '\$');

    quickEntryPreferences = QuickEntryPreferences();
    dataSource = TransactionLocalDataSourceImpl(db);
    repository = TransactionRepositoryImpl(dataSource);

    getDefaultsUseCase = GetQuickEntryDefaultsUseCase(
      quickEntryPreferences: quickEntryPreferences,
      preferenceService: preferenceService,
      transactionRepository: repository,
      appDatabase: db,
    );
    updateDefaultsUseCase =
        UpdateQuickEntryDefaultsUseCase(quickEntryPreferences);

    cubit = QuickAddCubit(
      getDefaultsUseCase,
      updateDefaultsUseCase,
      repository,
      db,
    );
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  group('QuickAddCubit Tests', () {
    test('Initial state is QuickAddInitial', () {
      expect(cubit.state, isA<QuickAddInitial>());
    });

    test('loadDefaults populates smart defaults in QuickAddReady', () async {
      await cubit.loadDefaults();

      expect(cubit.state, isA<QuickAddReady>());
      final ready = cubit.state as QuickAddReady;
      expect(ready.amountText, isEmpty);
      expect(ready.defaults.currencyCode, equals('USD'));
      expect(ready.defaults.currencySymbol, equals('\$'));
      expect(ready.selectedCategory.name, isNotEmpty);
      expect(ready.selectedPaymentMethod, equals(PaymentMethod.cash));
    });

    test('setAmount updates amountText and validates correctly', () async {
      await cubit.loadDefaults();

      cubit.setAmount('25.50');
      var ready = cubit.state as QuickAddReady;
      expect(ready.amountText, equals('25.50'));
      expect(ready.amountValue, equals(25.50));
      expect(ready.isValid, isTrue);

      cubit.setAmount('');
      ready = cubit.state as QuickAddReady;
      expect(ready.amountValue, equals(0.0));
      expect(ready.isValid, isFalse);
    });

    test('selectCategory, selectPaymentMethod, selectDate update state',
        () async {
      await cubit.loadDefaults();

      const newCategory = CategoryItem(
        id: 3,
        name: 'Housing',
        icon: 'home',
        colorHex: '#2196F3',
        type: TransactionType.expense,
      );
      cubit.selectCategory(newCategory);
      var ready = cubit.state as QuickAddReady;
      expect(ready.selectedCategory.id, equals(3));
      expect(ready.selectedCategory.name, equals('Housing'));

      cubit.selectPaymentMethod(PaymentMethod.card);
      ready = cubit.state as QuickAddReady;
      expect(ready.selectedPaymentMethod, equals(PaymentMethod.card));

      final testDate = DateTime(2026, 8, 20);
      cubit.selectDate(testDate);
      ready = cubit.state as QuickAddReady;
      expect(ready.selectedDate, equals(testDate));
    });

    test('saveExpense with invalid amount sets error message', () async {
      await cubit.loadDefaults();
      cubit.setAmount('0');

      await cubit.saveExpense();

      final ready = cubit.state as QuickAddReady;
      expect(ready.errorMessage, contains('valid amount'));
    });

    test('saveExpense with addAnother: false saves to DB and emits QuickAddSuccess',
        () async {
      await cubit.loadDefaults();
      cubit.setAmount('50.00');

      await cubit.saveExpense(addAnother: false);

      expect(cubit.state, isA<QuickAddSuccess>());
      final success = cubit.state as QuickAddSuccess;
      expect(success.amount, equals(50.00));
      expect(success.addAnother, isFalse);

      // Verify stored in DB
      final transactions = await repository.getAllTransactions();
      expect(transactions.length, equals(1));
      expect(transactions.first.amount, equals(50.00));

      // Verify smart preferences learned the category & method
      final lastCategory = await quickEntryPreferences.getLastUsedCategoryId();
      expect(lastCategory, equals(transactions.first.categoryId));
    });

    test('saveExpense with addAnother: true resets amountText for next entry',
        () async {
      await cubit.loadDefaults();
      cubit.setAmount('12.50');

      await cubit.saveExpense(addAnother: true);

      // State is reset to QuickAddReady with empty amount
      expect(cubit.state, isA<QuickAddReady>());
      final ready = cubit.state as QuickAddReady;
      expect(ready.amountText, isEmpty);
      expect(ready.amountValue, equals(0.0));

      // DB should contain the saved transaction
      final transactions = await repository.getAllTransactions();
      expect(transactions.length, equals(1));
      expect(transactions.first.amount, equals(12.50));
    });
  });
}
