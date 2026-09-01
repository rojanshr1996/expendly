import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/preferences/quick_entry_preferences.dart';
import '../../../../core/usecase/usecase.dart';

class UpdateQuickEntryDefaultsParams extends Equatable {
  final int categoryId;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String currencyCode;

  const UpdateQuickEntryDefaultsParams({
    required this.categoryId,
    required this.paymentMethod,
    required this.date,
    required this.currencyCode,
  });

  @override
  List<Object?> get props => [categoryId, paymentMethod, date, currencyCode];
}

@lazySingleton
class UpdateQuickEntryDefaultsUseCase
    implements UseCase<void, UpdateQuickEntryDefaultsParams> {
  final QuickEntryPreferences quickEntryPreferences;

  UpdateQuickEntryDefaultsUseCase(this.quickEntryPreferences);

  @override
  Future<void> call(UpdateQuickEntryDefaultsParams params) async {
    await quickEntryPreferences.setLastUsedCategoryId(params.categoryId);
    await quickEntryPreferences.setLastUsedPaymentMethod(params.paymentMethod);
    await quickEntryPreferences.setLastDailyEntryDate(params.date);
    await quickEntryPreferences.setLastUsedCurrencyCode(params.currencyCode);
  }
}
