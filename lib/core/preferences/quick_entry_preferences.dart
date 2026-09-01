import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/enums/database_enums.dart';
import '../utils/app_logger.dart';

/// Local preferences storage for Rapid Expense Capture and Smart Defaults.
@lazySingleton
class QuickEntryPreferences {
  static const String keyLastUsedCategoryId = 'quick_entry_last_category_id';
  static const String keyLastUsedPaymentMethod =
      'quick_entry_last_payment_method';
  static const String keyLastDailyEntryDate =
      'quick_entry_last_daily_entry_date';
  static const String keyLastUsedCurrencyCode =
      'quick_entry_last_currency_code';

  final SharedPreferences? _prefs;

  QuickEntryPreferences([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Retrieve the last recorded category ID for quick entry
  Future<int?> getLastUsedCategoryId() async {
    final prefs = await _getPrefs();
    return prefs.getInt(keyLastUsedCategoryId);
  }

  /// Persist the last recorded category ID
  Future<void> setLastUsedCategoryId(int categoryId) async {
    final prefs = await _getPrefs();
    await prefs.setInt(keyLastUsedCategoryId, categoryId);
    AppLogger.d('QuickEntryPreferences: LastUsedCategoryId set to $categoryId');
  }

  /// Retrieve the last recorded payment method
  Future<PaymentMethod?> getLastUsedPaymentMethod() async {
    final prefs = await _getPrefs();
    final methodName = prefs.getString(keyLastUsedPaymentMethod);
    if (methodName == null) return null;
    try {
      return PaymentMethod.values.firstWhere((e) => e.name == methodName);
    } catch (_) {
      return null;
    }
  }

  /// Persist the last recorded payment method
  Future<void> setLastUsedPaymentMethod(PaymentMethod method) async {
    final prefs = await _getPrefs();
    await prefs.setString(keyLastUsedPaymentMethod, method.name);
    AppLogger.d(
        'QuickEntryPreferences: LastUsedPaymentMethod set to ${method.name}');
  }

  /// Retrieve the last selected date for Daily/Batch entry mode
  Future<DateTime?> getLastDailyEntryDate() async {
    final prefs = await _getPrefs();
    final dateStr = prefs.getString(keyLastDailyEntryDate);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Persist the last selected date for Daily/Batch entry mode
  Future<void> setLastDailyEntryDate(DateTime date) async {
    final prefs = await _getPrefs();
    await prefs.setString(keyLastDailyEntryDate, date.toIso8601String());
    AppLogger.d('QuickEntryPreferences: LastDailyEntryDate set to $date');
  }

  /// Retrieve the last used currency code
  Future<String?> getLastUsedCurrencyCode() async {
    final prefs = await _getPrefs();
    return prefs.getString(keyLastUsedCurrencyCode);
  }

  /// Persist the last used currency code
  Future<void> setLastUsedCurrencyCode(String currencyCode) async {
    final prefs = await _getPrefs();
    await prefs.setString(keyLastUsedCurrencyCode, currencyCode);
    AppLogger.d(
        'QuickEntryPreferences: LastUsedCurrencyCode set to $currencyCode');
  }

  /// Invalidate or synchronize smart defaults when the primary currency changes
  Future<void> handleCurrencyChanged(String newCurrencyCode) async {
    final prefs = await _getPrefs();
    await prefs.setString(keyLastUsedCurrencyCode, newCurrencyCode);
    AppLogger.i(
        'QuickEntryPreferences: Currency changed to $newCurrencyCode. Cached preferences updated.');
  }

  /// Clear all cached quick entry defaults
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(keyLastUsedCategoryId);
    await prefs.remove(keyLastUsedPaymentMethod);
    await prefs.remove(keyLastDailyEntryDate);
    await prefs.remove(keyLastUsedCurrencyCode);
    AppLogger.i('QuickEntryPreferences: All quick entry preferences cleared.');
  }
}
