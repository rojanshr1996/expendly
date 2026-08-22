import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/financial_summary.dart';

class DashboardTabletSummaryRow extends StatelessWidget {
  final FinancialSummary summary;
  final ValueNotifier<bool> isPrivacyModeNotifier;

  const DashboardTabletSummaryRow({
    super.key,
    required this.summary,
    required this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildBalanceCard(context),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildIncomeCard(context),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildExpenseCard(context),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final isPositive = summary.totalBalance >= 0;
    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BALANCE',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(
                isPositive
                    ? Icons.account_balance_rounded
                    : Icons.trending_down_rounded,
                color: isPositive
                    ? context.customColors.semanticGreen
                    : context.customColors.semanticRed,
                size: 20.0,
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          ValueListenableBuilder<bool>(
            valueListenable: isPrivacyModeNotifier,
            builder: (context, isPrivacyMode, child) {
              return CompactAmountText(
                amount: summary.totalBalance,
                isPrivacyMode: isPrivacyMode,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context) {
    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONTHLY INCOME',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color:
                      context.customColors.semanticGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: context.customColors.semanticGreen,
                  size: 16.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          ValueListenableBuilder<bool>(
            valueListenable: isPrivacyModeNotifier,
            builder: (context, isPrivacyMode, child) {
              return CompactAmountText(
                amount: summary.totalIncome,
                isPrivacyMode: isPrivacyMode,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.customColors.semanticGreen,
                ),
              );
            },
          ),
          const SizedBox(height: 8.0),
          Text(
            'Income stream active',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context) {
    final double budgetProgress = summary.monthlyBudgetLimit > 0
        ? (summary.totalExpense / summary.monthlyBudgetLimit).clamp(0.0, 1.0)
        : 0.0;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONTHLY EXPENSES',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color:
                      context.customColors.semanticRed.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_down_rounded,
                  color: context.customColors.semanticRed,
                  size: 16.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          ValueListenableBuilder<bool>(
            valueListenable: isPrivacyModeNotifier,
            builder: (context, isPrivacyMode, child) {
              return CompactAmountText(
                amount: summary.totalExpense,
                isPrivacyMode: isPrivacyMode,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.customColors.semanticRed,
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),
          LinearProgressIndicator(
            value: budgetProgress,
            backgroundColor: context.customColors.surfaceLow,
            color: budgetProgress >= 0.9
                ? context.customColors.semanticRed
                : context.colorScheme.primary,
            borderRadius: BorderRadius.circular(4.0),
            minHeight: 4.0,
          ),
        ],
      ),
    );
  }
}
