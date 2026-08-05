import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../domain/entities/financial_summary.dart';

/// Bento Grid section displaying Net Balance (compact), Monthly Expenses, and Monthly Income.
/// Uses [CompactAmountText] to format amounts >= 100,000 using K, M, B notation and prevents layout overflows.
/// Tapping an amount displays an interactive overlay tooltip showing the full exact un-truncated amount.
class DashboardBentoGrid extends StatelessWidget {
  final FinancialSummary summary;
  final ValueNotifier<bool> isPrivacyModeNotifier;

  const DashboardBentoGrid({
    super.key,
    required this.summary,
    required this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    final isNegativeBalance = summary.totalBalance < 0;

    // Balance color: green when positive, red when negative, muted when zero
    final balanceColor = summary.totalBalance > 0
        ? customColors.semanticGreen
        : isNegativeBalance
            ? customColors.semanticRed
            : colorScheme.onSurfaceVariant;

    return ValueListenableBuilder<bool>(
      valueListenable: isPrivacyModeNotifier,
      builder: (context, isPrivacyMode, _) {
        return Column(
          children: [
            // Compact Net Balance row — Liquid Glass Card
            _DashboardLiquidGlassCard(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // Balance icon tinted with balance color
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: balanceColor.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      isNegativeBalance
                          ? Icons.trending_down_rounded
                          : Icons.account_balance_rounded,
                      color: balanceColor,
                      size: 20.sp,
                    ),
                  ),
                  horizontalMarginSmall,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.totalBalance.toUpperCase(),
                          style: (textTheme.labelSmall ?? const TextStyle())
                              .copyWith(
                            fontWeight: FontWeights.bold,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        CompactAmountText(
                          amount: summary.totalBalance,
                          isPrivacyMode: isPrivacyMode,
                          style: customTypography.labelMediumMono.copyWith(
                            color: balanceColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeights.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  horizontalMarginSmall,
                  // Net change pill
                  if (!isPrivacyMode)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: balanceColor.withAlpha((0.12 * 255).round()),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        isNegativeBalance ? l10n.overspent : l10n.netPositive,
                        style: (textTheme.labelSmall ?? const TextStyle())
                            .copyWith(
                          color: balanceColor,
                          fontWeight: FontWeights.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            verticalMarginSmall,

            // Two-card row: Expenses | Income
            Row(
              children: [
                // Monthly Expenses Bento Liquid Glass Card
                Expanded(
                  child: _DashboardLiquidGlassCard(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_down_rounded,
                                color: customColors.semanticRed, size: 18.sp),
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
                        CompactAmountText(
                          amount: summary.totalExpense,
                          isPrivacyMode: isPrivacyMode,
                          style: (customTypography.amountDisplay).copyWith(
                            color: customColors.semanticRed,
                            fontSize: 20.sp,
                          ),
                        ),
                        verticalMarginXXSmall,
                        Text(
                          l10n.thisMonth,
                          style: (textTheme.labelSmall ?? const TextStyle())
                              .copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                horizontalMarginSmall,

                // Monthly Income Bento Liquid Glass Card
                Expanded(
                  child: _DashboardLiquidGlassCard(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up_rounded,
                                color: customColors.semanticGreen, size: 18.sp),
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
                        CompactAmountText(
                          amount: summary.totalIncome,
                          isPrivacyMode: isPrivacyMode,
                          style: (customTypography.amountDisplay).copyWith(
                            color: customColors.semanticGreen,
                            fontSize: 20.sp,
                          ),
                        ),
                        verticalMarginXXSmall,
                        Text(
                          l10n.thisMonth,
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
          ],
        );
      },
    );
  }
}

class _DashboardLiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _DashboardLiquidGlassCard({
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = BorderRadius.circular(16.r);

    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.20),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.25),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.15),
                ],
        ),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.50)
              : customColors.glassStroke.withValues(alpha: 0.40),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.5 : 0.0),
            blurRadius: 6.r,
            spreadRadius: -1.r,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.18),
            blurRadius: 12.r,
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
