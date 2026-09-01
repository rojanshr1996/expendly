import 'package:equatable/equatable.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../domain/entities/category_item.dart';
import '../../domain/entities/quick_entry_defaults.dart';
import '../../domain/entities/transaction_item.dart';

abstract class QuickAddState extends Equatable {
  const QuickAddState();

  @override
  List<Object?> get props => [];
}

class QuickAddInitial extends QuickAddState {}

class QuickAddLoading extends QuickAddState {}

class QuickAddReady extends QuickAddState {
  final String amountText;
  final QuickEntryDefaults defaults;
  final CategoryItem selectedCategory;
  final PaymentMethod selectedPaymentMethod;
  final DateTime selectedDate;
  final List<CategoryItem> availableCategories;
  final List<TransactionItem> recentExpenses; // Will use TransactionItem
  final bool isSaving;
  final String? errorMessage;

  const QuickAddReady({
    this.amountText = '',
    required this.defaults,
    required this.selectedCategory,
    required this.selectedPaymentMethod,
    required this.selectedDate,
    this.availableCategories = const [],
    this.recentExpenses = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  double get amountValue => double.tryParse(amountText) ?? 0.0;
  bool get isValid => amountValue > 0;

  QuickAddReady copyWith({
    String? amountText,
    QuickEntryDefaults? defaults,
    CategoryItem? selectedCategory,
    PaymentMethod? selectedPaymentMethod,
    DateTime? selectedDate,
    List<CategoryItem>? availableCategories,
    List<TransactionItem>? recentExpenses,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QuickAddReady(
      amountText: amountText ?? this.amountText,
      defaults: defaults ?? this.defaults,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedDate: selectedDate ?? this.selectedDate,
      availableCategories: availableCategories ?? this.availableCategories,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        amountText,
        defaults,
        selectedCategory,
        selectedPaymentMethod,
        selectedDate,
        recentExpenses,
        isSaving,
        errorMessage,
      ];
}

class QuickAddSuccess extends QuickAddState {
  final int transactionId;
  final double amount;
  final String currencySymbol;
  final String categoryName;
  final bool addAnother;

  const QuickAddSuccess({
    required this.transactionId,
    required this.amount,
    required this.currencySymbol,
    required this.categoryName,
    this.addAnother = false,
  });

  @override
  List<Object?> get props => [
        transactionId,
        amount,
        currencySymbol,
        categoryName,
        addAnother,
      ];
}
