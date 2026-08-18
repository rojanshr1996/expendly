import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/app_logger.dart';
import '../models/exchange_rates_model.dart';

abstract class ExchangeRateLocalDataSource {
  Future<ExchangeRatesModel?> getCachedRates({String baseCurrency = 'USD'});
  Future<void> cacheRates(ExchangeRatesModel rates);
  ExchangeRatesModel getFallbackRates({String baseCurrency = 'USD'});
}

@LazySingleton(as: ExchangeRateLocalDataSource)
class ExchangeRateLocalDataSourceImpl implements ExchangeRateLocalDataSource {
  static const String _ratesKeyPrefix = 'cached_exchange_rates_';
  static const String _updatedAtKeyPrefix = 'cached_exchange_rates_timestamp_';

  // 24 hours TTL for currency cache
  static const Duration _cacheTtl = Duration(hours: 24);

  // Robust baseline fallback table against USD in case of first-run offline state
  static const Map<String, double> _usdFallbackRates = {
    'USD': 1.0,
    'NPR': 134.50,
    'EUR': 0.92,
    'GBP': 0.78,
    'INR': 83.95,
    'JPY': 155.0,
    'CAD': 1.36,
    'AUD': 1.51,
    'CHF': 0.90,
    'CNY': 7.25,
    'SGD': 1.35,
    'AED': 3.6725,
    'SAR': 3.75,
    'QAR': 3.64,
    'MYR': 4.71,
    'THB': 36.5,
    'KRW': 1370.0,
    'HKD': 7.82,
    'NZD': 1.63,
    'BRL': 5.40,
    'MXN': 18.2,
    'ZAR': 18.1,
    'SEK': 10.5,
    'NOK': 10.6,
    'DKK': 6.85,
    'PLN': 3.95,
    'TRY': 32.8,
    'RUB': 88.0,
    'IDR': 16200.0,
    'PHP': 58.5,
    'VND': 25400.0,
    'PKR': 278.5,
    'BDT': 117.5,
    'LKR': 302.0,
    'EGP': 47.7,
    'NGN': 1480.0,
    'KES': 129.5,
    'GHS': 15.0,
    'ARS': 910.0,
    'CLP': 930.0,
    'COP': 4100.0,
    'PEN': 3.75,
    'ILS': 3.70,
    'KWD': 0.31,
    'BHD': 0.38,
    'OMR': 0.38,
    'JOD': 0.71,
  };

  ExchangeRateLocalDataSourceImpl();

  @override
  Future<ExchangeRatesModel?> getCachedRates({
    String baseCurrency = 'USD',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sanitizedBase = baseCurrency.trim().toUpperCase();
      final rawJson = prefs.getString('$_ratesKeyPrefix$sanitizedBase');
      final timestampMs = prefs.getInt('$_updatedAtKeyPrefix$sanitizedBase');

      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        final model = ExchangeRatesModel.fromJson(decoded);

        if (timestampMs != null) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
          final isExpired = DateTime.now().difference(cachedAt) > _cacheTtl;
          if (isExpired) {
            AppLogger.d(
                'Exchange rate cache expired for base $sanitizedBase, returning for offline fallback');
          }
        }
        return model;
      }
    } catch (e) {
      AppLogger.w('Failed to read exchange rate cache: $e');
    }
    return null;
  }

  @override
  Future<void> cacheRates(ExchangeRatesModel rates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sanitizedBase = rates.baseCode.trim().toUpperCase();
      await prefs.setString(
        '$_ratesKeyPrefix$sanitizedBase',
        jsonEncode(rates.toJson()),
      );
      await prefs.setInt(
        '$_updatedAtKeyPrefix$sanitizedBase',
        DateTime.now().millisecondsSinceEpoch,
      );
      AppLogger.d(
          'Cached ${rates.rates.length} exchange rates for $sanitizedBase');
    } catch (e) {
      AppLogger.w('Failed to cache exchange rates: $e');
    }
  }

  @override
  ExchangeRatesModel getFallbackRates({String baseCurrency = 'USD'}) {
    final sanitizedBase = baseCurrency.trim().toUpperCase();
    if (sanitizedBase == 'USD') {
      return ExchangeRatesModel(
        result: 'success',
        baseCode: 'USD',
        rates: Map<String, double>.from(_usdFallbackRates),
      );
    }

    // Compute synthetic cross rates from USD fallback
    final baseToUsdRate = _usdFallbackRates[sanitizedBase] ?? 1.0;
    final Map<String, double> derivedRates = {};
    _usdFallbackRates.forEach((code, usdRate) {
      derivedRates[code] = usdRate / baseToUsdRate;
    });

    return ExchangeRatesModel(
      result: 'success',
      baseCode: sanitizedBase,
      rates: derivedRates,
    );
  }
}
