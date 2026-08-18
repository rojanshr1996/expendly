import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/features/currency/data/datasources/exchange_rate_local_datasource.dart';
import 'package:expendly/features/currency/data/datasources/exchange_rate_remote_datasource.dart';
import 'package:expendly/features/currency/data/models/exchange_rates_model.dart';
import 'package:expendly/features/currency/data/repositories/exchange_rate_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRemoteDataSource implements ExchangeRateRemoteDataSource {
  ExchangeRatesModel? mockResult;
  bool shouldThrow = false;

  @override
  Future<ExchangeRatesModel> getLatestRates({
    String baseCurrency = 'USD',
  }) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return mockResult ??
        ExchangeRatesModel(
          result: 'success',
          baseCode: baseCurrency.toUpperCase(),
          rates: {
            'USD': 1.0,
            'NPR': 134.50,
            'EUR': 0.92,
            'GBP': 0.78,
            'INR': 83.95,
          },
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeRemoteDataSource fakeRemoteDataSource;
  late ExchangeRateLocalDataSource localDataSource;
  late ExchangeRateRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeRemoteDataSource = FakeRemoteDataSource();
    localDataSource = ExchangeRateLocalDataSourceImpl();
    repository = ExchangeRateRepositoryImpl(
      fakeRemoteDataSource,
      localDataSource,
      db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ExchangeRatesModel tests', () {
    test('Should correctly parse from JSON and serialize to JSON', () {
      final json = {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_utc': 'Fri, 14 Aug 2026 00:00:01 +0000',
        'time_last_update_unix': 1786665601,
        'rates': {
          'USD': 1.0,
          'NPR': 134.52,
          'EUR': 0.92,
        },
      };

      final model = ExchangeRatesModel.fromJson(json);
      expect(model.result, equals('success'));
      expect(model.baseCode, equals('USD'));
      expect(model.rates['NPR'], equals(134.52));
      expect(model.rates['EUR'], equals(0.92));

      final serialized = model.toJson();
      expect(serialized['base_code'], equals('USD'));
      expect((serialized['rates'] as Map)['NPR'], equals(134.52));
    });
  });

  group('ExchangeRateRepository tests', () {
    test('Should return 1.0 for same currency pair', () async {
      final rate = await repository.getExchangeRate(from: 'USD', to: 'USD');
      expect(rate, equals(1.0));
    });

    test('Should fetch exchange rate from remote data source', () async {
      final rate = await repository.getExchangeRate(from: 'USD', to: 'NPR');
      expect(rate, equals(134.50));
    });

    test('Should calculate cross rates accurately (e.g. EUR to NPR)', () async {
      // 1 USD = 0.92 EUR, 1 USD = 134.50 NPR
      // 1 EUR = 134.50 / 0.92 ≈ 146.19565
      fakeRemoteDataSource.mockResult = ExchangeRatesModel(
        result: 'success',
        baseCode: 'USD',
        rates: {
          'USD': 1.0,
          'EUR': 0.92,
          'NPR': 134.50,
        },
      );

      final converted = await repository.convertAmount(
        amount: 100.0,
        from: 'USD',
        to: 'NPR',
      );
      expect(converted, equals(13450.0));
    });

    test('Should fallback to cached/static rates if network throws', () async {
      fakeRemoteDataSource.shouldThrow = true;
      final rates = await repository.getExchangeRates(base: 'USD');
      expect(rates, isNotEmpty);
      expect(rates.containsKey('NPR'), isTrue);
      expect(rates['NPR']!, greaterThan(0));
    });

    test('Should atomically convert database transactions, budgets, and recurring items',
        () async {
      final categories = await db.select(db.categories).get();
      final cat = categories.first;

      // 1. Insert a transaction ($100.00 USD -> 10000 minor units)
      final txId = await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              type: TransactionType.expense,
              amount: 10000,
              currencyCode: const drift.Value('USD'),
              categoryId: cat.id,
              timestamp: DateTime.now(),
              note: const drift.Value('Dinner'),
            ),
          );

      // 2. Insert a budget ($500.00 USD -> 50000 minor units)
      final budgetId = await db.into(db.budgets).insert(
            BudgetsCompanion.insert(
              categoryId: drift.Value(cat.id),
              targetAmount: 50000,
              period: BudgetPeriod.monthly,
              currencyCode: const drift.Value('USD'),
            ),
          );

      // 3. Insert a recurring transaction ($20.00 USD -> 2000 minor units)
      final recId = await db.into(db.recurringTransactions).insert(
            RecurringTransactionsCompanion.insert(
              type: TransactionType.expense,
              amount: 2000,
              categoryId: cat.id,
              frequency: RecurrenceFrequency.monthly,
              nextDueDate: DateTime.now().add(const Duration(days: 30)),
            ),
          );

      // 4. Convert all data to NPR (Rate: 1 USD = 134.50 NPR)
      final usedRate = await repository.convertAllDataToNewCurrency(
        fromCurrency: 'USD',
        toCurrency: 'NPR',
      );
      expect(usedRate, equals(134.50));

      // 5. Verify transaction conversion
      final updatedTx = await (db.select(db.transactions)
            ..where((t) => t.id.equals(txId)))
          .getSingle();
      expect(updatedTx.amount, equals(1345000)); // 10000 * 134.50
      expect(updatedTx.currencyCode, equals('NPR'));

      // 6. Verify budget conversion
      final updatedBudget = await (db.select(db.budgets)
            ..where((b) => b.id.equals(budgetId)))
          .getSingle();
      expect(updatedBudget.targetAmount, equals(6725000)); // 50000 * 134.50
      expect(updatedBudget.currencyCode, equals('NPR'));

      // 7. Verify recurring transaction conversion
      final updatedRec = await (db.select(db.recurringTransactions)
            ..where((r) => r.id.equals(recId)))
          .getSingle();
      expect(updatedRec.amount, equals(269000)); // 2000 * 134.50
    });

    test('Should NOT convert split bills data (sharing events & group expenses) during currency migration',
        () async {
      // 1. Create a sharing event
      final eventId = await db.into(db.sharingEvents).insert(
            SharingEventsCompanion.insert(
              name: 'Trip to Tokyo',
              category: const drift.Value('Trip'),
              startDate: DateTime.now(),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 2. Add an event participant
      final participantId = await db.into(db.eventParticipants).insert(
            EventParticipantsCompanion.insert(
              eventId: eventId,
              name: 'Alice',
              isOwner: const drift.Value(true),
            ),
          );

      // 3. Add a group expense of $50.00 (5000 minor units)
      final expenseId = await db.into(db.groupExpenses).insert(
            GroupExpensesCompanion.insert(
              eventId: eventId,
              title: 'Dinner',
              amountInCents: 5000,
              paidByParticipantId: participantId,
              date: DateTime.now(),
            ),
          );

      // 4. Convert primary currency from USD to NPR (Rate: 134.50)
      final rate = await repository.convertAllDataToNewCurrency(
        fromCurrency: 'USD',
        toCurrency: 'NPR',
      );
      expect(rate, equals(134.50));

      // 5. Verify the group expense amount remains exactly 5000 (NOT multiplied by 134.50)
      final expense = await (db.select(db.groupExpenses)
            ..where((g) => g.id.equals(expenseId)))
          .getSingle();
      expect(expense.amountInCents, equals(5000));
    });
  });
}
