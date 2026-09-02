import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:expendly/core/constants/margin_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../../../core/widgets/category_picker_sheet.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/status_components.dart';
import '../../domain/entities/category_item.dart';
import '../../domain/entities/transaction_item.dart';
import '../cubit/quick_add_cubit.dart';
import '../cubit/quick_add_state.dart';
import '../widgets/quick_amount_keypad.dart';

/// Modal Bottom Sheet implementing the Liquid Glass Quick Add flow.
/// Eliminates vertical whitespace with a compact, amount-first numeric keypad
/// and frosted glassmorphic appearance.
class QuickAddBottomSheet extends StatefulWidget {
  final int? initialCategoryId;
  final PaymentMethod? initialPaymentMethod;
  final DateTime? initialDate;
  final QuickAddCubit? cubit;

  const QuickAddBottomSheet({
    super.key,
    this.initialCategoryId,
    this.initialPaymentMethod,
    this.initialDate,
    this.cubit,
  });

  /// Displays the Quick Add sheet as a modal bottom sheet on compact mobile layouts,
  /// or as an adaptive centered dialog on tablet layouts.
  static Future<bool?> show(
    BuildContext context, {
    int? initialCategoryId,
    PaymentMethod? initialPaymentMethod,
    DateTime? initialDate,
    QuickAddCubit? cubit,
  }) {
    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (dialogCtx) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 24.0,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480.0),
            child: QuickAddBottomSheet(
              initialCategoryId: initialCategoryId,
              initialPaymentMethod: initialPaymentMethod,
              initialDate: initialDate,
              cubit: cubit,
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
        builder: (sheetCtx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: QuickAddBottomSheet(
            initialCategoryId: initialCategoryId,
            initialPaymentMethod: initialPaymentMethod,
            initialDate: initialDate,
            cubit: cubit,
          ),
        ),
      );
    }
  }

  @override
  State<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends State<QuickAddBottomSheet> {
  late final QuickAddCubit _cubit;

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

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? getIt<QuickAddCubit>();
    if (widget.cubit == null) {
      _cubit.loadDefaults(
        explicitCategoryId: widget.initialCategoryId,
        explicitPaymentMethod: widget.initialPaymentMethod,
        explicitDate: widget.initialDate,
      );
    }
  }

  @override
  void didUpdateWidget(QuickAddBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cubit != oldWidget.cubit && widget.cubit != null) {
      _cubit = widget.cubit!;
    }
  }

  @override
  void dispose() {
    if (widget.cubit == null) {
      _cubit.close();
    }
    super.dispose();
  }

  IconData _parseIcon(String iconName, [String? categoryName]) {
    return CategoryIconHelper.getIcon(iconName, categoryName);
  }

  Color _parseColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.orange;
    }
  }

  Future<void> _pickCategory(
    BuildContext context,
    CategoryItem currentSelected,
    List<CategoryItem> availableCategories,
  ) async {
    HapticFeedback.selectionClick();
    final selected = await CategoryPickerSheet.show(
      context: context,
      categories: availableCategories.isNotEmpty
          ? availableCategories
          : _fallbackExpenseCategories,
      selectedCategory: currentSelected,
      initialType: TransactionType.expense,
    );

    if (selected != null) {
      _cubit.selectCategory(selected);
    }
  }

  void _cyclePaymentMethod(PaymentMethod current) {
    HapticFeedback.selectionClick();
    const values = PaymentMethod.values;
    final nextIndex = (values.indexOf(current) + 1) % values.length;
    _cubit.selectPaymentMethod(values[nextIndex]);
  }

  Future<void> _pickDate(BuildContext context, DateTime currentDate) async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _cubit.selectDate(picked);
    }
  }

  String _formatPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.account:
        return 'Account';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.account:
        return Icons.account_balance_outlined;
    }
  }

  String _formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(date);
  }

  void _navigateToMoreDetails(QuickAddReady state) {
    HapticFeedback.selectionClick();
    final item = TransactionItem(
      id: 0,
      type: TransactionType.expense,
      amount: state.amountValue > 0 ? state.amountValue : 0.0,
      currencyCode: state.defaults.currencyCode,
      categoryId: state.selectedCategory.id,
      categoryName: state.selectedCategory.name,
      categoryIcon: state.selectedCategory.icon,
      categoryColorHex: state.selectedCategory.colorHex,
      timestamp: state.selectedDate,
      paymentMethod: state.selectedPaymentMethod,
    );

    // Dismiss bottom sheet and push detailed entry
    Navigator.of(context).pop();
    context.router.push(ModernAddTransactionRoute(initialTransaction: item));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final isTablet = Breakpoints.isTablet(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final customColors = context.customColors;

    final sheetRadius = isTablet
        ? BorderRadius.circular(24.r)
        : BorderRadius.vertical(top: Radius.circular(28.r));

    final glassBorderColor = isLight
        ? colorScheme.outlineVariant.withValues(alpha: 0.55)
        : customColors.glassStroke.withValues(alpha: 0.55);

    return BlocProvider<QuickAddCubit>.value(
      value: _cubit,
      child: BlocConsumer<QuickAddCubit, QuickAddState>(
        listener: (context, state) {
          if (state is QuickAddSuccess) {
            HapticFeedback.mediumImpact();
            StatusComponents.showToast(
              context,
              message:
                  'Saved ${state.currencySymbol}${state.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')} for ${state.categoryName}',
              isSuccess: true,
              actionLabel: 'Undo',
              onActionPressed: () {
                context.read<QuickAddCubit>().undoExpense(state.transactionId);
                StatusComponents.showToast(
                  context,
                  message: 'Transaction undone',
                  isSuccess: true,
                );
              },
            );

            if (!state.addAnother) {
              Navigator.of(context).pop(true);
            }
          } else if (state is QuickAddReady && state.errorMessage != null) {
            StatusComponents.showToast(
              context,
              message: state.errorMessage!,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          if (state is! QuickAddReady) {
            return Container(
              height: 240.h,
              decoration: BoxDecoration(
                color: isLight
                    ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.90)
                    : colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
                borderRadius: sheetRadius,
              ),
              child: Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
            );
          }

          final amountStr = state.amountText.isEmpty ? '0' : state.amountText;
          final currencySymbol = state.defaults.currencySymbol;
          final categoryColor = _parseColor(state.selectedCategory.colorHex);

          return ClipRRect(
            borderRadius: sheetRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isLight
                        ? [
                            colorScheme.surfaceContainerLowest
                                .withValues(alpha: 0.92),
                            colorScheme.surfaceContainerLow
                                .withValues(alpha: 0.96),
                          ]
                        : [
                            colorScheme.surfaceContainerHigh
                                .withValues(alpha: 0.85),
                            colorScheme.surfaceContainer
                                .withValues(alpha: 0.92),
                          ],
                  ),
                  borderRadius: sheetRadius,
                  border: Border.all(
                    color: glassBorderColor,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isLight ? 0.08 : 0.35),
                      blurRadius: 24.r,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Drag Handle Pill
                      Center(
                        child: Container(
                          width: 38.w,
                          height: 4.h,
                          margin: EdgeInsets.only(top: 12.h, bottom: 6.h),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),

                      // 2. Compact Top Bar: Close, Title, More Details
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20.0 : 16.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: isTablet ? 22.0 : 22.sp,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Text(
                                'Quick Expense',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    (textTheme.titleMedium ?? const TextStyle())
                                        .copyWith(
                                  fontWeight: FontWeights.bold,
                                  color: colorScheme.onSurface,
                                  fontSize: isTablet ? 16.0 : 15.sp,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _navigateToMoreDetails(state),
                              iconAlignment: IconAlignment.end,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                size: isTablet ? 18.0 : 18.sp,
                                color: colorScheme.primary,
                              ),
                              label: Text(
                                'More Details',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeights.semiBold,
                                  fontSize: isTablet ? 13.0 : 12.5.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. Hero Amount Display (Compact & Centered)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currencySymbol,
                                style:
                                    (customTypography.amountDisplay).copyWith(
                                  fontSize: isTablet ? 30.0 : 26.sp,
                                  fontWeight: FontWeights.bold,
                                  color: state.amountText.isEmpty
                                      ? customColors.semanticRed
                                          .withValues(alpha: 0.45)
                                      : customColors.semanticRed,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                amountStr,
                                maxLines: 1,
                                style: (customTypography.amountLarge).copyWith(
                                  fontSize: isTablet ? 46.0 : 42.sp,
                                  fontWeight: FontWeights.bold,
                                  letterSpacing: -0.5,
                                  color: state.amountText.isEmpty
                                      ? customColors.semanticRed
                                          .withValues(alpha: 0.45)
                                      : customColors.semanticRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 4. Contextual Smart Chips Row (Category, Payment Method, Date)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            // Category Chip
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _pickCategory(
                                  context,
                                  state.selectedCategory,
                                  state.availableCategories,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 11.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        categoryColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color:
                                          categoryColor.withValues(alpha: 0.40),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _parseIcon(state.selectedCategory.icon),
                                        size: 15.sp,
                                        color: categoryColor,
                                      ),
                                      SizedBox(width: 5.w),
                                      Flexible(
                                        child: Text(
                                          state.selectedCategory.name,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeights.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Icon(
                                        Icons.arrow_drop_down_rounded,
                                        size: 16.sp,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Payment Method Chip
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _cyclePaymentMethod(
                                    state.selectedPaymentMethod),
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 11.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLight
                                        ? colorScheme.surfaceContainerLow
                                        : colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.5),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getPaymentMethodIcon(
                                            state.selectedPaymentMethod),
                                        size: 14.sp,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      SizedBox(width: 5.w),
                                      Flexible(
                                        child: Text(
                                          _formatPaymentMethodName(
                                              state.selectedPaymentMethod),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeights.semiBold,
                                            color: colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Icon(
                                        Icons.unfold_more_rounded,
                                        size: 15.sp,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Date Chip
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _pickDate(context, state.selectedDate),
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 11.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLight
                                        ? colorScheme.surfaceContainerLow
                                        : colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.5),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 13.sp,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      SizedBox(width: 5.w),
                                      Flexible(
                                        child: Text(
                                          _formatDateDisplay(
                                              state.selectedDate),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeights.semiBold,
                                            color: colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Recent Expenses Section
                      if (state.recentExpenses.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20.0 : 18.w,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: isTablet ? 14.0 : 13.sp,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.70),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'RECENT EXPENSES',
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  fontSize: isTablet ? 11.0 : 10.5.sp,
                                  fontWeight: FontWeights.bold,
                                  letterSpacing: 1.1,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.70),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Tap to re-fill',
                                style: TextStyle(
                                  fontSize: isTablet ? 11.0 : 10.5.sp,
                                  fontWeight: FontWeights.medium,
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          height: isTablet ? 46.0 : 42.h,
                          margin: EdgeInsets.only(bottom: 8.h),
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 20.0 : 16.w,
                            ),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.recentExpenses.length,
                            separatorBuilder: (context, _) =>
                                SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              final item = state.recentExpenses[index];
                              final itemColor =
                                  _parseColor(item.categoryColorHex);

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _cubit.selectRecentExpense(item);
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? colorScheme.surfaceContainerLowest
                                          : colorScheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant
                                            .withValues(
                                                alpha: isLight ? 0.45 : 0.30),
                                        width: 1.0,
                                      ),
                                      boxShadow: isLight
                                          ? [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.03),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Colored Category Icon Badge
                                        Container(
                                          width: 26.w,
                                          height: 26.w,
                                          decoration: BoxDecoration(
                                            color: itemColor.withValues(
                                                alpha: isLight ? 0.15 : 0.22),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            _parseIcon(item.categoryIcon,
                                                item.categoryName),
                                            size: 14.sp,
                                            color: itemColor,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        // Category Name
                                        Text(
                                          item.categoryName,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeights.semiBold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        // Distinct Amount Pill Tag
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: customColors.semanticRed
                                                .withValues(alpha: 0.10),
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                          ),
                                          child: CompactAmountText(
                                            amount: item.amount,
                                            currencySymbol:
                                                state.defaults.currencySymbol,
                                            showSign: true,
                                            type: TransactionType.expense,
                                            isIncome: false,
                                            compact: true,
                                            animate: false,
                                            style: customTypography
                                                .labelMediumMono
                                                .copyWith(
                                              fontSize:
                                                  isTablet ? 12.0 : 11.5.sp,
                                              fontWeight: FontWeights.bold,
                                              color: customColors.semanticRed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // 5. Numeric Keypad & Action Row
                      QuickAmountKeypad(
                        onKeyPress: (key) {
                          final updated = QuickAmountKeypad.appendKey(
                              state.amountText, key);
                          _cubit.setAmount(updated);
                        },
                        onDeletePress: () {
                          final updated =
                              QuickAmountKeypad.removeLastKey(state.amountText);
                          _cubit.setAmount(updated);
                        },
                        customActionRow: Row(
                          children: [
                            // "+ Add Another" Button
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: isTablet ? 50.0 : 44.h,
                                child: OutlinedButton(
                                  onPressed: state.isValid && !state.isSaving
                                      ? () =>
                                          _cubit.saveExpense(addAnother: true)
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                    side: BorderSide(
                                      color: state.isValid
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    '+ Add Another',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeights.bold,
                                      fontSize: isTablet ? 13.5 : 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            horizontalMarginSmall,

                            // "Save" Primary Button
                            Expanded(
                              flex: 5,
                              child: SizedBox(
                                height: isTablet ? 50.0 : 44.h,
                                child: ElevatedButton(
                                  onPressed: state.isValid && !state.isSaving
                                      ? () =>
                                          _cubit.saveExpense(addAnother: false)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: state.isSaving
                                      ? SizedBox(
                                          width: 18.w,
                                          height: 18.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              colorScheme.onPrimary,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Save',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeights.bold,
                                            fontSize: isTablet ? 14.5 : 14.sp,
                                            color: state.isValid
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface
                                                    .withValues(alpha: 0.38),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 14.0 : 8.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// AutoRoute wrapper page for route-based deep-linking compatibility.
@RoutePage()
class QuickAddPage extends StatelessWidget {
  final int? initialCategoryId;
  final PaymentMethod? initialPaymentMethod;
  final DateTime? initialDate;
  final QuickAddCubit? cubit;

  const QuickAddPage({
    super.key,
    this.initialCategoryId,
    this.initialPaymentMethod,
    this.initialDate,
    this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: QuickAddBottomSheet(
            initialCategoryId: initialCategoryId,
            initialPaymentMethod: initialPaymentMethod,
            initialDate: initialDate,
            cubit: cubit,
          ),
        ),
      ),
    );
  }
}
