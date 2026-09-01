import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/analytics_report.dart';

class ReportInsightsSidebar extends StatelessWidget {
  final AnalyticsReport report;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final String? selectedPeriod;
  final ValueChanged<String>? onPeriodChanged;
  final VoidCallback onExportPdf;
  final VoidCallback onExportCsv;

  const ReportInsightsSidebar({
    super.key,
    required this.report,
    this.isPrivacyModeNotifier,
    this.selectedPeriod,
    this.onPeriodChanged,
    required this.onExportPdf,
    required this.onExportCsv,
  });

  static const List<String> _periods = [
    'This Month',
    'Last Month',
    'This Year',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selectedPeriod != null && onPeriodChanged != null) ...[
            _buildPeriodSelector(context),
            const SizedBox(height: 16.0),
          ],
          _buildHealthScoreCard(context),
          const SizedBox(height: 16.0),
          _buildKeyPerformanceBadges(context),
          const SizedBox(height: 16.0),
          if (report.topCategoryName != null) ...[
            _buildTopCategoryCard(context),
            const SizedBox(height: 16.0),
          ],
          _buildExportActions(context),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Period',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _periods.map((period) {
              final isSelected = period == selectedPeriod;
              return InkWell(
                onTap: () => onPeriodChanged?.call(period),
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : context.customColors.glassStroke
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPerformanceBadges(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Insights',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: customColors.semanticGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: customColors.semanticGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Savings Rate',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${report.savingsRatePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: customColors.semanticGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: customColors.semanticRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: customColors.semanticRed.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avg Daily Spend',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${getIt.isRegistered<PreferenceService>() ? getIt<PreferenceService>().currencySymbol : '\$'}${report.avgDailySpend.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: customColors.semanticRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Health',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56.0,
                    height: 56.0,
                    child: CircularProgressIndicator(
                      value: (report.budgetHealthPercentage / 100.0)
                          .clamp(0.0, 1.0),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: customColors.semanticGreen,
                      strokeWidth: 6.0,
                    ),
                  ),
                  Text(
                    '${report.budgetHealthPercentage.toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color:
                            customColors.semanticGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color:
                              customColors.semanticGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        report.budgetHealthStatus,
                        style: TextStyle(
                          color: customColors.semanticGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Score based on spending vs limit ratios.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoryCard(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: customColors.semanticRed,
                size: 20.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Top Spending',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            report.topCategoryName ?? 'N/A',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (report.topCategoryPercentage != null) ...[
            const SizedBox(height: 4.0),
            Text(
              '${report.topCategoryPercentage!.toStringAsFixed(1)}% of total monthly expenses',
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (report.topCategoryDesc != null &&
              report.topCategoryDesc!.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(
              report.topCategoryDesc!,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportActions(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Export Financial Data',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14.0),
          ElevatedButton.icon(
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18.0),
            label: const Text('Export PDF Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 10.0),
          OutlinedButton.icon(
            onPressed: onExportCsv,
            icon: const Icon(Icons.table_chart_rounded, size: 18.0),
            label: const Text('Export CSV Sheet'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
