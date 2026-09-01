import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/analytics_report.dart';

class ReportTypeSidebar extends StatelessWidget {
  final AnalyticsReport report;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final String? currencySymbol;

  const ReportTypeSidebar({
    super.key,
    required this.report,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.currencySymbol,
  });

  static const List<String> _periods = [
    'This Month',
    'Last Month',
    'This Year',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final resolvedCurrencySymbol = currencySymbol ??
        (getIt.isRegistered<PreferenceService>()
            ? getIt<PreferenceService>().currencySymbol
            : '\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Period',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          ..._periods.map((period) => _buildPeriodTile(context, period)),
          const SizedBox(height: 24.0),
          Text(
            'Key Insights',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          _buildBadge(
            context,
            title: 'Savings Rate',
            value: '${report.savingsRatePercentage.toStringAsFixed(1)}%',
            icon: Icons.savings_outlined,
            color: customColors.semanticGreen,
          ),
          const SizedBox(height: 10.0),
          _buildBadge(
            context,
            title: 'Budget Health',
            value: report.budgetHealthStatus,
            icon: Icons.health_and_safety_outlined,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 10.0),
          _buildBadge(
            context,
            title: 'Avg Daily Spend',
            value:
                '$resolvedCurrencySymbol${report.avgDailySpend.toStringAsFixed(2)}',
            icon: Icons.trending_up_rounded,
            color: customColors.semanticRed,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTile(BuildContext context, String period) {
    final isSelected = period == selectedPeriod;
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => onPeriodChanged(period),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.15)
                : colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : context.customColors.glassStroke,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18.0,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10.0),
              Text(
                period,
                style: TextStyle(
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = context.colorScheme;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(14.0)),
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: color, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: context.customTypography.labelMediumMono.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
