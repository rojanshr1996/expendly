import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/features/analytics/data/datasources/analytics_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/encryption_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AnalyticsLocalDataSourceImpl dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      PreferenceService.keyCurrencySymbol: '€',
      PreferenceService.keyCurrencyCode: 'EUR',
    });
    final prefService = PreferenceService(FakeSecureStorageService());
    await prefService.init();

    if (getIt.isRegistered<PreferenceService>()) {
      await getIt.unregister<PreferenceService>();
    }
    getIt.registerSingleton<PreferenceService>(prefService);

    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = AnalyticsLocalDataSourceImpl(database);
  });

  tearDown(() async {
    await database.close();
    if (getIt.isRegistered<PreferenceService>()) {
      await getIt.unregister<PreferenceService>();
    }
  });

  group('AnalyticsLocalDataSourceImpl Tests', () {
    test('Trend Report uses primary currency symbol in topCategoryDesc',
        () async {
      // 1. Insert Categories
      final catId = await database.into(database.categories).insert(
            CategoriesCompanion.insert(
              name: 'Dining',
              type: TransactionType.expense,
              icon: 'restaurant',
              color: '#FF5722',
            ),
          );

      // 2. Insert Transactions ($150.00 -> 15000 minor units)
      final now = DateTime.now();
      await database.into(database.transactions).insert(
            TransactionsCompanion.insert(
              amount: 15000,
              type: TransactionType.expense,
              categoryId: catId,
              timestamp: now,
              paymentMethod: const drift.Value(PaymentMethod.cash),
            ),
          );

      // 3. Generate Analytics Report
      final report = await dataSource.getAnalyticsReport(period: 'Monthly');

      expect(report.topCategoryName, 'Dining');
      expect(report.topCategoryDesc, isNotNull);
      // Verify that the narrative uses '€' instead of '$'
      expect(report.topCategoryDesc, contains('€150.00'));
      expect(report.topCategoryDesc, isNot(contains(r'$150.00')));
    });
  });
}
