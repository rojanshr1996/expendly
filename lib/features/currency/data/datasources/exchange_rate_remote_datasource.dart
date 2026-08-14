import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/exchange_rates_model.dart';

abstract class ExchangeRateRemoteDataSource {
  Future<ExchangeRatesModel> getLatestRates({String baseCurrency = 'USD'});
}

@LazySingleton(as: ExchangeRateRemoteDataSource)
class ExchangeRateRemoteDataSourceImpl implements ExchangeRateRemoteDataSource {
  final DioClient _dioClient;

  ExchangeRateRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ExchangeRatesModel> getLatestRates({
    String baseCurrency = 'USD',
  }) async {
    final sanitizedBase = baseCurrency.trim().toUpperCase();
    final url = 'https://open.er-api.com/v6/latest/$sanitizedBase';

    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        final model = ExchangeRatesModel.fromJson(response.data!);
        if (model.result == 'success' && model.rates.isNotEmpty) {
          return model;
        }
      }
      throw DioException(
        requestOptions: RequestOptions(path: url),
        error:
            'Invalid response from exchange rate API: ${response.statusCode}',
      );
    } catch (e, stack) {
      AppLogger.e('Failed to fetch exchange rates for base $sanitizedBase: $e',
          e, stack);
      rethrow;
    }
  }
}
