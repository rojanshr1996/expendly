class ExchangeRatesModel {
  final String result;
  final String baseCode;
  final String? timeLastUpdateUtc;
  final int? timeLastUpdateUnix;
  final Map<String, double> rates;

  ExchangeRatesModel({
    required this.result,
    required this.baseCode,
    this.timeLastUpdateUtc,
    this.timeLastUpdateUnix,
    required this.rates,
  });

  factory ExchangeRatesModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final Map<String, double> parsedRates = {};
    rawRates.forEach((key, value) {
      if (value is num) {
        parsedRates[key.toUpperCase()] = value.toDouble();
      }
    });

    return ExchangeRatesModel(
      result: json['result']?.toString() ?? 'success',
      baseCode: (json['base_code']?.toString() ?? 'USD').toUpperCase(),
      timeLastUpdateUtc: json['time_last_update_utc']?.toString(),
      timeLastUpdateUnix: json['time_last_update_unix'] is int
          ? json['time_last_update_unix'] as int
          : null,
      rates: parsedRates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'base_code': baseCode,
      'time_last_update_utc': timeLastUpdateUtc,
      'time_last_update_unix': timeLastUpdateUnix,
      'rates': rates,
    };
  }
}
