import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/financial_summary.dart';

class DashboardCategoriesDonut extends StatelessWidget {
  final FinancialSummary summary;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const DashboardCategoriesDonut({
    super.key,
    required this.summary,
    this.isPrivacyModeNotifier,
  });

  Color _hexToColor(String hexString, Color fallback) {
    if (hexString.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses =
        summary.recentTransactions.where((t) => !t.isIncome).toList();

    // Calculate totals
    final Map<String, double> categoryTotals = {};
    final Map<String, String> categoryColors = {};
    double totalExpense = 0.0;

    for (final exp in expenses) {
      categoryTotals[exp.categoryName] =
          (categoryTotals[exp.categoryName] ?? 0) + exp.amount;
      categoryColors[exp.categoryName] = exp.colorHex;
      totalExpense += exp.amount;
    }

    // Sort by amount descending
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hasData = sortedCategories.isNotEmpty && totalExpense > 0;

    final List<PieChartSectionData> sections = [];
    final defaultColors = [
      context.colorScheme.primary, // teal
      context.colorScheme.secondary, // indigo
      context.colorScheme.tertiary, // amber
      context.customColors.semanticRed,
      context.customColors.semanticBlue,
      context.customColors.semanticGreen,
    ];

    if (!hasData) {
      sections.add(
        PieChartSectionData(
          color: context.customColors.surfaceLow,
          value: 1,
          title: '',
          radius: 28.0,
          showTitle: false,
        ),
      );
    } else {
      int colorIndex = 0;
      for (final entry in sortedCategories) {
        final categoryName = entry.key;
        final amount = entry.value;
        final hex = categoryColors[categoryName] ?? '';
        final fallback = defaultColors[colorIndex % defaultColors.length];
        final color = _hexToColor(hex, fallback);

        sections.add(
          PieChartSectionData(
            color: color,
            value: amount,
            title: '',
            radius: 28.0,
            showTitle: false,
          ),
        );
        colorIndex++;
      }
    }

    final topCategory = hasData ? sortedCategories.first : null;
    final topPercentage = hasData
        ? ((topCategory!.value / totalExpense) * 100).toStringAsFixed(0)
        : '0';
    final topCategoryTitle = hasData ? topCategory!.key : 'No Expenses';

    return GlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                size: 20.0,
                color: context.colorScheme.primary,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Top Categories',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Chart
          SizedBox(
            height: 180.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 55.0,
                    sections: sections,
                    borderData: FlBorderData(show: false),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topCategoryTitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasData)
                      Text(
                        '$topPercentage%',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20.0),

          // Bottom top 3-4 categories
          if (hasData)
            Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children:
                  sortedCategories.take(4).toList().asMap().entries.map((e) {
                final index = e.key;
                final entry = e.value;
                final amount = entry.value;
                final percentage =
                    ((amount / totalExpense) * 100).toStringAsFixed(0);

                final hex = categoryColors[entry.key] ?? '';
                final fallback = defaultColors[index % defaultColors.length];
                final color = _hexToColor(hex, fallback);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      entry.key,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '$percentage%',
                      style: context.customTypography.labelMediumMono.copyWith(
                        fontSize: 11.0,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
