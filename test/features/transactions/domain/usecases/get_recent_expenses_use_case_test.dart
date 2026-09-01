import 'package:drift/native.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:expendly/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expendly/features/transactions/domain/usecases/get_recent_expenses_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionLocalDataSource dataSource;
  late TransactionRepositoryImpl repository;
  late GetRecentExpensesUseCase useCase;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = TransactionLocalDataSourceImpl(db);
    repository = TransactionRepositoryImpl(dataSource);
    useCase = GetRecentExpensesUseCase(repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('GetRecentExpensesUseCase Tests', () {
    test('Returns empty list when no transactions exist', () async {
      final results = await useCase(const GetRecentExpensesParams());
      expect(results, isEmpty);
    });

    test('Returns expenses ordered by timestamp descending respecting limit',
        () async {
      final categories = await db.select(db.categories).get();
      final cat1 = categories.first.id;
      final cat2 = categories[1].id;

      // Add transactions
      await dataSource.addTransaction(
        type: TransactionType.expense,
        amount: 15.0,
        categoryId: cat1,
        timestamp: DateTime(2026, 8, 20, 10, 0),
        note: 'First Expense',
      );

      await dataSource.addTransaction(
        type: TransactionType.income,
        amount: 1000.0,
        categoryId: cat2,
        timestamp: DateTime(2026, 8, 21, 10, 0),
        note: 'Salary Income',
      );

      await dataSource.addTransaction(
        type: TransactionType.expense,
        amount: 45.0,
        categoryId: cat1,
        timestamp: DateTime(2026, 8, 22, 10, 0),
        note: 'Latest Expense',
      );

      // Query only expenses (default)
      final expenses = await useCase(const GetRecentExpensesParams(limit: 5));
      expect(expenses, hasLength(2));
      expect(expenses.first.note, equals('Latest Expense'));
      expect(expenses.first.amount, equals(45.0));
      expect(expenses[1].note, equals('First Expense'));
      expect(expenses[1].amount, equals(15.0));

      // Query with limit = 1
      final limited = await useCase(const GetRecentExpensesParams(limit: 1));
      expect(limited, hasLength(1));
      expect(limited.first.note, equals('Latest Expense'));
    });
  });
}
