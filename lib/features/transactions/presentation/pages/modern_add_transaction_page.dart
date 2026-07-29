import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/constants/padding_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/category_picker_sheet.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../domain/entities/category_item.dart';
import '../../domain/entities/transaction_item.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';

@RoutePage()
class ModernAddTransactionPage extends StatefulWidget {
  final TransactionItem? initialTransaction;

  const ModernAddTransactionPage({super.key, this.initialTransaction});

  @override
  State<ModernAddTransactionPage> createState() => _ModernAddTransactionPageState();
}

class _ModernAddTransactionPageState extends State<ModernAddTransactionPage> {
  final ValueNotifier<TransactionType> _typeNotifier = ValueNotifier<TransactionType>(TransactionType.expense);
  final ValueNotifier<String> _amountStringNotifier = ValueNotifier<String>('0');
  final ValueNotifier<CategoryItem?> _selectedCategoryNotifier = ValueNotifier<CategoryItem?>(null);
  final ValueNotifier<CategoryItem?> _destinationCategoryNotifier = ValueNotifier<CategoryItem?>(null);
  final ValueNotifier<DateTime> _dateNotifier = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<PaymentMethod> _paymentMethodNotifier = ValueNotifier<PaymentMethod>(PaymentMethod.card);
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  List<CategoryItem> _expenseCategories = [];
  List<CategoryItem> _incomeCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final db = getIt<AppDatabase>();
      final rows = await db.select(db.categories).get();

      final expense = <CategoryItem>[];
      final income = <CategoryItem>[];

      for (final r in rows) {
        final item = CategoryItem(
          id: r.id,
          name: r.name,
          icon: r.icon,
          colorHex: r.color,
          type: r.type,
        );
        if (r.type == TransactionType.expense) {
          expense.add(item);
        } else {
          income.add(item);
        }
      }

