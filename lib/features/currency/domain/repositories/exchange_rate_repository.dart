abstract class ExchangeRateRepository {
  /// Fetches exchange rate multiplier to convert 1 unit of [from] to [to].
  /// Example: getExchangeRate(from: 'USD', to: 'NPR') => 134.50
  Future<double> getExchangeRate({
    required String from,
    required String to,
  });

  /// Converts a specific monetary [amount] from [from] currency into [to] currency.
  Future<double> convertAmount({
    required double amount,
    required String from,
    required String to,
  });

  /// Fetches a map of all available exchange rates against the given [base] currency.
  Future<Map<String, double>> getExchangeRates({String base = 'USD'});

  /// Atomically converts all stored transactions, budgets, and recurring transactions
  /// from [fromCurrency] to [toCurrency] in the SQLite database and returns the rate used.
  Future<double> convertAllDataToNewCurrency({
    required String fromCurrency,
    required String toCurrency,
  });
}
