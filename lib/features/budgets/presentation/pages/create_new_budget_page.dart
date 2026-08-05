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
import '../../../../core/ads/interstitial_ad_helper.dart';
import '../../../../core/widgets/category_picker_sheet.dart';
import '../../../../core/widgets/status_components.dart';
import '../../../transactions/domain/entities/category_item.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';

@RoutePage()
class CreateNewBudgetPage extends StatefulWidget {
  final VoidCallback? onSaved;

  const CreateNewBudgetPage({super.key, this.onSaved});

  @override
  State<CreateNewBudgetPage> createState() => _CreateNewBudgetPageState();
}

class _CreateNewBudgetPageState extends State<CreateNewBudgetPage> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final ValueNotifier<CategoryItem?> _selectedCategoryNotifier =
      ValueNotifier<CategoryItem?>(null);

  List<CategoryItem> _expenseCategories = [];

  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  bool _notifyAtThreshold = true;
  final int _thresholdPercentage = 80;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    InterstitialAdHelper.loadAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final db = getIt<AppDatabase>();
      final rows = await db.select(db.categories).get();
      if (mounted) {
        setState(() {
          _expenseCategories = rows
              .where((r) => r.type == TransactionType.expense)
              .map((r) => CategoryItem(
                    id: r.id,
                    name: r.name,
                    icon: r.icon,
                    colorHex: r.color,
                    type: r.type,
                  ))
              .toList();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _selectedCategoryNotifier.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      StatusComponents.showToast(
        context,
        message: context.l10n.enterTargetAmountError,
        isError: true,
      );
      return;
    }

    final budgetCubit = getIt<BudgetCubit>();
    await budgetCubit.setBudget(
      categoryId: _selectedCategoryNotifier.value?.id,
      targetAmount: amount,
      period: _selectedPeriod,
      notifyAtThreshold: _notifyAtThreshold,
      thresholdPercentage: _thresholdPercentage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final currencySymbol = getIt<PreferenceService>().currencySymbol;

    return BlocProvider.value(
      value: getIt<BudgetCubit>(),
      child: BlocListener<BudgetCubit, BudgetState>(
        listener: (context, state) {
          if (state is BudgetActionSuccess) {
            StatusComponents.showToast(
              context,
              message: state.message,
              isSuccess: true,
            );
            widget.onSaved?.call();
            context.router.maybePop(true);
          } else if (state is BudgetError) {
            StatusComponents.showToast(
              context,
              message: state.message,
              isError: true,
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
                onPressed: () => context.router.maybePop(),
              ),
              title: Text(
                'Add Budget',
                style: (textTheme.titleLarge ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: const [],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              verticalMarginMedium,

                              // Amount Display Section matching modern_add_transaction_page.dart
                              Column(
                                children: [
                                  Text(
                                    'LIMIT AMOUNT',
                                    style: customTypography.labelMediumMono
                                        .copyWith(
                                      color: colorScheme.outline,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  verticalMarginXSmall,
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$currencySymbol ',
                                          style: customTypography
                                              .headlineLargeMonoBold
                                              .copyWith(
                                            color: colorScheme.primary,
                                            fontSize: 42.sp,
                                          ),
                                        ),
                                        IntrinsicWidth(
                                          child: TextField(
                                            controller: _amountController,
                                            focusNode: _amountFocusNode,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            style: customTypography
                                                .headlineLargeMonoBold
                                                .copyWith(
                                              color: colorScheme.primary,
                                              fontSize: 42.sp,
                                            ),
                                            cursorColor: colorScheme.primary,
                                            decoration: InputDecoration(
                                              filled: false,
                                              fillColor: Colors.transparent,
                                              hintText: '0',
                                              hintStyle: customTypography
                                                  .headlineLargeMonoBold
                                                  .copyWith(
                                                color: colorScheme.primary
                                                    .withValues(alpha: 0.4),
                                                fontSize: 42.sp,
                                              ),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              verticalMarginLarge,

                              // Category Selector Button (Bottom Sheet Approach using CategoryPickerSheet)
                              Text(
                                context.l10n.categoryLabel,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              verticalMarginXSmall,
                              ValueListenableBuilder<CategoryItem?>(
                                valueListenable: _selectedCategoryNotifier,
                                builder: (context, selectedCat, _) {
                                  final catName = selectedCat?.name ??
                                      context.l10n.overallMonthlyLimit;
                                  final catColor = _parseColor(
                                      selectedCat?.colorHex ?? '#57F1DB',
                                      colorScheme.primary);
                                  final iconData = _getIconData(
                                      selectedCat?.icon ?? 'all_inclusive');

                                  return InkWell(
                                    onTap: () async {
                                      final picked =
                                          await CategoryPickerSheet.show(
                                        context: context,
                                        categories: _expenseCategories,
                                        selectedCategory: selectedCat,
                                        initialType: TransactionType.expense,
                                        allowOverallLimitOption: true,
                                      );
                                      setState(() {
                                        _selectedCategoryNotifier.value =
                                            picked;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: Container(
                                      height: 56.h,
                                      padding: horizontalPaddingMedium,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius:
                                            BorderRadius.circular(16.r),
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
                                                  color: catColor.withValues(
                                                      alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
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
                                                style: customTypography
                                                    .bodyLargeBold
                                                    .copyWith(
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

                              verticalMarginLarge,

                              // Renewal Period Section
                              Text(
                                'Renewal Period',
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: colorScheme.outlineVariant),
                                ),
                                child: Row(
                                  children: [
                                    _buildPeriodTab(
                                      label: 'Weekly',
                                      period: BudgetPeriod.weekly,
                                    ),
                                    _buildPeriodTab(
                                      label: 'Monthly',
                                      period: BudgetPeriod.monthly,
                                    ),
                                    _buildPeriodTab(
                                      label: 'Yearly',
                                      period: BudgetPeriod.yearly,
                                    ),
                                  ],
                                ),
                              ),

                              verticalMarginMedium,

                              // Threshold Alert Toggle Section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: colorScheme.outlineVariant),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Threshold Alert',
                                          style: customTypography.bodyLargeBold
                                              .copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Notify me when I reach $_thresholdPercentage%',
                                          style: customTypography.bodyMedium
                                              .copyWith(
                                            color: colorScheme.outline,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: _notifyAtThreshold,
                                      activeColor: colorScheme.primary,
                                      activeTrackColor: colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      inactiveThumbColor: colorScheme.outline,
                                      inactiveTrackColor:
                                          colorScheme.surfaceContainerHigh,
                                      onChanged: (val) {
                                        setState(() {
                                          _notifyAtThreshold = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              verticalMarginLarge,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Area: Save Button
                  Container(
                    color: colorScheme.surfaceContainerLow,
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 24.w,
                      top: 12.h,
                      bottom: 12.h + MediaQuery.of(context).viewPadding.bottom,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _saveBudget,
                      icon: const Icon(Icons.add_circle_rounded, size: 22),
                      label: Text(
                        context.l10n.createBudget,
                        style: customTypography.headlineMediumMonoBold.copyWith(
                          color: colorScheme.onPrimary,
                          fontSize: 16.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
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

  Widget _buildPeriodTab(
      {required String label, required BudgetPeriod period}) {
    final colorScheme = context.colorScheme;
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.customTypography.labelMediumMono.copyWith(
              color: isSelected ? colorScheme.onPrimary : colorScheme.outline,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
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
      default:
        return Icons.all_inclusive_rounded;
    }
  }
}