      // setState() ensures the widget rebuilds after the async load so categories
      // are visible immediately without requiring a tab switch.
      if (mounted) {
        setState(() {
          _expenseCategories = expense;
          _incomeCategories = income;
        });

        if (widget.initialTransaction != null) {
          final tx = widget.initialTransaction!;
          _typeNotifier.value = tx.type;
          _amountStringNotifier.value = tx.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
          _dateNotifier.value = tx.timestamp;
          if (tx.paymentMethod != null) {
            _paymentMethodNotifier.value = tx.paymentMethod!;
          }
          if (tx.note != null) {
            _noteController.text = tx.note!;
          }

          final allCats = [...expense, ...income];
          CategoryItem? foundCat;
          try {
            foundCat = allCats.firstWhere((c) => c.id == tx.categoryId);
          } catch (_) {
            foundCat = CategoryItem(
              id: tx.categoryId,
              name: tx.categoryName,
              icon: tx.categoryIcon,
              colorHex: tx.categoryColorHex,
              type: tx.type,
            );
          }
          _selectedCategoryNotifier.value = foundCat;
        } else if (_expenseCategories.isNotEmpty) {
          _selectedCategoryNotifier.value = _expenseCategories.first;
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _typeNotifier.dispose();
    _amountStringNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    _destinationCategoryNotifier.dispose();
    _dateNotifier.dispose();
    _paymentMethodNotifier.dispose();
    _noteController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String value) {
    final current = _amountStringNotifier.value;
    if (value == '<') {
      if (current.length > 1) {
        _amountStringNotifier.value = current.substring(0, current.length - 1);
      } else {
        _amountStringNotifier.value = '0';
      }
    } else if (value == '.') {
      if (!current.contains('.')) {
        _amountStringNotifier.value = '$current.';
      }
    } else {
      if (current == '0') {
        _amountStringNotifier.value = value;
      } else {
        // Limit to 2 decimal places if dot exists
        if (current.contains('.')) {
          final parts = current.split('.');
          if (parts.length > 1 && parts[1].length >= 2) {
            return;
          }
        }
        _amountStringNotifier.value = current + value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return BlocProvider.value(
      value: getIt<TransactionCubit>(),
      child: BlocListener<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionActionSuccess) {
            // Refresh dashboard data
            try {
              getIt<DashboardCubit>().loadDashboardData();
            } catch (_) {}
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.secondary,
              ),
            );
            context.router.maybePop(true);
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
                onPressed: () => context.router.maybePop(),
              ),
              title: Text(
                widget.initialTransaction != null
                    ? 'Edit Transaction'
                    : context.l10n.logTransaction,
                style: (textTheme.titleLarge ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  verticalMarginMedium,

                  // Segmented Type Selector (Expense / Income / Transfer)
                  ValueListenableBuilder<TransactionType>(
                    valueListenable: _typeNotifier,
                    builder: (context, type, _) {
                      return Container(
                        margin: horizontalPaddingLarge,
                        padding: allXXSmall,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            // Expense Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _typeNotifier.value = TransactionType.expense;
                                  if (_expenseCategories.isNotEmpty) {
                                    _selectedCategoryNotifier.value = _expenseCategories.first;
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: horizontalPaddingTiny,
                                  padding: verticalPaddingSmall,
                                  decoration: BoxDecoration(
                                    color: type == TransactionType.expense
                                        ? colorScheme.error.withAlpha((0.2 * 255).round())
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: type == TransactionType.expense
                                        ? Border.all(color: colorScheme.error, width: 1.5)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      context.l10n.expense,
                                      style: customTypography.bodyLargeBold.copyWith(
                                        color:
                                            type == TransactionType.expense ? colorScheme.error : colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Income Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _typeNotifier.value = TransactionType.income;
                                  if (_incomeCategories.isNotEmpty) {
                                    _selectedCategoryNotifier.value = _incomeCategories.first;
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: horizontalPaddingTiny,
                                  padding: verticalPaddingSmall,
                                  decoration: BoxDecoration(
                                    color: type == TransactionType.income
                                        ? colorScheme.primary.withAlpha((0.2 * 255).round())
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: type == TransactionType.income
                                        ? Border.all(color: colorScheme.primary, width: 1.5)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      context.l10n.income,
                                      style: customTypography.bodyLargeBold.copyWith(
                                        color:
                                            type == TransactionType.income ? colorScheme.primary : colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Transfer Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _typeNotifier.value = TransactionType.transfer;
                                  if (_expenseCategories.isNotEmpty) {
                                    _selectedCategoryNotifier.value = _expenseCategories.first;
                                  }
                                  if (_incomeCategories.isNotEmpty) {
                                    _destinationCategoryNotifier.value = _incomeCategories.first;
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: horizontalPaddingTiny,
                                  padding: verticalPaddingSmall,
                                  decoration: BoxDecoration(
                                    color: type == TransactionType.transfer
                                        ? colorScheme.secondary.withAlpha((0.2 * 255).round())
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: type == TransactionType.transfer
                                        ? Border.all(color: colorScheme.secondary, width: 1.5)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      context.l10n.transfer,
                                      style: customTypography.bodyLargeBold.copyWith(
                                        color: type == TransactionType.transfer
                                            ? colorScheme.secondary
                                            : colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  verticalMarginLarge,

                  // Amount Display with Dynamic Signup Currency Symbol
                  ValueListenableBuilder<String>(
                    valueListenable: _amountStringNotifier,
                    builder: (context, amountStr, _) {
                      return ValueListenableBuilder<TransactionType>(
                        valueListenable: _typeNotifier,
                        builder: (context, type, _) {
                          final currencySymbol = getIt<PreferenceService>().currencySymbol;
                          final color = type == TransactionType.income
                              ? colorScheme.primary
                              : type == TransactionType.transfer
                                  ? colorScheme.secondary
                                  : colorScheme.error;

                          return Column(
                            children: [
                              Text(
                                context.l10n.amountLabel,
                                style: customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              verticalMarginXSmall,
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$currencySymbol $amountStr',
                                  style: customTypography.headlineLargeMonoBold.copyWith(
                                    color: color,
                                    fontSize: 42.sp,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  verticalMarginLarge,

                  // Category / Transfer Account Selection Fields
                  ValueListenableBuilder<TransactionType>(
                    valueListenable: _typeNotifier,
                    builder: (context, currentType, _) {
                      if (currentType == TransactionType.transfer) {
                        return Padding(
                          padding: horizontalPaddingLarge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // From Account / Category
                              Text(
                                context.l10n.fromAccount,
                                style: customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              verticalMarginXSmall,
                              ValueListenableBuilder<CategoryItem?>(
                                valueListenable: _selectedCategoryNotifier,
                                builder: (context, fromCat, _) {
                                  final name = fromCat?.name ?? 'Source';
                                  final catColor = _parseColor(fromCat?.colorHex ?? '#57F1DB', colorScheme.primary);
                                  final iconData = _getIconData(fromCat?.icon ?? 'category');

                                  return InkWell(
                                    onTap: () async {
                                      final picked = await CategoryPickerSheet.show(
                                        context: context,
                                        categories:
                                            _expenseCategories.isNotEmpty ? _expenseCategories : _incomeCategories,
                                        selectedCategory: fromCat,
                                        initialType: TransactionType.expense,
                                      );
                                      if (picked != null) {
                                        _selectedCategoryNotifier.value = picked;
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: Container(
                                      height: 52.h,
                                      padding: horizontalPaddingMedium,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(color: colorScheme.outlineVariant),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(iconData, color: catColor, size: 20.sp),
                                              horizontalMarginSmall,
                                              Text(
                                                name,
                                                style: customTypography.bodyLargeBold
                                                    .copyWith(color: colorScheme.onSurface),
                                              ),
                                            ],
                                          ),
                                          Icon(Icons.unfold_more_rounded, color: colorScheme.outline, size: 20.sp),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              verticalMarginMedium,

                              // To Account / Category
                              Text(
                                context.l10n.toAccount,
                                style: customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              verticalMarginXSmall,
                              ValueListenableBuilder<CategoryItem?>(
                                valueListenable: _destinationCategoryNotifier,
                                builder: (context, toCat, _) {
                                  final name = toCat?.name ?? 'Destination';
                                  final catColor = _parseColor(toCat?.colorHex ?? '#34D399', colorScheme.secondary);
                                  final iconData = _getIconData(toCat?.icon ?? 'category');

                                  return InkWell(
                                    onTap: () async {
                                      final picked = await CategoryPickerSheet.show(
                                        context: context,
                                        categories:
                                            _incomeCategories.isNotEmpty ? _incomeCategories : _expenseCategories,
                                        selectedCategory: toCat,
                                        initialType: TransactionType.income,
                                      );
                                      if (picked != null) {
                                        _destinationCategoryNotifier.value = picked;
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: Container(
                                      height: 52.h,
                                      padding: horizontalPaddingMedium,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(color: colorScheme.outlineVariant),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(iconData, color: catColor, size: 20.sp),
                                              horizontalMarginSmall,
                                              Text(
                                                name,
                                                style: customTypography.bodyLargeBold
                                                    .copyWith(color: colorScheme.onSurface),
                                              ),
                                            ],
                                          ),
                                          Icon(Icons.unfold_more_rounded, color: colorScheme.outline, size: 20.sp),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              verticalMarginMedium,

                              // Transfer Fee Field
                              Text(
                                context.l10n.transferFee,
                                style: customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              verticalMarginXSmall,
                              AppTextField(
                                controller: _feeController,
                                hintText: 'e.g. 5.00',
                                isAmount: true,
                                fillColor: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ],
                          ),
                        );
                      }

                      // Expense or Income Category Selector
                      final categories =
                          currentType == TransactionType.expense ? _expenseCategories : _incomeCategories;

                      return Padding(
                        padding: horizontalPaddingLarge,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.categoryLabel,
                              style: customTypography.labelMediumMono.copyWith(
                                color: colorScheme.outline,
                                letterSpacing: 1.2,
                              ),
                            ),
                            verticalMarginXSmall,
                            ValueListenableBuilder<CategoryItem?>(
                              valueListenable: _selectedCategoryNotifier,
                              builder: (context, selectedCat, _) {
                                final catName = selectedCat?.name ?? context.l10n.categoryLabel;
                                final catColor = _parseColor(selectedCat?.colorHex ?? '#57F1DB', colorScheme.primary);
                                final iconData = _getIconData(selectedCat?.icon ?? 'category');

                                return InkWell(
                                  onTap: () async {
                                    final picked = await CategoryPickerSheet.show(
                                      context: context,
                                      categories: categories,
                                      selectedCategory: selectedCat,
                                      initialType: currentType,
                                    );
                                    if (picked != null) {
                                      _selectedCategoryNotifier.value = picked;
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    height: 56.h,
                                    padding: horizontalPaddingMedium,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: allXSmall,
                                              decoration: BoxDecoration(
                                                color: catColor.withAlpha((0.2 * 255).round()),
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                iconData,
                                                color: catColor,
                                                size: 20.sp,
                                              ),
                                            ),
                                            horizontalMarginSmall,
                                            Text(
                                              catName,
                                              style: customTypography.bodyLargeBold.copyWith(
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.unfold_more_rounded,
                                          color: colorScheme.outline,
                                          size: 22.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Payment Method Selection (Expense & Transfer)
                  ValueListenableBuilder<TransactionType>(
                    valueListenable: _typeNotifier,
                    builder: (context, currentType, _) {
                      if (currentType != TransactionType.expense && currentType != TransactionType.transfer) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: horizontalPaddingLarge,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            verticalMarginMedium,
                            Text(
                              context.l10n.paymentMethodLabel,
                              style: customTypography.labelMediumMono.copyWith(
                                color: colorScheme.outline,
                                letterSpacing: 1.2,
                              ),
                            ),
                            verticalMarginXSmall,
                            ValueListenableBuilder<PaymentMethod>(
                              valueListenable: _paymentMethodNotifier,
                              builder: (context, selectedMethod, _) {
                                return Row(
                                  children: [
                                    _buildPaymentMethodOption(
                                      context,
                                      method: PaymentMethod.card,
                                      label: context.l10n.paymentCard,
                                      icon: Icons.credit_card_rounded,
                                      isSelected: selectedMethod == PaymentMethod.card,
                                    ),
                                    horizontalMarginSmall,
                                    _buildPaymentMethodOption(
                                      context,
                                      method: PaymentMethod.cash,
                                      label: context.l10n.paymentCash,
                                      icon: Icons.payments_rounded,
                                      isSelected: selectedMethod == PaymentMethod.cash,
                                    ),
                                    horizontalMarginSmall,
                                    _buildPaymentMethodOption(
                                      context,
                                      method: PaymentMethod.account,
                                      label: context.l10n.paymentAccount,
                                      icon: Icons.account_balance_rounded,
                                      isSelected: selectedMethod == PaymentMethod.account,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  verticalMargin20,

                  // Note Input & Date Picker (Consistent height & 16px radius)
                  Padding(
                    padding: horizontalPaddingLarge,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Date Selector Button matching AppTextField height
                          ValueListenableBuilder<DateTime>(
                            valueListenable: _dateNotifier,
                            builder: (context, selectedDate, _) {
                              return InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    _dateNotifier.value = picked;
                                  }
                                },
                                borderRadius: BorderRadius.circular(16.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 18.sp,
                                        color: colorScheme.primary,
                                      ),
                                      horizontalMarginXSmall,
                                      Text(
                                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                        style: customTypography.bodyMedium.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          horizontalMarginSmall,

                          // Note Field using custom AppTextField component
                          Expanded(
                            child: AppTextField(
                              controller: _noteController,
                              hintText: 'Add note (optional)...',
                              prefixIcon: Icon(
                                Icons.sticky_note_2_outlined,
                                color: colorScheme.outline,
                                size: 18.sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                              fillColor: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  verticalMarginLarge,
                ],
              ),
            ),
            bottomNavigationBar: Builder(
              builder: (context) {
                final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom Numeric Keypad (hidden when system keyboard is active)
                    if (!isKeyboardOpen)
                      Container(
                        color: colorScheme.surfaceContainerLow,
                        padding: verticalPaddingSmall,
                        child: Column(
                          children: [
                            _buildKeypadRow(['1', '2', '3']),
                            verticalMarginXSmall,
                            _buildKeypadRow(['4', '5', '6']),
                            verticalMarginXSmall,
                            _buildKeypadRow(['7', '8', '9']),
                            verticalMarginXSmall,
                            _buildKeypadRow(['.', '0', '<']),
                          ],
                        ),
                      ),
                    // Save Button
                    Container(
                      color: colorScheme.surfaceContainerLow,
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        top: 12.h,
                        bottom: 12.h + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      child: Builder(
                        builder: (blocContext) {
                          return ElevatedButton(
                            onPressed: () {
                              final amount = double.tryParse(_amountStringNotifier.value) ?? 0.0;
                              if (amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.l10n.enterAmountError),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                                return;
                              }

                              final selectedCat = _selectedCategoryNotifier.value;
                              if (selectedCat == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.l10n.selectCategoryError),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                                return;
                              }

                              String? noteText;
                              final baseNote = _noteController.text.trim();
                              final fee = double.tryParse(_feeController.text.trim());

                              if (_typeNotifier.value == TransactionType.transfer) {
                                final destCat = _destinationCategoryNotifier.value;
                                final feePart = (fee != null && fee > 0)
                                    ? ' (Fee: ${getIt<PreferenceService>().currencySymbol}$fee)'
                                    : '';
                                final transferDesc =
                                    'Transfer: ${selectedCat.name} → ${destCat?.name ?? "Destination"}$feePart';
                                noteText = baseNote.isNotEmpty ? '$transferDesc | $baseNote' : transferDesc;
                              } else {
                                noteText = baseNote.isNotEmpty ? baseNote : null;
                              }

                              final PaymentMethod? paymentMethod = (_typeNotifier.value == TransactionType.expense ||
                                      _typeNotifier.value == TransactionType.transfer)
                                  ? _paymentMethodNotifier.value
                                  : null;

                              if (widget.initialTransaction != null) {
                                blocContext.read<TransactionCubit>().updateTransaction(
                                      id: widget.initialTransaction!.id,
                                      type: _typeNotifier.value,
                                      amount: amount,
                                      categoryId: selectedCat.id,
                                      timestamp: _dateNotifier.value,
                                      note: noteText,
                                      paymentMethod: paymentMethod,
                                    );
                              } else {
                                blocContext.read<TransactionCubit>().addTransaction(
                                      type: _typeNotifier.value,
                                      amount: amount,
                                      categoryId: selectedCat.id,
                                      timestamp: _dateNotifier.value,
                                      note: noteText,
                                      paymentMethod: paymentMethod,
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.black,
                              minimumSize: Size(double.infinity, 52.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              widget.initialTransaction != null
                                  ? 'Update Transaction'
                                  : context.l10n.saveTransaction,
                              style: customTypography.bodyLargeBold.copyWith(
                                color: Colors.black,
                                fontSize: 18.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return InkWell(
          onTap: () => _onKeypadTap(key),
          borderRadius: BorderRadius.circular(32.r),
          child: Container(
            width: 72.w,
            height: 48.h,
            alignment: Alignment.center,
            child: key == '<'
                ? Icon(Icons.backspace_outlined, color: colorScheme.onSurface, size: 22.sp)
                : Text(
                    key,
                    style: context.customTypography.headlineMediumMonoBold.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 22.sp,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String hex, Color fallback) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'storefront':
        return Icons.storefront_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildPaymentMethodOption(
    BuildContext context, {
    required PaymentMethod method,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final activeColor = colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: () {
          _paymentMethodNotifier.value = method;
        },
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withAlpha((0.15 * 255).round()) : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? activeColor : colorScheme.outlineVariant,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected ? activeColor : colorScheme.outline,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: customTypography.bodyMedium.copyWith(
                    color: isSelected ? colorScheme.onSurface : colorScheme.outline,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
