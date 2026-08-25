import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/preferences/quick_entry_preferences.dart';
import 'package:expendly/features/transactions/domain/usecases/update_quick_entry_defaults_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuickEntryPreferences quickEntryPreferences;
  late UpdateQuickEntryDefaultsUseCase useCase;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    quickEntryPreferences = QuickEntryPreferences();
    useCase = UpdateQuickEntryDefaultsUseCase(quickEntryPreferences);
  });

  group('UpdateQuickEntryDefaultsUseCase Tests', () {
    test('Persists all updated defaults into QuickEntryPreferences', () async {
      final date = DateTime(2026, 8, 24, 15, 30);
      await useCase(UpdateQuickEntryDefaultsParams(
        categoryId: 4,
        paymentMethod: PaymentMethod.card,
        date: date,
        currencyCode: 'NPR',
      ));

      expect(await quickEntryPreferences.getLastUsedCategoryId(), equals(4));
      expect(await quickEntryPreferences.getLastUsedPaymentMethod(),
          equals(PaymentMethod.card));
      expect(await quickEntryPreferences.getLastDailyEntryDate(), equals(date));
      expect(await quickEntryPreferences.getLastUsedCurrencyCode(),
          equals('NPR'));
    });
  });
}
