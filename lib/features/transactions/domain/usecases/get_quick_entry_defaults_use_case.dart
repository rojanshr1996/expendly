import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/preferences/quick_entry_preferences.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/quick_entry_defaults.dart';
import '../repositories/transaction_repository.dart';

class QuickEntryDefaultsParams extends Equatable {
  final int? explicitCategoryId;
  final PaymentMethod? explicitPaymentMethod;
  final DateTime? explicitDate;
  final int? sessionCategoryId;
  final PaymentMethod? sessionPaymentMethod;
  final DateTime? sessionDate;

  const QuickEntryDefaultsParams({
    this.explicitCategoryId,
    this.explicitPaymentMethod,
    this.explicitDate,
    this.sessionCategoryId,
    this.sessionPaymentMethod,
    this.sessionDate,
  });

  @override
  List<Object?> get props => [
        explicitCategoryId,
        explicitPaymentMethod,
        explicitDate,
        sessionCategoryId,
        sessionPaymentMethod,
        sessionDate,
      ];
}

@lazySingleton
class GetQuickEntryDefaultsUseCase
    implements UseCase<QuickEntryDefaults, QuickEntryDefaultsParams> {
  final QuickEntryPreferences quickEntryPreferences;
  final PreferenceService preferenceService;
  final TransactionRepository transactionRepository;
  final AppDatabase appDatabase;

  GetQuickEntryDefaultsUseCase({
    required this.quickEntryPreferences,
    required this.preferenceService,
    required this.transactionRepository,
    required this.appDatabase,
  });

  @override
  Future<QuickEntryDefaults> call(QuickEntryDefaultsParams params) async {
    // 1. Resolve Date
    final resolvedDate =
        params.explicitDate ?? params.sessionDate ?? DateTime.now();

    // 2. Resolve Currency
    final currencyCode = preferenceService.currencyCode;
    final currencySymbol = preferenceService.currencySymbol;

    // Fetch recent transactions if needed for fallback
    final recentList = await transactionRepository.getRecentTransactions(
      limit: 1,
      type: TransactionType.expense,
    );
    final mostRecent = recentList.isNotEmpty ? recentList.first : null;

    // 3. Resolve Payment Method: Explicit > Session > Preferences > Recent > Default (Cash)
    PaymentMethod? resolvedPaymentMethod = params.explicitPaymentMethod ??
        params.sessionPaymentMethod ??
        await quickEntryPreferences.getLastUsedPaymentMethod() ??
        mostRecent?.paymentMethod ??
        PaymentMethod.cash;

    // 4. Resolve Category ID: Explicit > Session > Preferences > Recent > Default (1)
    int resolvedCategoryId = params.explicitCategoryId ??
        params.sessionCategoryId ??
        await quickEntryPreferences.getLastUsedCategoryId() ??
        mostRecent?.categoryId ??
        1;

    // 5. Look up Category metadata
    String? categoryName;
    String? categoryIcon;
    String? categoryColorHex;

    if (mostRecent != null && mostRecent.categoryId == resolvedCategoryId) {
      categoryName = mostRecent.categoryName;
      categoryIcon = mostRecent.categoryIcon;
      categoryColorHex = mostRecent.categoryColorHex;
    } else {
      try {
        final query = appDatabase.select(appDatabase.categories)
          ..where((c) => c.id.equals(resolvedCategoryId));
        final catRow = await query.getSingleOrNull();
        if (catRow != null) {
          categoryName = catRow.name;
          categoryIcon = catRow.icon;
          categoryColorHex = catRow.color;
        } else {
          // If specified categoryId doesn't exist, try getting first available category
          final allCats =
              await appDatabase.select(appDatabase.categories).get();
          if (allCats.isNotEmpty) {
            final firstCat = allCats.first;
            resolvedCategoryId = firstCat.id;
            categoryName = firstCat.name;
            categoryIcon = firstCat.icon;
            categoryColorHex = firstCat.color;
          }
        }
      } catch (_) {
        categoryName = 'Food & Dining';
        categoryIcon = 'restaurant';
        categoryColorHex = '#FF5722';
      }
    }

    return QuickEntryDefaults(
      categoryId: resolvedCategoryId,
      categoryName: categoryName ?? 'Food & Dining',
      categoryIcon: categoryIcon ?? 'restaurant',
      categoryColorHex: categoryColorHex ?? '#FF5722',
      paymentMethod: resolvedPaymentMethod,
      date: resolvedDate,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
    );
  }
}
