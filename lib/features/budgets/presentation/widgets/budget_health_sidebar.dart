import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/budget_item.dart';

class BudgetHealthSidebar extends StatelessWidget {
  final List<BudgetItem> budgets;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const BudgetHealthSidebar({
    super.key,
    required this.budgets,
    this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customColors = context.customColors;

    double totalTarget = 0;
    double totalSpent = 0;

    for (final b in budgets) {
      totalTarget += b.targetAmount;
      totalSpent += b.spentAmount;
    }

    final totalRemaining =
        (totalTarget - totalSpent).clamp(0.0, double.infinity);
    final double overallProgress =
        totalTarget > 0 ? (totalSpent / totalTarget) : 0;

    String status = 'Healthy';
    Color statusColor = customColors.semanticGreen;
    if (overallProgress > 1.0) {
      status = 'Over Budget';
      statusColor = customColors.semanticRed;
    } else if (overallProgress > 0.8) {
      status = 'Warning';
      statusColor = const Color(0xFFFFAC5A);
    }

    final overBudgetItems = budgets.where((b) => b.isOverBudget).toList();
    final nearingLimitItems = budgets.where((b) => b.isWarning).toList();

    String insightText =
        '✅ Great Job! Your spending is well within budget limits.';
    if (overBudgetItems.isNotEmpty) {
      insightText =
          '⚠️ Over Budget Alert: Review recent expenses in ${overBudgetItems.first.categoryName}.';
    } else if (nearingLimitItems.isNotEmpty) {
      final item = nearingLimitItems.first;
      insightText =
          '⚡ Nearing Limit: ${item.categoryName} has reached ${(item.progressPercentage * 100).toInt()}% of its limit.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Total Budget Health Card
          GlassContainer(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Budget Health',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: LinearProgressIndicator(
                    value: overallProgress.clamp(0.0, 1.0),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8.0,
                  ),
                ),
                const SizedBox(height: 14.0),

                // Spent / Target / Remaining rows
                _buildStatRow(
                  context,
                  label: 'Total Spent',
                  amount: totalSpent,
                  color: totalSpent > totalTarget
                      ? customColors.semanticRed
                      : colorScheme.onSurface,
                ),
                const SizedBox(height: 8.0),
                _buildStatRow(
                  context,
                  label: 'Total Budgeted',
                  amount: totalTarget,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8.0),
                _buildStatRow(
                  context,
                  label: 'Remaining Pool',
                  amount: totalRemaining,
                  color: customColors.semanticGreen,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // 2. Spending Velocity Card
          GlassContainer(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      size: 20.0,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Spending Pace',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  overallProgress > 0.8
                      ? 'You are burning through budgets faster than usual this cycle.'
                      : 'Your spending pace is healthy and aligned with your monthly goals.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // 3. Smart Insights Card
          GlassContainer(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 20.0,
                      color: Color(0xFFFFD54F),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Smart Insights',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  insightText,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
          builder: (context, isPrivacy, _) {
            return CompactAmountText(
              amount: amount,
              isPrivacyMode: isPrivacy,
              style: context.customTypography.labelMediumMono.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }
}
