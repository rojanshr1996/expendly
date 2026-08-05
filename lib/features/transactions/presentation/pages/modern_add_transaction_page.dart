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
  State<ModernAddTransactionPage> createState() =>
      _ModernAddTransactionPageState();
}

class _ModernAddTransactionPageState extends State<ModernAddTransactionPage> {
  final ValueNotifier<TransactionType> _typeNotifier =
      ValueNotifier<TransactionType>(TransactionType.expense);
  final ValueNotifier<String> _amountStringNotifier =
      ValueNotifier<String>('0');
  final ValueNotifier<CategoryItem?> _selectedCategoryNotifier =
      ValueNotifier<CategoryItem?>(null);
  final ValueNotifier<PaymentMethod> _destinationPaymentMethodNotifier =
      ValueNotifier<PaymentMethod>(PaymentMethod.account);
  final ValueNotifier<DateTime> _dateNotifier =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<PaymentMethod> _paymentMethodNotifier =
      ValueNotifier<PaymentMethod>(PaymentMethod.cash);
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
          _amountStringNotifier.value =
              tx.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
          _dateNotifier.value = tx.timestamp;
          if (tx.paymentMethod != null) {
            _paymentMethodNotifier.value = tx.paymentMethod!;
          }

          final allCats = [...expense, ...income];
          CategoryItem? foundCat;
          try {
            foundCat = allCats.firstWhere((c) => c.id == tx.categoryId);
          } catch (_) {
            if (allCats.isNotEmpty) {
              foundCat = allCats.first;
            } else {
              foundCat = CategoryItem(
                id: tx.categoryId > 0 ? tx.categoryId : 1,
                name: tx.categoryName,
                icon: tx.categoryIcon,
                colorHex: tx.categoryColorHex,
                type: tx.type,
              );
            }
          }
          if (foundCat.id <= 0 && allCats.isNotEmpty) {
            foundCat = allCats.first;
          }
          _selectedCategoryNotifier.value = foundCat;

