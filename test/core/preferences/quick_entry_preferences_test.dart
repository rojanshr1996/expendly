import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/preferences/quick_entry_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuickEntryPreferences quickEntryPreferences;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    quickEntryPreferences = QuickEntryPreferences();
  });

  group('QuickEntryPreferences Tests', () {
    test('Stores and retrieves last used category ID correctly', () async {
      expect(await quickEntryPreferences.getLastUsedCategoryId(), isNull);

      await quickEntryPreferences.setLastUsedCategoryId(3);
      expect(await quickEntryPreferences.getLastUsedCategoryId(), equals(3));
    });

    test('Stores and retrieves last used PaymentMethod correctly', () async {
      expect(await quickEntryPreferences.getLastUsedPaymentMethod(), isNull);

      await quickEntryPreferences.setLastUsedPaymentMethod(PaymentMethod.card);
      expect(await quickEntryPreferences.getLastUsedPaymentMethod(),
          equals(PaymentMethod.card));

      await quickEntryPreferences.setLastUsedPaymentMethod(PaymentMethod.cash);
      expect(await quickEntryPreferences.getLastUsedPaymentMethod(),
          equals(PaymentMethod.cash));
    });

    test('Stores and retrieves last daily entry date correctly', () async {
      expect(await quickEntryPreferences.getLastDailyEntryDate(), isNull);

      final date = DateTime(2026, 8, 20);
      await quickEntryPreferences.setLastDailyEntryDate(date);
      expect(await quickEntryPreferences.getLastDailyEntryDate(), equals(date));
    });

    test('Stores and retrieves last used currency code correctly', () async {
      expect(await quickEntryPreferences.getLastUsedCurrencyCode(), isNull);

      await quickEntryPreferences.setLastUsedCurrencyCode('EUR');
      expect(await quickEntryPreferences.getLastUsedCurrencyCode(),
          equals('EUR'));
    });

    test('handleCurrencyChanged updates cached currency code', () async {
      await quickEntryPreferences.setLastUsedCurrencyCode('USD');
      expect(await quickEntryPreferences.getLastUsedCurrencyCode(),
          equals('USD'));

      await quickEntryPreferences.handleCurrencyChanged('NPR');
      expect(await quickEntryPreferences.getLastUsedCurrencyCode(),
          equals('NPR'));
    });

    test('clearAll removes all quick entry preferences', () async {
      await quickEntryPreferences.setLastUsedCategoryId(5);
      await quickEntryPreferences
          .setLastUsedPaymentMethod(PaymentMethod.account);
      await quickEntryPreferences
          .setLastDailyEntryDate(DateTime(2026, 8, 24));
      await quickEntryPreferences.setLastUsedCurrencyCode('GBP');

      await quickEntryPreferences.clearAll();

      expect(await quickEntryPreferences.getLastUsedCategoryId(), isNull);
      expect(await quickEntryPreferences.getLastUsedPaymentMethod(), isNull);
      expect(await quickEntryPreferences.getLastDailyEntryDate(), isNull);
      expect(await quickEntryPreferences.getLastUsedCurrencyCode(), isNull);
    });
  });
}
