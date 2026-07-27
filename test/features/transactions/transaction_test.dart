import 'package:drift/native.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:expendly/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expendly/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:expendly/features/transactions/presentation/cubit/transaction_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionLocalDataSource dataSource;
  late TransactionRepositoryImpl repository;
  late TransactionCubit cubit;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = TransactionLocalDataSourceImpl(db);
    repository = TransactionRepositoryImpl(dataSource);
    cubit = TransactionCubit(repository);
  });

  tearDown(() async {
    await db.close();
  });

  test('Initial state of TransactionCubit should be TransactionInitial', () {
    expect(cubit.state, equals(TransactionInitial()));
  });

  test('Should insert transaction and retrieve it via cubit loadTransactions', () async {
    // Get seeded default category ID (Category 1: Food & Dining)
    final categories = await db.select(db.categories).get();
    expect(categories, isNotEmpty);
    final firstCat = categories.first;

    await cubit.addTransaction(
      type: TransactionType.expense,
      amount: 45.50,
      categoryId: firstCat.id,
      timestamp: DateTime.now(),
      note: 'Dinner with friends',
    );

    expect(cubit.state, isA<TransactionLoaded>());
    final loaded = cubit.state as TransactionLoaded;
    expect(loaded.transactions, hasLength(1));
    expect(loaded.transactions.first.amount, equals(45.50));
    expect(loaded.transactions.first.note, equals('Dinner with friends'));
  });

  test('Should filter transactions by search query', () async {
    final categories = await db.select(db.categories).get();
    final firstCat = categories.first;

    await dataSource.addTransaction(
      type: TransactionType.expense,
      amount: 10.0,
      categoryId: firstCat.id,
      timestamp: DateTime.now(),
      note: 'Coffee',
    );

    await dataSource.addTransaction(
      type: TransactionType.expense,
      amount: 100.0,
      categoryId: firstCat.id,
      timestamp: DateTime.now(),
      note: 'Grocery store',
    );

    await cubit.loadTransactions();
    expect(cubit.state, isA<TransactionLoaded>());

    cubit.filterSearch('Coffee');
    final loaded = cubit.state as TransactionLoaded;
    expect(loaded.filteredTransactions, hasLength(1));
    expect(loaded.filteredTransactions.first.note, equals('Coffee'));
  });
}