          if (tx.type == TransactionType.transfer && tx.note != null) {
            _populateTransferFieldsFromNote(tx.note!);
          } else if (tx.note != null) {
            _noteController.text = tx.note!;
          }
        } else if (_expenseCategories.isNotEmpty) {
          _selectedCategoryNotifier.value = _expenseCategories.first;
        }
      }
    } catch (_) {}
  }

  void _populateTransferFieldsFromNote(String note) {
    final feeRegExp = RegExp(r'\(Fee:\s*[^0-9]*([0-9]+(?:\.[0-9]+)?)\)');
    final feeMatch = feeRegExp.firstMatch(note);
    if (feeMatch != null && feeMatch.groupCount >= 1) {
      final feeVal = double.tryParse(feeMatch.group(1)!);
      if (feeVal != null && feeVal > 0) {
        _feeController.text =
            feeVal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      }
    }

    final transferRegExp = RegExp(r'Transfer:\s*([^(|→]+)\s*→\s*([^(|]+)');
    final transferMatch = transferRegExp.firstMatch(note);
    if (transferMatch != null && transferMatch.groupCount >= 2) {
      final fromStr = transferMatch.group(1)!.trim();
      final toStr = transferMatch.group(2)!.trim();
      _paymentMethodNotifier.value =
          _matchPaymentMethod(fromStr, fallback: PaymentMethod.cash);
      _destinationPaymentMethodNotifier.value =
          _matchPaymentMethod(toStr, fallback: PaymentMethod.account);
    }

    if (note.contains('|')) {
      _noteController.text = note.split('|').last.trim();
    } else if (note.startsWith('Transfer:')) {
      _noteController.text = '';
    } else {
      _noteController.text = note;
    }
  }

  PaymentMethod _matchPaymentMethod(String str,
      {required PaymentMethod fallback}) {
    final lower = str.toLowerCase();
    if (lower.contains('card') || lower.contains('credit'))
      return PaymentMethod.card;
    if (lower.contains('cash') || lower.contains('wallet'))
      return PaymentMethod.cash;
    if (lower.contains('account') || lower.contains('bank'))
      return PaymentMethod.account;
    return fallback;
  }

  String _formatPaymentMethodName(BuildContext context, PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return context.l10n.paymentCard;
      case PaymentMethod.cash:
        return context.l10n.paymentCash;
      case PaymentMethod.account:
        return context.l10n.paymentAccount;
    }
  }

  @override
  void dispose() {
    _typeNotifier.dispose();
    _amountStringNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    _destinationPaymentMethodNotifier.dispose();
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
                      final customColors = context.customColors;
                      final tabs = [
                        {
                          'type': TransactionType.expense,
                          'label': context.l10n.expense,
                          'activeColor': customColors.semanticRed,
                          'onActiveColor': Colors.white,
                        },
                        {
                          'type': TransactionType.income,
                          'label': context.l10n.income,
                          'activeColor': customColors.semanticGreen,
                          'onActiveColor': Colors.white,
                        },
                        {
                          'type': TransactionType.transfer,
                          'label': context.l10n.transfer,
                          'activeColor': customColors.semanticBlue,
                          'onActiveColor': Colors.white,
                        },
                      ];

                      return Container(
                        margin: horizontalPaddingLarge,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Row(
                          children: tabs.map((t) {
                            final tabType = t['type'] as TransactionType;
                            final isSelected = type == tabType;
                            final activeColor = t['activeColor'] as Color;
                            final onActiveColor = t['onActiveColor'] as Color;

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: GestureDetector(
                                  onTap: () {
                                    _typeNotifier.value = tabType;
                                    if (tabType == TransactionType.expense) {
                                      if (_expenseCategories.isNotEmpty) {
                                        _selectedCategoryNotifier.value =
                                            _expenseCategories.first;
                                      }
                                    } else if (tabType ==
                                        TransactionType.income) {
                                      if (_incomeCategories.isNotEmpty) {
                                        _selectedCategoryNotifier.value =
                                            _incomeCategories.first;
                                      }
                                    } else if (tabType ==
                                        TransactionType.transfer) {
                                      _paymentMethodNotifier.value =
                                          PaymentMethod.cash;
                                      _destinationPaymentMethodNotifier.value =
                                          PaymentMethod.account;
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? activeColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      t['label'] as String,
                                      textAlign: TextAlign.center,
                                      style: customTypography.labelMediumMono
                                          .copyWith(
                                        color: isSelected
                                            ? onActiveColor
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
                          final currencySymbol =
                              getIt<PreferenceService>().currencySymbol;
                          final customColors = context.customColors;
                          final color = type == TransactionType.income
                              ? customColors.semanticGreen
                              : type == TransactionType.transfer
                                  ? customColors.semanticBlue
                                  : customColors.semanticRed;

                          return Column(
                            children: [
                              Text(
                                context.l10n.amountLabel,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.5,
                                  fontSize: 11.sp,
                                ),
                              ),
                              verticalMarginXSmall,
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$currencySymbol $amountStr',
                                  style: customTypography.headlineLargeMonoBold
                                      .copyWith(
                                    color: color,
                                    fontSize: 34.sp,
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
                              // From Payment Method (Source)
                              Text(
                                context.l10n.fromAccount,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.2,
                                  fontSize: 11.sp,
                                ),
                              ),
                              verticalMarginXSmall,
                              ValueListenableBuilder<PaymentMethod>(
                                valueListenable: _paymentMethodNotifier,
                                builder: (context, fromMethod, _) {
                                  return Row(
                                    children: [
                                      _buildPaymentMethodOption(
                                        context,
                                        method: PaymentMethod.cash,
                                        label: context.l10n.paymentCash,
                                        icon: Icons.payments_rounded,
                                        isSelected:
                                            fromMethod == PaymentMethod.cash,
                                        onSelect: (m) =>
                                            _paymentMethodNotifier.value = m,
                                      ),
                                      horizontalMarginXSmall,
                                      _buildPaymentMethodOption(
                                        context,
                                        method: PaymentMethod.account,
                                        label: context.l10n.paymentAccount,
                                        icon: Icons.account_balance_rounded,
                                        isSelected:
                                            fromMethod == PaymentMethod.account,
                                        onSelect: (m) =>
                                            _paymentMethodNotifier.value = m,
                                      ),
                                      horizontalMarginXSmall,
                                      _buildPaymentMethodOption(
                                        context,
                                        method: PaymentMethod.card,
                                        label: context.l10n.paymentCard,
                                        icon: Icons.credit_card_rounded,
                                        isSelected:
                                            fromMethod == PaymentMethod.card,
                                        onSelect: (m) =>
                                            _paymentMethodNotifier.value = m,
                                      ),
                                    ],
                                  );
                                },
                              ),

                              verticalMarginMedium,

                              // To Payment Method (Destination)
                              Text(
                                context.l10n.toAccount,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.2,
                                  fontSize: 11.sp,
                                ),
                              ),
                              verticalMarginXSmall,
                              ValueListenableBuilder<PaymentMethod>(
                                valueListenable:
                                    _destinationPaymentMethodNotifier,
                                builder: (context, toMethod, _) {
                                  return Row(
                                    children: [
                                      _buildPaymentMethodOption(
                                        context,
                                        method: PaymentMethod.cash,
                                        label: context.l10n.paymentCash,
                                        icon: Icons.payments_rounded,
                                        isSelected:
                                            toMethod == PaymentMethod.cash,
                                        onSelect: (m) =>
                                            _destinationPaymentMethodNotifier
                                                .value = m,
                                      ),
                                      horizontalMarginXSmall,
                                      _buildPaymentMethodOption(
                                        context,
                                        method: PaymentMethod.account,
                                        label: context.l10n.paymentAccount,
                                        icon: Icons.account_balance_rounded,
                                        isSelected:
                                            toMethod == PaymentMethod.account,
                                        onSelect: (m) =>
                                            _destinationPaymentMethodNotifier
                                                .value = m,
                                      ),
                                      horizontalMarginXSmall,
                                      _buildPaymentMethodOption(
                                        context,
                                        method: PaymentMethod.card,
                                        label: context.l10n.paymentCard,
                                        icon: Icons.credit_card_rounded,
                                        isSelected:
                                            toMethod == PaymentMethod.card,
                                        onSelect: (m) =>
                                            _destinationPaymentMethodNotifier
                                                .value = m,
                                      ),
                                    ],
                                  );
                                },
                              ),

                              verticalMarginMedium,

                              // Transfer Fee Field
                              Text(
                                context.l10n.transferFee,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.2,
                                  fontSize: 11.sp,
                                ),
                              ),
                              verticalMarginXSmall,
                              AppTextField(
                                controller: _feeController,
                                hintText: 'e.g. 5.00',
                                isAmount: true,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.onSurface,
                                  fontSize: 13.sp,
                                ),
                                hintStyle:
                                    customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  fontSize: 12.sp,
                                ),
                                fillColor: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ],
                          ),
                        );
                      }

                      // Expense or Income Category Selector
                      final categories = currentType == TransactionType.expense
                          ? _expenseCategories
                          : _incomeCategories;

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
                                fontSize: 11.sp,
                              ),
                            ),
                            verticalMarginXSmall,
                            ValueListenableBuilder<CategoryItem?>(
                              valueListenable: _selectedCategoryNotifier,
                              builder: (context, selectedCat, _) {
                                final catName = selectedCat?.name ??
                                    context.l10n.categoryLabel;
                                final catColor = _parseColor(
                                    selectedCat?.colorHex ?? '#57F1DB',
                                    colorScheme.primary);
                                final iconData = _getIconData(
                                    selectedCat?.icon ?? 'category');

                                return InkWell(
                                  onTap: () async {
                                    final picked =
                                        await CategoryPickerSheet.show(
                                      context: context,
                                      categories: categories,
                                      selectedCategory: selectedCat,
                                      initialType: currentType,
                                    );
                                    if (picked != null) {
                                      _selectedCategoryNotifier.value = picked;
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Container(
                                    height: 48.h,
                                    padding: horizontalPaddingMedium,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: allXSmall,
                                              decoration: BoxDecoration(
                                                color: catColor.withAlpha(
                                                    (0.2 * 255).round()),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Icon(
                                                iconData,
                                                color: catColor,
                                                size: 18.sp,
                                              ),
                                            ),
                                            horizontalMarginSmall,
                                            Text(
                                              catName,
                                              style: customTypography.bodyMedium
                                                  .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                                fontSize: 13.5.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.unfold_more_rounded,
                                          color: colorScheme.outline,
                                          size: 18.sp,
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

                  // Payment Method Selection (Expense only - Transfer uses From/To Payment Types above)
                  ValueListenableBuilder<TransactionType>(
                    valueListenable: _typeNotifier,
                    builder: (context, currentType, _) {
                      if (currentType != TransactionType.expense) {
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
                                fontSize: 11.sp,
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
                                      method: PaymentMethod.cash,
                                      label: context.l10n.paymentCash,
                                      icon: Icons.payments_rounded,
                                      isSelected:
                                          selectedMethod == PaymentMethod.cash,
                                    ),
                                    horizontalMarginXSmall,
                                    _buildPaymentMethodOption(
                                      context,
                                      method: PaymentMethod.account,
                                      label: context.l10n.paymentAccount,
                                      icon: Icons.account_balance_rounded,
                                      isSelected: selectedMethod ==
                                          PaymentMethod.account,
                                    ),
                                    horizontalMarginXSmall,
                                    _buildPaymentMethodOption(
                                      context,
                                      method: PaymentMethod.card,
                                      label: context.l10n.paymentCard,
                                      icon: Icons.credit_card_rounded,
                                      isSelected:
                                          selectedMethod == PaymentMethod.card,
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

                  // Note Input & Date Picker (Consistent height & 14px radius)
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
                                borderRadius: BorderRadius.circular(14.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(14.r),
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
                                        size: 16.sp,
                                        color: colorScheme.primary,
                                      ),
                                      horizontalMarginXSmall,
                                      Text(
                                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                        style: customTypography.bodyMedium
                                            .copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5.sp,
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
                              hintText: context.l10n.addNoteHint,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 13.sp,
                              ),
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 12.5.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.sticky_note_2_outlined,
                                color: colorScheme.outline,
                                size: 16.sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 10.h),
                              fillColor: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14.r),
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
                final isKeyboardOpen =
                    MediaQuery.of(context).viewInsets.bottom > 0;
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
                        bottom:
                            12.h + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      child: Builder(
                        builder: (blocContext) {
                          return ElevatedButton(
                            onPressed: () async {
                              final amount = double.tryParse(
                                      _amountStringNotifier.value) ??
                                  0.0;
                              if (amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(context.l10n.enterAmountError),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                                return;
                              }

                              CategoryItem? selectedCat =
                                  _selectedCategoryNotifier.value;
                              if (selectedCat == null) {
                                if (_expenseCategories.isNotEmpty) {
                                  selectedCat = _expenseCategories.first;
                                } else if (_incomeCategories.isNotEmpty) {
                                  selectedCat = _incomeCategories.first;
                                }
                              }

                              if (selectedCat == null &&
                                  _typeNotifier.value !=
                                      TransactionType.transfer) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(context.l10n.selectCategoryError),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                                return;
                              }

                              final catId = selectedCat?.id ?? 1;
                              final cubit =
                                  blocContext.read<TransactionCubit>();

                              String? noteText;
                              final baseNote = _noteController.text.trim();
                              final fee =
                                  double.tryParse(_feeController.text.trim());

                              final fromName = _formatPaymentMethodName(
                                  context, _paymentMethodNotifier.value);
                              final toName = _formatPaymentMethodName(context,
                                  _destinationPaymentMethodNotifier.value);

                              if (_typeNotifier.value ==
                                  TransactionType.transfer) {
                                final feePart = (fee != null && fee > 0)
                                    ? ' (Fee: ${getIt<PreferenceService>().currencySymbol}$fee)'
                                    : '';
                                final transferDesc =
                                    'Transfer: $fromName → $toName$feePart';
                                noteText = baseNote.isNotEmpty
                                    ? '$transferDesc | $baseNote'
                                    : transferDesc;
                              } else {
                                noteText =
                                    baseNote.isNotEmpty ? baseNote : null;
                              }

                              final PaymentMethod paymentMethod =
                                  _paymentMethodNotifier.value;

                              if (widget.initialTransaction != null) {
                                final initialTx = widget.initialTransaction!;
                                await cubit.updateTransaction(
                                  id: initialTx.id,
                                  type: _typeNotifier.value,
                                  amount: amount,
                                  categoryId: catId,
                                  timestamp: _dateNotifier.value,
                                  note: noteText,
                                  paymentMethod: paymentMethod,
                                );

                                if (_typeNotifier.value ==
                                    TransactionType.transfer) {
                                  final feeTx = cubit.allTransactions
                                      .where(
                                        (t) =>
                                            t.type == TransactionType.expense &&
                                            (t.note?.contains(
                                                        '[Ref: #${initialTx.id}]') ==
                                                    true ||
                                                (t.note?.startsWith(
                                                            'Transfer Fee') ==
                                                        true &&
                                                    (t.timestamp
                                                                .difference(
                                                                    _dateNotifier
                                                                        .value)
                                                                .inSeconds)
                                                            .abs() <
                                                        60)),
                                      )
                                      .firstOrNull;

                                  final feeNote =
                                      'Transfer Fee ($fromName → $toName) [Ref: #${initialTx.id}]';

                                  if (fee != null && fee > 0) {
                                    if (feeTx != null) {
                                      await cubit.updateTransaction(
                                        id: feeTx.id,
                                        type: TransactionType.expense,
                                        amount: fee,
                                        categoryId: catId,
                                        timestamp: _dateNotifier.value,
                                        note: feeNote,
                                        paymentMethod: paymentMethod,
                                      );
                                    } else {
                                      await cubit.addTransaction(
                                        type: TransactionType.expense,
                                        amount: fee,
                                        categoryId: catId,
                                        timestamp: _dateNotifier.value,
                                        note: feeNote,
                                        paymentMethod: paymentMethod,
                                      );
                                    }
                                  } else if (feeTx != null) {
                                    await cubit.deleteTransaction(feeTx.id);
                                  }
                                } else if (initialTx.type ==
                                        TransactionType.expense &&
                                    initialTx.note?.contains('Transfer Fee') ==
                                        true) {
                                  final refMatch = RegExp(r'\[Ref:\s*#(\d+)\]')
                                      .firstMatch(initialTx.note!);
                                  if (refMatch != null &&
                                      refMatch.groupCount >= 1) {
                                    final parentId =
                                        int.tryParse(refMatch.group(1)!);
                                    if (parentId != null) {
                                      final parentTx = cubit.allTransactions
                                          .where((t) => t.id == parentId)
                                          .firstOrNull;
                                      if (parentTx != null &&
                                          parentTx.note != null) {
                                        final symbol =
                                            getIt<PreferenceService>()
                                                .currencySymbol;
                                        final updatedNote =
                                            parentTx.note!.replaceAll(
                                          RegExp(r'\(Fee:\s*[^)]+\)'),
                                          '(Fee: $symbol${amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')})',
                                        );
                                        await cubit.updateTransaction(
                                          id: parentTx.id,
                                          type: parentTx.type,
                                          amount: parentTx.amount,
                                          categoryId: parentTx.categoryId,
                                          timestamp: parentTx.timestamp,
                                          note: updatedNote,
                                          paymentMethod: parentTx.paymentMethod,
                                        );
                                      }
                                    }
                                  }
                                }
                              } else {
                                final newId =
                                    await cubit.addTransactionAndReturnId(
                                  type: _typeNotifier.value,
                                  amount: amount,
                                  categoryId: catId,
                                  timestamp: _dateNotifier.value,
                                  note: noteText,
                                  paymentMethod: paymentMethod,
                                );

                                if (_typeNotifier.value ==
                                        TransactionType.transfer &&
                                    fee != null &&
                                    fee > 0) {
                                  final feeRef =
                                      newId != null ? ' [Ref: #$newId]' : '';
                                  await cubit.addTransaction(
                                    type: TransactionType.expense,
                                    amount: fee,
                                    categoryId: catId,
                                    timestamp: _dateNotifier.value,
                                    note:
                                        'Transfer Fee ($fromName → $toName)$feeRef',
                                    paymentMethod: paymentMethod,
                                  );
                                }
                              }

                              cubit.emitActionSuccess(
                                widget.initialTransaction != null
                                    ? 'Transaction updated successfully'
                                    : 'Transaction saved successfully',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              minimumSize: Size(double.infinity, 46.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              widget.initialTransaction != null
                                  ? 'Update Transaction'
                                  : context.l10n.saveTransaction,
                              style: customTypography.bodyLargeBold.copyWith(
                                color: colorScheme.onPrimary,
                                fontSize: 16.sp,
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
            height: 42.h,
            alignment: Alignment.center,
            child: key == '<'
                ? Icon(Icons.backspace_outlined,
                    color: colorScheme.onSurface, size: 20.sp)
                : Text(
                    key,
                    style: context.customTypography.headlineMediumMonoBold
                        .copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 20.sp,
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
    ValueChanged<PaymentMethod>? onSelect,
  }) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final activeColor = colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onSelect != null) {
            onSelect(method);
          } else {
            _paymentMethodNotifier.value = method;
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withAlpha((0.15 * 255).round())
                : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.r),
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
                size: 14.sp,
                color: isSelected ? activeColor : colorScheme.outline,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: customTypography.bodyMedium.copyWith(
                    fontSize: 11.sp,
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.outline,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
