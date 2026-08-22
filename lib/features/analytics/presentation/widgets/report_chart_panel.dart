import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/analytics_report.dart';

class ReportChartPanel extends StatelessWidget {
  final AnalyticsReport report;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const ReportChartPanel({
    super.key,
    required this.report,
    this.isPrivacyModeNotifier,
  });

  Color _parseColor(String hex, Color fallback) {
    if (hex.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Metric Summary Cards
          _buildSummaryCards(context),
          const SizedBox(height: 16.0),

          // 2. Cash Flow Bar Chart
          _buildBarChart(context),
          const SizedBox(height: 16.0),

          // 3. Category Breakdown Section
          _buildCategoryBreakdown(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final customColors = context.customColors;
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Total Income',
            amount: report.totalIncome,
            isPrivacyModeNotifier: isPrivacyModeNotifier,
            color: customColors.semanticGreen,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _MetricCard(
            title: 'Total Expense',
            amount: report.totalExpense,
            isPrivacyModeNotifier: isPrivacyModeNotifier,
            color: customColors.semanticRed,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _MetricCard(
            title: 'Net Savings',
            amount: report.netSavings,
            isPrivacyModeNotifier: isPrivacyModeNotifier,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Cash Flow Activity',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Flexible(
                flex: 2,
                child: Text(
                  report.periodName,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            height: 200.0,
            child: report.dailyFlows.isEmpty
                ? Center(
                    child: Text(
                      'No cash flow data for this period',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: report.dailyFlows
                              .map((e) => e.amount)
                              .fold(0.0, (a, b) => a > b ? a : b) *
                          1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) =>
                              colorScheme.surfaceContainerHigh,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final flow = report.dailyFlows[group.x.toInt()];
                            return BarTooltipItem(
                              '${flow.label}\n\$${flow.amount.toStringAsFixed(2)}',
                              TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 ||
                                  index >= report.dailyFlows.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  report.dailyFlows[index].label,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: report.dailyFlows.asMap().entries.map((entry) {
                        final index = entry.key;
                        final flow = entry.value;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: flow.amount,
                              color: flow.isPeak
                                  ? customColors.semanticRed
                                  : colorScheme.primary,
                              width: 14.0,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context) {
    final colorScheme = context.colorScheme;
    final categories = report.categoryBreakdowns;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16.0),
          if (categories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No category expenses recorded',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 160.0,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: categories.map((cat) {
                    final color =
                        _parseColor(cat.colorHex, colorScheme.primary);
                    return PieChartSectionData(
                      color: color,
                      value: cat.amount,
                      title: '${cat.percentage.toInt()}%',
                      radius: 35,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ...categories.map((cat) {
              final color = _parseColor(cat.colorHex, colorScheme.primary);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        cat.categoryName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable:
                          isPrivacyModeNotifier ?? ValueNotifier<bool>(false),
                      builder: (context, isPrivacy, _) {
                        return CompactAmountText(
                          amount: cat.amount,
                          isPrivacyMode: isPrivacy,
                          style:
                              context.customTypography.labelMediumMono.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '(${cat.percentage.toStringAsFixed(1)}%)',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final double amount;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.amount,
    this.isPrivacyModeNotifier,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(14.0)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),
          ValueListenableBuilder<bool>(
            valueListenable:
                isPrivacyModeNotifier ?? ValueNotifier<bool>(false),
            builder: (context, isPrivacy, _) {
              return CompactAmountText(
                amount: amount,
                isPrivacyMode: isPrivacy,
                style: context.customTypography.amountDisplay.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
