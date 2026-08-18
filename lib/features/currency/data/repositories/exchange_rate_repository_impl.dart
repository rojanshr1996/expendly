import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../datasources/exchange_rate_local_datasource.dart';
import '../datasources/exchange_rate_remote_datasource.dart';

@LazySingleton(as: ExchangeRateRepository)
class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final ExchangeRateRemoteDataSource _remoteDataSource;
  final ExchangeRateLocalDataSource _localDataSource;
  final AppDatabase _db;

  ExchangeRateRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._db,
  );

  @override
  Future<Map<String, double>> getExchangeRates({String base = 'USD'}) async {
    final sanitizedBase = base.trim().toUpperCase();

    // 1. Attempt fresh fetch from Open Exchange Rates API
    try {
      final model = await _remoteDataSource.getLatestRates(
        baseCurrency: sanitizedBase,
      );
      if (model.rates.isNotEmpty) {
        await _localDataSource.cacheRates(model);
        return model.rates;
      }
    } catch (e) {
      AppLogger.w(
        'Unable to fetch live rates from network for base $sanitizedBase: $e. Falling back to local cache.',
      );
    }

    // 2. Fallback to cached rates if present
    final cached = await _localDataSource.getCachedRates(
      baseCurrency: sanitizedBase,
    );
    if (cached != null && cached.rates.isNotEmpty) {
      return cached.rates;
    }

    // 3. Fallback to pre-seeded baseline static rates
    final fallback = _localDataSource.getFallbackRates(
      baseCurrency: sanitizedBase,
    );
    return fallback.rates;
  }

  @override
  Future<double> getExchangeRate({
    required String from,
    required String to,
  }) async {
    final fromCode = from.trim().toUpperCase();
    final toCode = to.trim().toUpperCase();

    if (fromCode == toCode) {
      return 1.0;
    }

    // Fetch rate table with 'from' as base
    final rates = await getExchangeRates(base: fromCode);
    if (rates.containsKey(toCode) &&
        rates[toCode] != null &&
        rates[toCode]! > 0) {
      return rates[toCode]!;
    }

    // Cross-rate calculation via USD if direct rate not present
    final usdRates = await getExchangeRates(base: 'USD');
    final fromToUsd = usdRates[fromCode];
    final toToUsd = usdRates[toCode];

    if (fromToUsd != null && toToUsd != null && fromToUsd > 0) {
      return toToUsd / fromToUsd;
    }

    return 1.0;
  }

  @override
  Future<double> convertAmount({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from.trim().toUpperCase() == to.trim().toUpperCase() || amount == 0) {
      return amount;
    }
    final rate = await getExchangeRate(from: from, to: to);
    return amount * rate;
  }

  @override
  Future<double> convertAllDataToNewCurrency({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final fromCode = fromCurrency.trim().toUpperCase();
    final toCode = toCurrency.trim().toUpperCase();

    if (fromCode == toCode) {
      return 1.0;
    }

    final rate = await getExchangeRate(from: fromCode, to: toCode);
    if (rate <= 0 || rate.isNaN || rate.isInfinite) {
      AppLogger.w(
          'Invalid exchange rate calculated: $rate. Aborting conversion.');
      return 1.0;
    }

    AppLogger.i(
        'Starting database currency migration from $fromCode to $toCode at rate $rate');

    await _db.transaction(() async {
      // 1. Convert all Transactions
      final allTransactions = await _db.select(_db.transactions).get();
      for (final tx in allTransactions) {
        final newMinorUnits = (tx.amount * rate).round();
        await _db.update(_db.transactions).replace(
              tx.copyWith(
                amount: newMinorUnits,
                currencyCode: toCode,
              ),
            );
      }

      // 2. Convert all Budgets
      final allBudgets = await _db.select(_db.budgets).get();
      for (final budget in allBudgets) {
        final newMinorUnits = (budget.targetAmount * rate).round();
        await _db.update(_db.budgets).replace(
              budget.copyWith(
                targetAmount: newMinorUnits,
                currencyCode: toCode,
              ),
            );
      }

      // 3. Convert all Recurring Transactions
      final allRecurring = await _db.select(_db.recurringTransactions).get();
      for (final rec in allRecurring) {
        final newMinorUnits = (rec.amount * rate).round();
        await _db.update(_db.recurringTransactions).replace(
              rec.copyWith(
                amount: newMinorUnits,
              ),
            );
      }
    });

    AppLogger.i(
        'Completed database currency migration to $toCode (Rate: $rate)');
    return rate;
  }
}
