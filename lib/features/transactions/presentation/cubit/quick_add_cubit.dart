import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/events/transaction_events.dart';
import '../../../../core/services/preference_service.dart';
import '../../domain/entities/category_item.dart';
import '../../domain/entities/quick_entry_defaults.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/get_quick_entry_defaults_use_case.dart';
import '../../domain/usecases/update_quick_entry_defaults_use_case.dart';
import 'quick_add_state.dart';

@injectable
class QuickAddCubit extends Cubit<QuickAddState> {
  final GetQuickEntryDefaultsUseCase _getDefaultsUseCase;
  final UpdateQuickEntryDefaultsUseCase _updateDefaultsUseCase;
  final TransactionRepository _transactionRepository;
  final AppDatabase _appDatabase;

  QuickAddCubit(
    this._getDefaultsUseCase,
    this._updateDefaultsUseCase,
    this._transactionRepository,
    this._appDatabase,
  ) : super(QuickAddInitial());

  /// Load Smart Defaults when opening Quick Add
  Future<void> loadDefaults({
    int? explicitCategoryId,
    PaymentMethod? explicitPaymentMethod,
    DateTime? explicitDate,
  }) async {
    emit(QuickAddLoading());
    try {
      final defaults = await _getDefaultsUseCase(QuickEntryDefaultsParams(
        explicitCategoryId: explicitCategoryId,
        explicitPaymentMethod: explicitPaymentMethod,
        explicitDate: explicitDate,
      ));

      // Resolve full category item from Database or fallback
      CategoryItem? categoryItem;
      try {
        final query = _appDatabase.select(_appDatabase.categories)
          ..where((c) => c.id.equals(defaults.categoryId ?? 1));
        final row = await query.getSingleOrNull();
        if (row != null) {
          categoryItem = CategoryItem(
            id: row.id,
            name: row.name,
            icon: row.icon,
            colorHex: row.color,
            type: row.type,
          );
        }
      } catch (_) {}

      final resolvedCategory = categoryItem ??
          CategoryItem(
            id: defaults.categoryId ?? 1,
            name: defaults.categoryName ?? 'Food & Dining',
            icon: defaults.categoryIcon ?? 'restaurant',
            colorHex: defaults.categoryColorHex ?? '#FF5722',
            type: TransactionType.expense,
          );

      // Fetch available expense categories
      List<CategoryItem> availableCategories = [];
      try {
        final rows = await (_appDatabase.select(_appDatabase.categories)
              ..where((c) => c.type.equals(TransactionType.expense.index)))
            .get();
        availableCategories = rows
            .map((r) => CategoryItem(
                  id: r.id,
                  name: r.name,
                  icon: r.icon,
                  colorHex: r.color,
                  type: r.type,
                ))
            .toList();
      } catch (_) {}

      // Fetch recent distinct expenses
      List<TransactionItem> recentExpenses = [];
      try {
        recentExpenses =
            await _transactionRepository.getRecentDistinctExpenses(limit: 6);
      } catch (_) {}

      emit(QuickAddReady(
        amountText: '',
        defaults: defaults,
        selectedCategory: resolvedCategory,
        selectedPaymentMethod: defaults.paymentMethod,
        selectedDate: defaults.date,
        availableCategories: availableCategories,
        recentExpenses: recentExpenses,
      ));
    } catch (e) {
      emit(QuickAddReady(
        amountText: '',
        defaults: QuickEntryDefaults(
          categoryId: 1,
          categoryName: 'Food & Dining',
          categoryIcon: 'restaurant',
          categoryColorHex: '#FF5722',
          paymentMethod: PaymentMethod.cash,
          date: DateTime.now(),
          currencyCode: getIt.isRegistered<PreferenceService>()
              ? getIt<PreferenceService>().currencyCode
              : 'USD',
          currencySymbol: getIt.isRegistered<PreferenceService>()
              ? getIt<PreferenceService>().currencySymbol
              : '\$',
        ),
        selectedCategory: const CategoryItem(
          id: 1,
          name: 'Food & Dining',
          icon: 'restaurant',
          colorHex: '#FF5722',
          type: TransactionType.expense,
        ),
        selectedPaymentMethod: PaymentMethod.cash,
        selectedDate: DateTime.now(),
        errorMessage: 'Failed to load smart defaults: $e',
      ));
    }
  }

