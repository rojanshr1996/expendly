import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/financial_summary.dart';

class SummaryCard extends StatelessWidget {
  final FinancialSummary summary;

  const SummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: customColors.surfaceLow,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: customColors.glassStroke, width: 1.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalBalance,
            style: customTypography.labelMediumMono.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          AppSpacing.gapBase,
          Text(
            '${summary.currencySymbol}${summary.totalBalance.toStringAsFixed(2)}',
            style: customTypography.amountLarge,
          ),
          AppSpacing.gapContainer,
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.income,
                  amount:
                      '${summary.currencySymbol}${summary.totalIncome.toStringAsFixed(2)}',
                  color: customColors.semanticGreen,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 36.h,
                color: customColors.glassStroke,
              ),
              Expanded(
                child: _MetricTile(
                  label: l10n.expenses,
                  amount:
                      '${summary.currencySymbol}${summary.totalExpense.toStringAsFixed(2)}',
                  color: customColors.semanticRed,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: color),
              AppSpacing.gapHorizontalTight,
              Text(
                label,
                style: (textTheme.bodyMedium ?? const TextStyle())
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          AppSpacing.gapTight,
          Text(
            amount,
            style: textTheme.titleMedium?.copyWith(
              fontFamily: customTypography.amountDisplay.fontFamily,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
