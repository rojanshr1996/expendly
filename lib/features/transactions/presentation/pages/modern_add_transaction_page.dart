import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/category_picker_sheet.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
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
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
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
  bool _isAddingAnother = false;

  void _resetForm() {
    _amountController.clear();
    _noteController.clear();
    _feeController.clear();
    _isAddingAnother = false;
  }

  List<CategoryItem> _expenseCategories = [];
  List<CategoryItem> _incomeCategories = [];

  static const List<CategoryItem> _fallbackExpenseCategories = [
    CategoryItem(
        id: 1,
        name: 'Food & Dining',
        icon: 'restaurant',
        colorHex: '#FB7185',
        type: TransactionType.expense),
    CategoryItem(
        id: 2,
        name: 'Grocery Shopping',
        icon: 'shopping_cart',
        colorHex: '#FFAC5A',
        type: TransactionType.expense),
    CategoryItem(
        id: 3,
        name: 'Coffee & Cafes',
        icon: 'coffee',
        colorHex: '#D97706',
        type: TransactionType.expense),
    CategoryItem(
        id: 4,
        name: 'Housing & Bills',
        icon: 'home',
        colorHex: '#62FAE3',
        type: TransactionType.expense),
    CategoryItem(
        id: 5,
        name: 'Utilities',
        icon: 'receipt_long',
        colorHex: '#38BDF8',
        type: TransactionType.expense),
    CategoryItem(
        id: 6,
        name: 'Transportation',
        icon: 'directions_bus',
        colorHex: '#C0C1FF',
        type: TransactionType.expense),
    CategoryItem(
        id: 7,
        name: 'Personal Care',
        icon: 'content_cut',
        colorHex: '#A78BFA',
        type: TransactionType.expense),
    CategoryItem(
        id: 8,
        name: 'Beauty & Grooming',
        icon: 'spa',
        colorHex: '#F472B6',
        type: TransactionType.expense),
    CategoryItem(
        id: 9,
        name: 'Fitness & Gym',
        icon: 'fitness_center',
        colorHex: '#06B6D4',
        type: TransactionType.expense),
    CategoryItem(
        id: 10,
        name: 'Shopping & Apparel',
        icon: 'shopping_bag',
        colorHex: '#F43F5E',
        type: TransactionType.expense),
    CategoryItem(
        id: 11,
        name: 'Hobbies & Crafts',
        icon: 'palette',
        colorHex: '#F59E0B',
        type: TransactionType.expense),
    CategoryItem(
        id: 12,
        name: 'Electronics & Gadgets',
        icon: 'devices',
        colorHex: '#3B82F6',
        type: TransactionType.expense),
    CategoryItem(
        id: 13,
        name: 'Health & Wellness',
        icon: 'medical_services',
        colorHex: '#34D399',
        type: TransactionType.expense),
    CategoryItem(
        id: 14,
        name: 'Education',
        icon: 'school',
        colorHex: '#FBBF24',
        type: TransactionType.expense),
    CategoryItem(
        id: 15,
        name: 'Subscriptions',
        icon: 'subscriptions',
        colorHex: '#EC4899',
        type: TransactionType.expense),
    CategoryItem(
        id: 16,
        name: 'Events & Celebrations',
        icon: 'celebration',
        colorHex: '#E11D48',
        type: TransactionType.expense),
    CategoryItem(
        id: 17,
        name: 'Concerts & Live Shows',
        icon: 'music_note',
        colorHex: '#8B5CF6',
        type: TransactionType.expense),
    CategoryItem(
        id: 18,
        name: 'Weddings & Ceremonies',
        icon: 'favorite',
        colorHex: '#DB2777',
        type: TransactionType.expense),
    CategoryItem(
        id: 19,
        name: 'Sports & Stadium Events',
        icon: 'sports_soccer',
        colorHex: '#10B981',
        type: TransactionType.expense),
    CategoryItem(
        id: 20,
        name: 'Nightlife & Bars',
        icon: 'nightlife',
        colorHex: '#9333EA',
        type: TransactionType.expense),
    CategoryItem(
        id: 21,
        name: 'Entertainment',
        icon: 'movie',
        colorHex: '#FFD1AA',
        type: TransactionType.expense),
    CategoryItem(
        id: 22,
        name: 'Travel & Vacation',
        icon: 'flight',
        colorHex: '#818CF8',
        type: TransactionType.expense),
    CategoryItem(
        id: 23,
        name: 'Gifts & Donations',
        icon: 'card_giftcard',
        colorHex: '#FB7185',
        type: TransactionType.expense),
    CategoryItem(
        id: 24,
        name: 'Family & Childcare',
        icon: 'child_care',
        colorHex: '#FB923C',
        type: TransactionType.expense),
    CategoryItem(
        id: 25,
        name: 'Pets',
        icon: 'pets',
        colorHex: '#A3E635',
        type: TransactionType.expense),
    CategoryItem(
        id: 26,
        name: 'Debt & Loans',
        icon: 'credit_card',
        colorHex: '#E11D48',
        type: TransactionType.expense),
    CategoryItem(
        id: 27,
        name: 'Other Expense',
        icon: 'more_horiz',
        colorHex: '#94A3B8',
        type: TransactionType.expense),
  ];

  static const List<CategoryItem> _fallbackIncomeCategories = [
    CategoryItem(
        id: 28,
        name: 'Salary',
        icon: 'payments',
        colorHex: '#34D399',
        type: TransactionType.income),
    CategoryItem(
        id: 29,
        name: 'Freelance Payout',
        icon: 'work',
        colorHex: '#57F1DB',
        type: TransactionType.income),
    CategoryItem(
        id: 30,
        name: 'Investments & Dividends',
        icon: 'trending_up',
        colorHex: '#C0C1FF',
        type: TransactionType.income),
    CategoryItem(
        id: 31,
        name: 'Business Revenue',
        icon: 'storefront',
        colorHex: '#38BDF8',
        type: TransactionType.income),
    CategoryItem(
        id: 32,
        name: 'Rental Income',
        icon: 'real_estate_agent',
        colorHex: '#FBBF24',
        type: TransactionType.income),
    CategoryItem(
        id: 33,
        name: 'Gifts & Cashbacks',
        icon: 'redeem',
        colorHex: '#F472B6',
        type: TransactionType.income),
    CategoryItem(
        id: 34,
        name: 'Refunds & Reimbursements',
        icon: 'currency_exchange',
        colorHex: '#A78BFA',
        type: TransactionType.income),
    CategoryItem(
        id: 35,
        name: 'Other Income',
        icon: 'more_horiz',
        colorHex: '#94A3B8',
        type: TransactionType.income),
  ];

  @override
  void initState() {
    super.initState();
    _expenseCategories = List.from(_fallbackExpenseCategories);
    _incomeCategories = List.from(_fallbackIncomeCategories);
    _selectedCategoryNotifier.value = _fallbackExpenseCategories.first;

    if (widget.initialTransaction != null) {
      final tx = widget.initialTransaction!;
      _typeNotifier.value = tx.type;
      _amountController.text =
          tx.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      _dateNotifier.value = tx.timestamp;
      if (tx.paymentMethod != null) {
        _paymentMethodNotifier.value = tx.paymentMethod!;
      }

      final allCats = [..._expenseCategories, ..._incomeCategories];
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
    }

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final db = getIt<AppDatabase>();
      final rows = await db.select(db.categories).get();

      if (rows.isNotEmpty) {
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

        if (mounted) {
          setState(() {
            _expenseCategories =
                expense.isNotEmpty ? expense : _fallbackExpenseCategories;
            _incomeCategories =
                income.isNotEmpty ? income : _fallbackIncomeCategories;
          });

          if (widget.initialTransaction != null) {
            final tx = widget.initialTransaction!;
            final allCats = [..._expenseCategories, ..._incomeCategories];
            CategoryItem? foundCat;
            try {
              foundCat = allCats.firstWhere((c) => c.id == tx.categoryId);
            } catch (_) {
              if (allCats.isNotEmpty) {
                foundCat = allCats.first;
              }
            }
            if (foundCat != null) {
              _selectedCategoryNotifier.value = foundCat;
            }
          }
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

  void _switchType(TransactionType tabType) {
    debugPrint('*** SWITCH TYPE EXECUTED: $tabType ***');
    _typeNotifier.value = tabType;
    if (tabType == TransactionType.expense) {
      if (_expenseCategories.isNotEmpty) {
        _selectedCategoryNotifier.value = _expenseCategories.first;
      }
    } else if (tabType == TransactionType.income) {
      if (_incomeCategories.isNotEmpty) {
        _selectedCategoryNotifier.value = _incomeCategories.first;
      }
    } else if (tabType == TransactionType.transfer) {
      _paymentMethodNotifier.value = PaymentMethod.cash;
      _destinationPaymentMethodNotifier.value = PaymentMethod.account;
    }
  }

  PaymentMethod _matchPaymentMethod(String str,
      {required PaymentMethod fallback}) {
    final lower = str.toLowerCase();
    if (lower.contains('card') || lower.contains('credit')) {
      return PaymentMethod.card;
    }
    if (lower.contains('cash') || lower.contains('wallet')) {
      return PaymentMethod.cash;
    }
    if (lower.contains('account') || lower.contains('bank')) {
      return PaymentMethod.account;
    }
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
    _amountController.dispose();
    _amountFocusNode.dispose();
    _selectedCategoryNotifier.dispose();
    _destinationPaymentMethodNotifier.dispose();
    _dateNotifier.dispose();
    _paymentMethodNotifier.dispose();
    _noteController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final isTablet = Breakpoints.isTablet(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + kToolbarHeight;

    return BlocProvider<TransactionCubit>(
      create: (_) => getIt<TransactionCubit>(),
      child: BlocListener<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionActionSuccess) {
            try {
              getIt<DashboardCubit>().loadDashboardData();
            } catch (_) {}
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.secondary,
                action: state.transactionId != null
                    ? SnackBarAction(
                        label: 'Undo',
                        textColor: colorScheme.onSecondary,
                        onPressed: () {
                          context
                              .read<TransactionCubit>()
                              .deleteTransaction(state.transactionId!);
                        },
                      )
                    : null,
              ),
            );

            if (_isAddingAnother) {
              _resetForm();
            } else {
              context.router.maybePop(true);
            }
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
            extendBodyBehindAppBar: true,
            appBar: LiquidGlassAppBar(
              leading: IconButton(
                icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
                onPressed: () => context.router.maybePop(),
              ),
              titleText: widget.initialTransaction != null
                  ? 'Edit Transaction'
                  : context.l10n.logTransaction,
            ),
            body: Padding(
              padding: EdgeInsets.only(top: headerPaddingTop),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. Scrollable Form Content (scrolls UNDER the pinned liquid glass tab bar)
                        Positioned.fill(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.only(
                              top: 60.0,
                              bottom: 24.0,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isTablet ? 640.0 : double.infinity,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Amount Hero Card Display
                                    ValueListenableBuilder<TransactionType>(
                                      valueListenable: _typeNotifier,
                                      builder: (context, type, _) {
                                        final currencySymbol =
                                            getIt<PreferenceService>()
                                                .currencySymbol;
                                        final color = type ==
                                                TransactionType.income
                                            ? customColors.semanticGreen
                                            : type == TransactionType.transfer
                                                ? customColors.semanticBlue
                                                : customColors.semanticRed;

                                        return GestureDetector(
                                          onTap: () =>
                                              _amountFocusNode.requestFocus(),
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 16.0),
                                            decoration: BoxDecoration(
                                              color: colorScheme
                                                  .surfaceContainerHigh
                                                  .withValues(alpha: 0.55),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(20.0)),
                                              border: Border.all(
                                                color: color.withValues(
                                                    alpha: 0.30),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withValues(
                                                      alpha: 0.08),
                                                  blurRadius: 16.0,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  context.l10n.amountLabel
                                                      .toUpperCase(),
                                                  style: customTypography
                                                      .labelMediumMono
                                                      .copyWith(
                                                    color: colorScheme.outline,
                                                    letterSpacing: 1.5,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment: Alignment.center,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .baseline,
                                                    textBaseline:
                                                        TextBaseline.alphabetic,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '$currencySymbol ',
                                                        style: customTypography
                                                            .headlineLargeMonoBold
                                                            .copyWith(
                                                          color: color,
                                                          fontSize: 36.0,
                                                        ),
                                                      ),
                                                      IntrinsicWidth(
                                                        child: TextField(
                                                          controller:
                                                              _amountController,
                                                          focusNode:
                                                              _amountFocusNode,
                                                          keyboardType:
                                                              const TextInputType
                                                                  .numberWithOptions(
                                                                  decimal:
                                                                      true),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .allow(RegExp(
                                                                    r'^\d*\.?\d{0,2}')),
                                                          ],
                                                          style: customTypography
                                                              .headlineLargeMonoBold
                                                              .copyWith(
                                                            color: color,
                                                            fontSize: 36.0,
                                                          ),
                                                          cursorColor: color,
                                                          decoration:
                                                              InputDecoration(
                                                            filled: false,
                                                            fillColor: Colors
                                                                .transparent,
                                                            hintText: '0.00',
                                                            hintStyle:
                                                                customTypography
                                                                    .headlineLargeMonoBold
                                                                    .copyWith(
                                                              color: color
                                                                  .withValues(
                                                                      alpha:
                                                                          0.35),
                                                              fontSize: 36.0,
                                                            ),
                                                            border: InputBorder
                                                                .none,
                                                            enabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            focusedBorder:
                                                                InputBorder
                                                                    .none,
                                                            errorBorder:
                                                                InputBorder
                                                                    .none,
                                                            disabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            isDense: true,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 20.0),

                                    // Category / Transfer Account Selection Fields
                                    ValueListenableBuilder<TransactionType>(
                                      valueListenable: _typeNotifier,
                                      builder: (context, currentType, _) {
                                        if (currentType ==
                                            TransactionType.transfer) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // From Payment Method (Source)
                                                Text(
                                                  context.l10n.fromAccount,
                                                  style: customTypography
                                                      .labelMediumMono
                                                      .copyWith(
                                                    color: colorScheme.outline,
                                                    letterSpacing: 1.2,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                ValueListenableBuilder<
                                                    PaymentMethod>(
                                                  valueListenable:
                                                      _paymentMethodNotifier,
                                                  builder:
                                                      (context, fromMethod, _) {
                                                    return Row(
                                                      children: [
                                                        _buildPaymentMethodOption(
                                                          context,
                                                          method: PaymentMethod
                                                              .cash,
                                                          label: context
                                                              .l10n.paymentCash,
                                                          icon: Icons
                                                              .payments_rounded,
                                                          isSelected:
                                                              fromMethod ==
                                                                  PaymentMethod
                                                                      .cash,
                                                          onSelect: (m) =>
                                                              _paymentMethodNotifier
                                                                  .value = m,
                                                        ),
                                                        const SizedBox(
                                                            width: 8.0),
                                                        _buildPaymentMethodOption(
                                                          context,
                                                          method: PaymentMethod
                                                              .account,
                                                          label: context.l10n
                                                              .paymentAccount,
                                                          icon: Icons
                                                              .account_balance_rounded,
                                                          isSelected:
                                                              fromMethod ==
                                                                  PaymentMethod
                                                                      .account,
                                                          onSelect: (m) =>
                                                              _paymentMethodNotifier
                                                                  .value = m,
                                                        ),
                                                        const SizedBox(
                                                            width: 8.0),
                                                        _buildPaymentMethodOption(
                                                          context,
                                                          method: PaymentMethod
                                                              .card,
                                                          label: context
                                                              .l10n.paymentCard,
                                                          icon: Icons
                                                              .credit_card_rounded,
                                                          isSelected:
                                                              fromMethod ==
                                                                  PaymentMethod
                                                                      .card,
                                                          onSelect: (m) =>
                                                              _paymentMethodNotifier
                                                                  .value = m,
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),

                                                const SizedBox(height: 16.0),

                                                // To Payment Method (Destination)
                                                Text(
                                                  context.l10n.toAccount,
                                                  style: customTypography
                                                      .labelMediumMono
                                                      .copyWith(
                                                    color: colorScheme.outline,
                                                    letterSpacing: 1.2,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                ValueListenableBuilder<
                                                    PaymentMethod>(
                                                  valueListenable:
                                                      _destinationPaymentMethodNotifier,
                                                  builder:
                                                      (context, toMethod, _) {
                                                    return Row(
                                                      children: [
                                                        _buildPaymentMethodOption(
                                                          context,
                                                          method: PaymentMethod
                                                              .cash,
                                                          label: context
                                                              .l10n.paymentCash,
                                                          icon: Icons
                                                              .payments_rounded,
                                                          isSelected:
                                                              toMethod ==
                                                                  PaymentMethod
                                                                      .cash,
                                                          onSelect: (m) =>
                                                              _destinationPaymentMethodNotifier
                                                                  .value = m,
                                                        ),
                                                        const SizedBox(
                                                            width: 8.0),
                                                        _buildPaymentMethodOption(
                                                          context,
                                                          method: PaymentMethod
                                                              .account,
                                                          label: context.l10n
                                                              .paymentAccount,
                                                          icon: Icons
                                                              .account_balance_rounded,
                                                          isSelected:
                                                              toMethod ==
                                                                  PaymentMethod
                                                                      .account,
                                                          onSelect: (m) =>
                                                              _destinationPaymentMethodNotifier
                                                                  .value = m,
                                                        ),
                                                        const SizedBox(
                                                            width: 8.0),
                                                        _buildPaymentMethodOption(
                                                          context,
                                                          method: PaymentMethod
                                                              .card,
                                                          label: context
                                                              .l10n.paymentCard,
                                                          icon: Icons
                                                              .credit_card_rounded,
                                                          isSelected:
                                                              toMethod ==
                                                                  PaymentMethod
                                                                      .card,
                                                          onSelect: (m) =>
                                                              _destinationPaymentMethodNotifier
                                                                  .value = m,
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),

                                                const SizedBox(height: 16.0),

                                                // Transfer Fee Field
                                                Text(
                                                  context.l10n.transferFee,
                                                  style: customTypography
                                                      .labelMediumMono
                                                      .copyWith(
                                                    color: colorScheme.outline,
                                                    letterSpacing: 1.2,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                AppTextField(
                                                  controller: _feeController,
                                                  hintText: 'e.g. 5.00',
                                                  isAmount: true,
                                                  style: customTypography
                                                      .labelMediumMono
                                                      .copyWith(
                                                    color:
                                                        colorScheme.onSurface,
                                                    fontSize: 14.0,
                                                  ),
                                                  hintStyle: customTypography
                                                      .labelMediumMono
                                                      .copyWith(
                                                    color: colorScheme.outline,
                                                    fontSize: 13.0,
                                                  ),
                                                  fillColor: colorScheme
                                                      .surfaceContainerHigh,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              14.0)),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        // Expense or Income Category Selector
                                        final categories = currentType ==
                                                TransactionType.expense
                                            ? _expenseCategories
                                            : _incomeCategories;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                context.l10n.categoryLabel,
                                                style: customTypography
                                                    .labelMediumMono
                                                    .copyWith(
                                                  color: colorScheme.outline,
                                                  letterSpacing: 1.2,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              ValueListenableBuilder<
                                                  CategoryItem?>(
                                                valueListenable:
                                                    _selectedCategoryNotifier,
                                                builder:
                                                    (context, selectedCat, _) {
                                                  final catName =
                                                      selectedCat?.name ??
                                                          context.l10n
                                                              .categoryLabel;
                                                  final catColor = _parseColor(
                                                      selectedCat?.colorHex ??
                                                          '#57F1DB',
                                                      colorScheme.primary);
                                                  final iconData = _getIconData(
                                                      selectedCat?.icon ??
                                                          'category');

                                                  return InkWell(
                                                    onTap: () async {
                                                      final picked =
                                                          await CategoryPickerSheet
                                                              .show(
                                                        context: context,
                                                        categories: categories,
                                                        selectedCategory:
                                                            selectedCat,
                                                        initialType:
                                                            currentType,
                                                      );
                                                      if (picked != null) {
                                                        _selectedCategoryNotifier
                                                            .value = picked;
                                                      }
                                                    },
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                14.0)),
                                                    child: Container(
                                                      height: 52.0,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16.0),
                                                      decoration: BoxDecoration(
                                                        color: colorScheme
                                                            .surfaceContainerHigh,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    14.0)),
                                                        border: Border.all(
                                                          color: colorScheme
                                                              .outlineVariant,
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: catColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.2),
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              8.0)),
                                                                ),
                                                                child: Icon(
                                                                  iconData,
                                                                  color:
                                                                      catColor,
                                                                  size: 20.0,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 12.0),
                                                              Text(
                                                                catName,
                                                                style: customTypography
                                                                    .bodyMedium
                                                                    .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: colorScheme
                                                                      .onSurface,
                                                                  fontSize:
                                                                      14.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .unfold_more_rounded,
                                                            color: colorScheme
                                                                .outline,
                                                            size: 20.0,
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

                                    // Payment Method Selection (Expense only)
                                    ValueListenableBuilder<TransactionType>(
                                      valueListenable: _typeNotifier,
                                      builder: (context, currentType, _) {
                                        if (currentType !=
                                            TransactionType.expense) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 16.0),
                                              Text(
                                                context.l10n.paymentMethodLabel,
                                                style: customTypography
                                                    .labelMediumMono
                                                    .copyWith(
                                                  color: colorScheme.outline,
                                                  letterSpacing: 1.2,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              ValueListenableBuilder<
                                                  PaymentMethod>(
                                                valueListenable:
                                                    _paymentMethodNotifier,
                                                builder: (context,
                                                    selectedMethod, _) {
                                                  return Row(
                                                    children: [
                                                      _buildPaymentMethodOption(
                                                        context,
                                                        method:
                                                            PaymentMethod.cash,
                                                        label: context
                                                            .l10n.paymentCash,
                                                        icon: Icons
                                                            .payments_rounded,
                                                        isSelected:
                                                            selectedMethod ==
                                                                PaymentMethod
                                                                    .cash,
                                                      ),
                                                      const SizedBox(
                                                          width: 8.0),
                                                      _buildPaymentMethodOption(
                                                        context,
                                                        method: PaymentMethod
                                                            .account,
                                                        label: context.l10n
                                                            .paymentAccount,
                                                        icon: Icons
                                                            .account_balance_rounded,
                                                        isSelected:
                                                            selectedMethod ==
                                                                PaymentMethod
                                                                    .account,
                                                      ),
                                                      const SizedBox(
                                                          width: 8.0),
                                                      _buildPaymentMethodOption(
                                                        context,
                                                        method:
                                                            PaymentMethod.card,
                                                        label: context
                                                            .l10n.paymentCard,
                                                        icon: Icons
                                                            .credit_card_rounded,
                                                        isSelected:
                                                            selectedMethod ==
                                                                PaymentMethod
                                                                    .card,
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

                                    const SizedBox(height: 16.0),

                                    // Date Picker
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n.dateAndTimeLabel,
                                            style: customTypography
                                                .labelMediumMono
                                                .copyWith(
                                              color: colorScheme.outline,
                                              letterSpacing: 1.2,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          ValueListenableBuilder<DateTime>(
                                            valueListenable: _dateNotifier,
                                            builder:
                                                (context, selectedDate, _) {
                                              return InkWell(
                                                onTap: () async {
                                                  final picked =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: selectedDate,
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (picked != null) {
                                                    _dateNotifier.value =
                                                        picked;
                                                  }
                                                },
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(14.0)),
                                                child: Container(
                                                  height: 52.0,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme
                                                        .surfaceContainerHigh,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                14.0)),
                                                    border: Border.all(
                                                      color: colorScheme
                                                          .outlineVariant,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today_rounded,
                                                            size: 20.0,
                                                            color: colorScheme
                                                                .primary,
                                                          ),
                                                          const SizedBox(
                                                              width: 12.0),
                                                          Text(
                                                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                                            style:
                                                                customTypography
                                                                    .bodyMedium
                                                                    .copyWith(
                                                              color: colorScheme
                                                                  .onSurface,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .edit_calendar_rounded,
                                                        color:
                                                            colorScheme.outline,
                                                        size: 20.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16.0),

                                    // Note / Description Field
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n.noteLabel,
                                            style: customTypography
                                                .labelMediumMono
                                                .copyWith(
                                              color: colorScheme.outline,
                                              letterSpacing: 1.2,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          AppTextField(
                                            controller: _noteController,
                                            hintText: context.l10n.addNoteHint,
                                            textInputAction:
                                                TextInputAction.done,
                                            style:
                                                textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurface,
                                              fontSize: 14.0,
                                            ),
                                            hintStyle:
                                                textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.outline,
                                              fontSize: 13.5,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.sticky_note_2_outlined,
                                              color: colorScheme.outline,
                                              size: 20.0,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 14.0),
                                            fillColor: colorScheme
                                                .surfaceContainerHigh,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(14.0)),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 2. Fixed Non-Scrollable Pinned Liquid Glass Tab Bar Component
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 640.0 : double.infinity,
                              ),
                              child: ValueListenableBuilder<TransactionType>(
                                valueListenable: _typeNotifier,
                                builder: (context, type, _) {
                                  return _TypeSelectorRow(
                                    selectedType: type,
                                    onTypeSelected: _switchType,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Fixed Bottom Save Container taking the bottom space of the page
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: isLight
                              ? colorScheme.outlineVariant
                                  .withValues(alpha: 0.50)
                              : customColors.glassStroke
                                  .withValues(alpha: 0.40),
                          width: 1.0,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isLight ? 0.04 : 0.15),
                          blurRadius: 10.0,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32.0 : 20.0,
                          vertical: 12.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 640.0 : double.infinity,
                            ),
                            child: Builder(
                              builder: (blocContext) {
                                final isEditing =
                                    widget.initialTransaction != null;

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isEditing) ...[
                                      OutlinedButton(
                                        onPressed: () => _handleSave(
                                            blocContext,
                                            addAnother: true),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: colorScheme.primary,
                                          minimumSize: Size(double.infinity,
                                              isTablet ? 54.0 : 48.0),
                                          side: BorderSide(
                                              color: colorScheme.primary,
                                              width: 1.5),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(14.0)),
                                          ),
                                        ),
                                        child: Text(
                                          'Save & Add Another',
                                          textAlign: TextAlign.center,
                                          style: customTypography.bodyLargeBold
                                              .copyWith(
                                            color: colorScheme.primary,
                                            fontSize: isTablet ? 15.0 : 13.0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                    ],
                                    ElevatedButton(
                                      onPressed: () => _handleSave(blocContext,
                                          addAnother: false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        minimumSize: Size(double.infinity,
                                            isTablet ? 54.0 : 48.0),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14.0)),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        isEditing
                                            ? 'Update Transaction'
                                            : context.l10n.saveTransaction,
                                        textAlign: TextAlign.center,
                                        style: customTypography.bodyLargeBold
                                            .copyWith(
                                          color: colorScheme.onPrimary,
                                          fontSize: isTablet ? 16.0 : 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext blocContext,
      {bool addAnother = false}) async {
    _isAddingAnother = addAnother;
    final colorScheme = Theme.of(context).colorScheme;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.enterAmountError),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    CategoryItem? selectedCat = _selectedCategoryNotifier.value;
    if (selectedCat == null) {
      if (_expenseCategories.isNotEmpty) {
        selectedCat = _expenseCategories.first;
      } else if (_incomeCategories.isNotEmpty) {
        selectedCat = _incomeCategories.first;
      }
    }

    if (selectedCat == null &&
        _typeNotifier.value != TransactionType.transfer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.selectCategoryError),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final catId = selectedCat?.id ?? 1;
    final cubit = blocContext.read<TransactionCubit>();

    String? noteText;
    final baseNote = _noteController.text.trim();
    final fee = double.tryParse(_feeController.text.trim());

    final fromName =
        _formatPaymentMethodName(context, _paymentMethodNotifier.value);
    final toName = _formatPaymentMethodName(
        context, _destinationPaymentMethodNotifier.value);

    if (_typeNotifier.value == TransactionType.transfer) {
      final feePart = (fee != null && fee > 0)
          ? ' (Fee: ${getIt<PreferenceService>().currencySymbol}$fee)'
          : '';
      final transferDesc = 'Transfer: $fromName → $toName$feePart';
      noteText =
          baseNote.isNotEmpty ? '$transferDesc | $baseNote' : transferDesc;
    } else {
      noteText = baseNote.isNotEmpty ? baseNote : null;
    }

    final PaymentMethod paymentMethod = _paymentMethodNotifier.value;

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

      if (_typeNotifier.value == TransactionType.transfer) {
        final feeTx = cubit.allTransactions
            .where(
              (t) =>
                  t.type == TransactionType.expense &&
                  (t.note?.contains('[Ref: #${initialTx.id}]') == true ||
                      (t.note?.startsWith('Transfer Fee') == true &&
                          (t.timestamp
                                      .difference(_dateNotifier.value)
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
      } else if (initialTx.type == TransactionType.expense &&
          initialTx.note?.contains('Transfer Fee') == true) {
        final refMatch =
            RegExp(r'\[Ref:\s*#(\d+)\]').firstMatch(initialTx.note!);
        if (refMatch != null && refMatch.groupCount >= 1) {
          final parentId = int.tryParse(refMatch.group(1)!);
          if (parentId != null) {
            final parentTx = cubit.allTransactions
                .where((t) => t.id == parentId)
                .firstOrNull;
            if (parentTx != null && parentTx.note != null) {
              final symbol = getIt<PreferenceService>().currencySymbol;
              final updatedNote = parentTx.note!.replaceAll(
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
      final newId = await cubit.addTransactionAndReturnId(
        type: _typeNotifier.value,
        amount: amount,
        categoryId: catId,
        timestamp: _dateNotifier.value,
        note: noteText,
        paymentMethod: paymentMethod,
      );

      if (_typeNotifier.value == TransactionType.transfer &&
          fee != null &&
          fee > 0) {
        final feeRef = newId != null ? ' [Ref: #$newId]' : '';
        await cubit.addTransaction(
          type: TransactionType.expense,
          amount: fee,
          categoryId: catId,
          timestamp: _dateNotifier.value,
          note: 'Transfer Fee ($fromName → $toName)$feeRef',
          paymentMethod: paymentMethod,
        );
      }
    }

    cubit.emitActionSuccess(
      widget.initialTransaction != null
          ? 'Transaction updated successfully'
          : 'Transaction saved successfully',
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
    return CategoryIconHelper.getIcon(iconName);
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
        borderRadius: const BorderRadius.all(Radius.circular(14.0)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.15)
                : colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
                size: 16.0,
                color: isSelected ? activeColor : colorScheme.outline,
              ),
              const SizedBox(width: 4.0),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: customTypography.bodyMedium.copyWith(
                    fontSize: 12.0,
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

class _TypeSelectorRow extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeSelected;

  const _TypeSelectorRow({
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isTablet = Breakpoints.isTablet(context);

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

    return _LiquidGlassCard(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 0.0 : 20.0,
        vertical: 6.0,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(14.0)),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: tabs.map((t) {
          final tabType = t['type'] as TransactionType;
          final isSelected = tabType == selectedType;
          final activeColor = t['activeColor'] as Color;
          final onActiveColor = t['onActiveColor'] as Color;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: GestureDetector(
                key: Key('tab_${tabType.name}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onTypeSelected(tabType),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.35),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t['label'] as String,
                    textAlign: TextAlign.center,
                    style: customTypography.labelMediumMono.copyWith(
                      color: isSelected
                          ? onActiveColor
                          : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _LiquidGlassCard({
    required this.child,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = borderRadius ?? const BorderRadius.all(Radius.circular(16.0));

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.15),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.08),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.12),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.05),
                ],
        ),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.35)
              : customColors.glassStroke.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          // Specular Top Highlight Glow
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.40 : 0.05),
            blurRadius: 4.0,
            spreadRadius: -1.0,
            offset: const Offset(0, -1),
          ),
          // Subtle contact separation shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.15),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 2),
          ),
          // Soft Ambient Elevation Shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.07 : 0.25),
            blurRadius: 16.0,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