  /// Update the current amount string from keypad input
  void setAmount(String amountText) {
    if (state is QuickAddReady) {
      final ready = state as QuickAddReady;
      emit(ready.copyWith(amountText: amountText, clearError: true));
    }
  }

  /// Update the selected category
  void selectCategory(CategoryItem category) {
    if (state is QuickAddReady) {
      final ready = state as QuickAddReady;
      emit(ready.copyWith(selectedCategory: category));
    }
  }

  /// Update the selected payment method
  void selectPaymentMethod(PaymentMethod method) {
    if (state is QuickAddReady) {
      final ready = state as QuickAddReady;
      emit(ready.copyWith(selectedPaymentMethod: method));
    }
  }

  /// Update the transaction date
  void selectDate(DateTime date) {
    if (state is QuickAddReady) {
      final ready = state as QuickAddReady;
      emit(ready.copyWith(selectedDate: date));
    }
  }

  /// Save expense and either close or reset for continuous capture
  Future<void> saveExpense({bool addAnother = false}) async {
    if (state is! QuickAddReady) return;
    final ready = state as QuickAddReady;

    if (!ready.isValid) {
      emit(ready.copyWith(
        errorMessage: 'Please enter a valid amount greater than 0',
      ));
      return;
    }

    emit(ready.copyWith(isSaving: true, clearError: true));

    try {
      final txId = await _transactionRepository.addTransaction(
        type: TransactionType.expense,
        amount: ready.amountValue,
        categoryId: ready.selectedCategory.id,
        timestamp: ready.selectedDate,
        paymentMethod: ready.selectedPaymentMethod,
        currencyCode: ready.defaults.currencyCode,
      );

      // Persist learned smart defaults
      await _updateDefaultsUseCase(UpdateQuickEntryDefaultsParams(
        categoryId: ready.selectedCategory.id,
        paymentMethod: ready.selectedPaymentMethod,
        date: ready.selectedDate,
        currencyCode: ready.defaults.currencyCode,
      ));

      TransactionEvents.notifyUpdated();

      if (addAnother) {
        emit(QuickAddSuccess(
          transactionId: txId,
          amount: ready.amountValue,
          currencySymbol: ready.defaults.currencySymbol,
          categoryName: ready.selectedCategory.name,
          addAnother: true,
        ));

        // Immediately reset amount for next quick entry while retaining category & payment method
        emit(ready.copyWith(
          amountText: '',
          isSaving: false,
          clearError: true,
        ));
      } else {
        emit(QuickAddSuccess(
          transactionId: txId,
          amount: ready.amountValue,
          currencySymbol: ready.defaults.currencySymbol,
          categoryName: ready.selectedCategory.name,
          addAnother: false,
        ));
      }
    } catch (e) {
      emit(ready.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save expense: $e',
      ));
    }
  }

  /// Undo a recently created expense
  Future<void> undoExpense(int transactionId) async {
    try {
      await _transactionRepository.deleteTransaction(transactionId);
      TransactionEvents.notifyUpdated();
    } catch (_) {}
  }

  /// Select a recent expense to duplicate
  void selectRecentExpense(TransactionItem item) {
    if (state is QuickAddReady) {
      final ready = state as QuickAddReady;
      CategoryItem? matchedCategory;
      try {
        matchedCategory = ready.availableCategories.firstWhere(
          (c) => c.id == item.categoryId,
        );
      } catch (_) {
        matchedCategory = CategoryItem(
          id: item.categoryId,
          name: item.categoryName,
          icon: item.categoryIcon,
          colorHex: item.categoryColorHex,
          type: TransactionType.expense,
        );
      }

      emit(ready.copyWith(
        amountText: item.amount.toStringAsFixed(
            item.amount.truncateToDouble() == item.amount ? 0 : 2),
        selectedCategory: matchedCategory,
        selectedPaymentMethod: item.paymentMethod,
        clearError: true,
      ));
    }
  }
}
