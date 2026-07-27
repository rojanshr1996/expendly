import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/financial_summary.dart';

/// Bento Grid section displaying Total Net Balance, Monthly Expenses, Monthly Income, and Budget Progress.
/// Supports Privacy Mode balance obfuscation (`•••••`) and monospaced typography (`JetBrainsMono`) for all figures.
class DashboardBentoGrid extends StatelessWidget {
  final FinancialSummary summary;
  final ValueNotifier<bool> isPrivacyModeNotifier;

  const DashboardBentoGrid({
    super.key,
    required this.summary,
    required this.isPrivacyModeNotifier,
  });

  String _formatAmount(double amount, String symbol, bool isPrivacyMode) {
    if (isPrivacyMode) return '$symbol •••••';
    final formatted = amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$symbol$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    final symbol = summary.currencySymbol;
    final spentPct = summary.totalExpense > 0
        ? (summary.totalExpense / summary.monthlyBudgetLimit).clamp(0.0, 1.0)
        : 0.0;
    final remainingBudget = summary.monthlyBudgetLimit - summary.totalExpense;

    return ValueListenableBuilder<bool>(
      valueListenable: isPrivacyModeNotifier,
      builder: (context, isPrivacyMode, _) {
        return Column(
          children: [
            // Net Total Balance Header Card
            GlassContainer(
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalBalance,
                        style: (textTheme.labelSmall ?? const TextStyle())
                            .copyWith(
                          fontWeight: FontWeights.bold,
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      verticalMarginXXSmall,
                      Text(
                        _formatAmount(
                            summary.totalBalance, symbol, isPrivacyMode),
                        style: (customTypography.amountLarge).copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primary.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color:
                            colorScheme.primary.withAlpha((0.3 * 255).round()),
                      ),
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      color: colorScheme.primary,
                      size: 26.sp,
                    ),
                  ),
                ],
              ),
            ),
            verticalMarginSmall,

            // 3-Card Bento Grid Layout
            Row(
              children: [
                // Monthly Expenses Bento Card
                Expanded(
                  child: GlassContainer(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_down_rounded,
                                color: AppColors.semanticRed, size: 18.sp),
                            horizontalMarginXXSmall,
                            Text(
                              l10n.expenses.toUpperCase(),
                              style: (textTheme.labelSmall ?? const TextStyle())
                                  .copyWith(
                                fontWeight: FontWeights.bold,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        verticalMarginXXSmall,
                        Text(
                          _formatAmount(
                              summary.totalExpense, symbol, isPrivacyMode),
                          style: (customTypography.amountDisplay).copyWith(
                            color: AppColors.semanticRed,
                            fontSize: 20.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        verticalMarginXXSmall,
                        Text(
                          '↑ 12% vs last month',
                          style: (textTheme.labelSmall ?? const TextStyle())
                              .copyWith(
                            color: AppColors.semanticRed,
                            fontWeight: FontWeights.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                horizontalMarginSmall,

                // Monthly Income Bento Card
                Expanded(
                  child: GlassContainer(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up_rounded,
                                color: AppColors.semanticGreen, size: 18.sp),
                            horizontalMarginXXSmall,
                            Text(
                              l10n.income.toUpperCase(),
                              style: (textTheme.labelSmall ?? const TextStyle())
                                  .copyWith(
                                fontWeight: FontWeights.bold,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        verticalMarginXXSmall,
                        Text(
                          _formatAmount(
                              summary.totalIncome, symbol, isPrivacyMode),
                          style: (customTypography.amountDisplay).copyWith(
                            color: AppColors.semanticGreen,
                            fontSize: 20.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        verticalMarginXXSmall,
                        Text(
                          'On track for goals',
                          style: (textTheme.labelSmall ?? const TextStyle())
                              .copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            verticalMarginSmall,

            // Monthly Budget Progress Bento Card
            GlassContainer(
              padding: EdgeInsets.all(16.w),
              borderStrokeColor:
                  colorScheme.primary.withAlpha((0.2 * 255).round()),
              backgroundColor:
                  colorScheme.primary.withAlpha((0.05 * 255).round()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              color: colorScheme.primary, size: 18.sp),
                          horizontalMarginXXSmall,
                          Text(
                            'REMAINING BUDGET',
                            style: (textTheme.labelSmall ?? const TextStyle())
                                .copyWith(
                              fontWeight: FontWeights.bold,
                              color: colorScheme.primary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(spentPct * 100).toInt()}% limit spent',
                        style: (textTheme.labelSmall ?? const TextStyle())
                            .copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeights.bold,
                        ),
                      ),
                    ],
                  ),
                  verticalMarginXXSmall,
                  Text(
                    _formatAmount(remainingBudget, symbol, isPrivacyMode),
                    style: (customTypography.amountDisplay).copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  verticalMarginSmall,

                  // Spending Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: spentPct,
                      minHeight: 6.h,
                      backgroundColor:
                          Colors.white.withAlpha((0.1 * 255).round()),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        spentPct > 0.85
                            ? AppColors.semanticRed
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
