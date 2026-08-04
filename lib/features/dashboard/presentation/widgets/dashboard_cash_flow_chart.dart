import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/financial_summary.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

enum ChartTimeFilter { weekly, monthly, threeMonths, sixMonths }

/// Helper model for aggregated bar data groups
class _BarDataGroup {
  final String label;
  final double income;
  final double expense;

  const _BarDataGroup({
    required this.label,
    required this.income,
    required this.expense,
  });
}

/// Swipable Chart Carousel offering two dynamic visual views with Date Range Filtering, Clear Indices,
/// and smooth animated header transitions:
/// Filters: [1W] [1M (Default: Current Month)] [3M] [6M]
/// Page 1: Smooth Gradient Line Chart (Cash Flow Trajectory)
/// Page 2: Dual Side-by-Side Bar Chart (Income vs Expense Comparison)
class DashboardCashFlowChart extends StatefulWidget {
  const DashboardCashFlowChart({super.key});

  @override
  State<DashboardCashFlowChart> createState() => _DashboardCashFlowChartState();
}

class _DashboardCashFlowChartState extends State<DashboardCashFlowChart> {
  late final PageController _pageController;
  int _currentPage = 0;

  // Default filter is 1M (Current Month)
  ChartTimeFilter _selectedFilter = ChartTimeFilter.monthly;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<DailyCashFlowPoint> _filterPoints(List<DailyCashFlowPoint> allPoints) {
    if (allPoints.isEmpty) return allPoints;
    final now = DateTime.now();

    switch (_selectedFilter) {
      case ChartTimeFilter.weekly:
        // Last 7 days
        final cutoff = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        return allPoints.where((p) => !p.date.isBefore(cutoff)).toList();

      case ChartTimeFilter.monthly:
        // Current Month (Default)
        return allPoints
            .where((p) => p.date.year == now.year && p.date.month == now.month)
            .toList();

      case ChartTimeFilter.threeMonths:
        // Last 90 days
        final cutoff = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 90));
        return allPoints.where((p) => !p.date.isBefore(cutoff)).toList();

      case ChartTimeFilter.sixMonths:
        // Last 180 days
        final cutoff = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 180));
        return allPoints.where((p) => !p.date.isBefore(cutoff)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor = isLight ? colorScheme.primary : const Color(0xFF00E5FF);

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) return const SizedBox.shrink();
        final rawPoints = state.summary.dailyCashFlow;
        final filteredPoints = _filterPoints(rawPoints);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row with Subtle Animated Title Switch & Carousel Page Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Animated Switcher for Subtle Fade & Slide Header Transition
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    key: ValueKey<int>(_currentPage),
                    children: [
                      Icon(
                        _currentPage == 0
                            ? Icons.show_chart_rounded
                            : Icons.bar_chart_rounded,
                        color: accentColor,
                        size: 20.sp,
                      ),
                      horizontalMarginXXSmall,
                      Text(
                        _currentPage == 0
                            ? '${context.l10n.cashFlow} Trend'
                            : 'Income vs Expense',
                        style: (textTheme.titleMedium ?? const TextStyle())
                            .copyWith(
                          fontWeight: FontWeights.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // Carousel Dots Indicator
                Row(
                  children: [
                    _buildDotIndicator(0),
                    SizedBox(width: 6.w),
                    _buildDotIndicator(1),
                  ],
                ),
              ],
            ),
            verticalMarginSmall,

            // Date Range Filter Selector Pills: [1W] [1M (Default)] [3M] [6M]
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildFilterPill('1W', ChartTimeFilter.weekly),
                SizedBox(width: 6.w),
                _buildFilterPill('1M', ChartTimeFilter.monthly),
                SizedBox(width: 6.w),
                _buildFilterPill('3M', ChartTimeFilter.threeMonths),
                SizedBox(width: 6.w),
                _buildFilterPill('6M', ChartTimeFilter.sixMonths),
              ],
            ),
            verticalMarginSmall,

            // Chart Carousel PageView Container (Compact 205.h height)
            SizedBox(
              height: 205.h,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // Page 1: Smooth Gradient Line Chart
                  _SmoothLineChartPage(
                    points: filteredPoints,
                    filter: _selectedFilter,
                    currencySymbol: state.summary.currencySymbol,
                  ),

                  // Page 2: Dual-Bar Side-by-Side Chart (Supports all filters)
                  _DualBarChartPage(
                    points: filteredPoints,
                    filter: _selectedFilter,
                    currencySymbol: state.summary.currencySymbol,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterPill(String label, ChartTimeFilter filter) {
    final isSelected = _selectedFilter == filter;
    final colorScheme = context.colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor = isLight ? colorScheme.primary : const Color(0xFF00E5FF);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withAlpha((0.25 * 255).round())
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? accentColor
                : colorScheme.outlineVariant.withAlpha((0.3 * 255).round()),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? accentColor : colorScheme.onSurfaceVariant,
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeights.bold : FontWeights.medium,
            fontFamily: 'JetBrainsMono',
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int pageIndex) {
    final isActive = _currentPage == pageIndex;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor =
        isLight ? context.colorScheme.primary : const Color(0xFF00E5FF);

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isActive ? 18.w : 7.w,
        height: 7.h,
        decoration: BoxDecoration(
          color: isActive
              ? accentColor
              : context.colorScheme.outlineVariant
                  .withAlpha((0.5 * 255).round()),
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }
}

// =============================================================================
// PAGE 1: SMOOTH GRADIENT LINE CHART (Cash Flow Trajectory)
// =============================================================================
class _SmoothLineChartPage extends StatelessWidget {
  final List<DailyCashFlowPoint> points;
  final ChartTimeFilter filter;
  final String currencySymbol;

  const _SmoothLineChartPage({
    required this.points,
    required this.filter,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryLineColor =
        isLight ? colorScheme.primary : const Color(0xFF00E5FF);
    final secondaryLineColor = isLight
        ? colorScheme.primary.withValues(alpha: 0.7)
        : const Color(0xFF00F5D4);

    // Build spots dynamically based on filtered points
    final spots = <FlSpot>[];
    if (points.isNotEmpty) {
      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final val = p.income > 0 ? p.income : p.expense;
        spots.add(FlSpot((i + 1).toDouble(), val));
      }
    } else {
      // Fallback display spots
      spots.addAll(const [
        FlSpot(1, 30),
        FlSpot(2, 20),
        FlSpot(3, 18),
        FlSpot(4, 32),
        FlSpot(5, 50),
        FlSpot(6, 32),
        FlSpot(7, 40),
      ]);
    }

    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);
    final topY = maxY <= 0 ? 100.0 : maxY * 1.25;

    return GlassContainer(
      padding: EdgeInsets.only(
        top: 14.h,
        bottom: 12.h,
        left: 12.w,
        right: 18.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clear On-Chart Index & Legend Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: primaryLineColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Net Cash Flow Trajectory',
                    style: customTypography.labelMediumMono.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 11.sp,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Values in ($currencySymbol)',
                  style: customTypography.labelMediumMono.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Line Chart Canvas
          Expanded(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(
                  'line_${filter.name}_${points.length}_${points.isNotEmpty ? points.first.date.millisecondsSinceEpoch : 0}'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, _) {
                final animatedSpots =
                    spots.map((s) => FlSpot(s.x, s.y * animValue)).toList();

                return LineChart(
                  LineChartData(
                    minX: 1,
                    maxX: spots.length.toDouble(),
                    minY: 0,
                    maxY: topY,
                    clipData: const FlClipData.none(),

                    // Grid Lines
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      horizontalInterval:
                          (topY / 3).clamp(1.0, double.infinity),
                      verticalInterval:
                          (spots.length / 4).clamp(1.0, double.infinity),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isLight
                            ? colorScheme.outlineVariant.withValues(alpha: 0.5)
                            : const Color(0xFF2E3B4E)
                                .withAlpha((0.5 * 255).round()),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: isLight
                            ? colorScheme.outlineVariant.withValues(alpha: 0.5)
                            : const Color(0xFF2E3B4E)
                                .withAlpha((0.5 * 255).round()),
                        strokeWidth: 1,
                      ),
                    ),

                    borderData: FlBorderData(show: false),

                    // Axes Labels
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42.w,
                          interval: (topY / 3).clamp(1.0, double.infinity),
                          getTitlesWidget: (value, meta) {
                            if (value <= 0) return const SizedBox.shrink();
                            return Text(
                              '$currencySymbol${_formatCompact(value)}',
                              style: customTypography.labelMediumMono.copyWith(
                                fontSize: 10.sp,
                                color: isLight
                                    ? colorScheme.onSurfaceVariant
                                    : const Color(0xFF8A9BAE),
                                fontWeight: FontWeights.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22.h,
                          interval:
                              (spots.length / 3).clamp(1.0, double.infinity),
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 1 || idx > spots.length) {
                              return const SizedBox.shrink();
                            }

                            String label = '';
                            if (points.isNotEmpty && idx - 1 < points.length) {
                              final d = points[idx - 1].date;
                              if (filter == ChartTimeFilter.weekly) {
                                label = DateFormat('E').format(d).toUpperCase();
                              } else if (filter == ChartTimeFilter.monthly) {
                                label = 'D${d.day}';
                              } else {
                                label =
                                    DateFormat('MMM').format(d).toUpperCase();
                              }
                            } else {
                              final defaultLabels = [
                                'MAR',
                                'JUN',
                                'SEP',
                                'DEC'
                              ];
                              final labelIndex =
                                  ((idx - 1) / (spots.length / 3))
                                      .clamp(0, 3)
                                      .toInt();
                              label = defaultLabels[labelIndex];
                            }

                            return Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Text(
                                label,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  fontSize: 10.sp,
                                  color: isLight
                                      ? colorScheme.onSurfaceVariant
                                      : const Color(0xFF8A9BAE),
                                  fontWeight: FontWeights.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),

                    // Floating Tooltip & Touch Indicator
                    lineTouchData: LineTouchData(
                      enabled: true,
                      getTouchedSpotIndicator: (barData, spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: primaryLineColor,
                              strokeWidth: 2,
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6.r,
                                  color: primaryLineColor,
                                  strokeWidth: 3.r,
                                  strokeColor: isLight
                                      ? colorScheme.surface
                                      : Colors.white,
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => isLight
                            ? colorScheme.surfaceContainerHigh
                            : Colors.white,
                        tooltipBorder: BorderSide.none,
                        tooltipPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        tooltipMargin: 12,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '$currencySymbol${spot.y.toStringAsFixed(1)}',
                              TextStyle(
                                color: primaryLineColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeights.bold,
                                fontFamily: 'JetBrainsMono',
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    // Main Smooth Curve
                    lineBarsData: [
                      LineChartBarData(
                        spots: animatedSpots,
                        isCurved: true,
                        curveSmoothness: 0.45,
                        gradient: LinearGradient(
                          colors: [primaryLineColor, secondaryLineColor],
                        ),
                        barWidth: 3.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              primaryLineColor.withValues(alpha: 0.45),
                              secondaryLineColor.withValues(alpha: 0.02),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}

// =============================================================================
// PAGE 2: DUAL SIDE-BY-SIDE BAR CHART (Income vs Expense Breakdown)
// =============================================================================
class _DualBarChartPage extends StatelessWidget {
  final List<DailyCashFlowPoint> points;
  final ChartTimeFilter filter;
  final String currencySymbol;

  const _DualBarChartPage({
    required this.points,
    required this.filter,
    required this.currencySymbol,
  });

  List<_BarDataGroup> _getBarGroups() {
    if (points.isEmpty) {
      // Fallback display groups
      return const [
        _BarDataGroup(label: 'Mn', income: 2.5, expense: 6.0),
        _BarDataGroup(label: 'Te', income: 7.5, expense: 6.0),
        _BarDataGroup(label: 'Wd', income: 9.0, expense: 2.5),
        _BarDataGroup(label: 'Tu', income: 9.5, expense: 8.8),
        _BarDataGroup(label: 'Fr', income: 8.5, expense: 3.0),
        _BarDataGroup(label: 'St', income: 9.8, expense: 1.2),
        _BarDataGroup(label: 'Sn', income: 5.0, expense: 1.0),
      ];
    }

    final groups = <_BarDataGroup>[];

    if (filter == ChartTimeFilter.weekly) {
      // 7 Daily Groups for Weekly Filter
      final count = points.length.clamp(0, 7);
      final startIndex = points.length - count;
      for (int i = 0; i < count; i++) {
        final p = points[startIndex + i];
        final label = DateFormat('E').format(p.date).substring(0, 2);
        groups.add(
            _BarDataGroup(label: label, income: p.income, expense: p.expense));
      }
    } else if (filter == ChartTimeFilter.monthly) {
      // 4 Weekly Groups for Monthly Filter (W1, W2, W3, W4)
      final w1 = points.where((p) => p.date.day >= 1 && p.date.day <= 7);
      final w2 = points.where((p) => p.date.day >= 8 && p.date.day <= 14);
      final w3 = points.where((p) => p.date.day >= 15 && p.date.day <= 21);
      final w4 = points.where((p) => p.date.day >= 22);

      final wList = [
        MapEntry('W1', w1),
        MapEntry('W2', w2),
        MapEntry('W3', w3),
        MapEntry('W4', w4),
      ];

      for (final entry in wList) {
        final inc = entry.value.fold(0.0, (sum, p) => sum + p.income);
        final exp = entry.value.fold(0.0, (sum, p) => sum + p.expense);
        groups.add(_BarDataGroup(label: entry.key, income: inc, expense: exp));
      }
    } else if (filter == ChartTimeFilter.threeMonths) {
      // 3 Monthly Groups for 3M Filter
      final monthMap = <String, Map<String, double>>{};
      for (final p in points) {
        final key = DateFormat('MMM').format(p.date).toUpperCase();
        monthMap.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0});
        monthMap[key]!['income'] = (monthMap[key]!['income'] ?? 0.0) + p.income;
        monthMap[key]!['expense'] =
            (monthMap[key]!['expense'] ?? 0.0) + p.expense;
      }
      monthMap.forEach((key, val) {
        groups.add(_BarDataGroup(
            label: key, income: val['income']!, expense: val['expense']!));
      });
    } else if (filter == ChartTimeFilter.sixMonths) {
      // 6 Monthly Groups for 6M Filter
      final monthMap = <String, Map<String, double>>{};
      for (final p in points) {
        final key = DateFormat('MMM').format(p.date).toUpperCase();
        monthMap.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0});
        monthMap[key]!['income'] = (monthMap[key]!['income'] ?? 0.0) + p.income;
        monthMap[key]!['expense'] =
            (monthMap[key]!['expense'] ?? 0.0) + p.expense;
      }
      monthMap.forEach((key, val) {
        groups.add(_BarDataGroup(
            label: key, income: val['income']!, expense: val['expense']!));
      });
    }

    return groups.isEmpty
        ? [const _BarDataGroup(label: 'N/A', income: 0, expense: 0)]
        : groups;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    final isLight = Theme.of(context).brightness == Brightness.light;
    final incomeColor =
        isLight ? context.customColors.semanticGreen : const Color(0xFF00E5FF);
    final expenseColor =
        isLight ? context.customColors.semanticRed : const Color(0xFFFF2A6D);

    final barDataGroups = _getBarGroups();
    final maxVal = barDataGroups
        .expand((g) => [g.income, g.expense])
        .fold(0.0, (a, b) => a > b ? a : b);
    final topY = maxVal <= 0 ? 10.0 : maxVal * 1.25;

    return GlassContainer(
      padding: EdgeInsets.only(
        top: 14.h,
        bottom: 12.h,
        left: 12.w,
        right: 16.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clear On-Chart Index & Color Legends Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildLegendDot(incomeColor),
                  SizedBox(width: 4.w),
                  Text(
                    'Income',
                    style: customTypography.labelMediumMono.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 10.sp,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _buildLegendDot(expenseColor),
                  SizedBox(width: 4.w),
                  Text(
                    'Expense',
                    style: customTypography.labelMediumMono.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 10.sp,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Comparison ($currencySymbol)',
                  style: customTypography.labelMediumMono.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Bar Chart Canvas
          Expanded(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(
                  'bar_${filter.name}_${barDataGroups.length}_${points.isNotEmpty ? points.first.date.millisecondsSinceEpoch : 0}'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, _) {
                return BarChart(
                  BarChartData(
                    maxY: topY,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42.w,
                          interval: (topY / 2).clamp(1.0, double.infinity),
                          getTitlesWidget: (value, meta) {
                            if (value <= 0) return const SizedBox.shrink();
                            return Text(
                              '$currencySymbol${_formatCompact(value)}',
                              style: customTypography.labelMediumMono.copyWith(
                                fontSize: 10.sp,
                                color: isLight
                                    ? colorScheme.onSurfaceVariant
                                    : const Color(0xFF7C8BA1),
                                fontWeight: FontWeights.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22.h,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= barDataGroups.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                barDataGroups[idx].label,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  fontSize: 10.sp,
                                  color: isLight
                                      ? colorScheme.onSurfaceVariant
                                      : const Color(0xFF8A9BAE),
                                  fontWeight: FontWeights.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => isLight
                            ? colorScheme.surfaceContainerHigh
                            : Colors.white,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final isIncome = rodIndex == 0;
                          return BarTooltipItem(
                            '${isIncome ? "Income" : "Expense"}: $currencySymbol${rod.toY.toStringAsFixed(1)}',
                            TextStyle(
                              color: isIncome ? incomeColor : expenseColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeights.bold,
                              fontFamily: 'JetBrainsMono',
                            ),
                          );
                        },
                      ),
                    ),
                    barGroups: List.generate(barDataGroups.length, (i) {
                      final g = barDataGroups[i];

                      final incVal = g.income <= 0
                          ? 0.3 * animValue
                          : g.income * animValue;
                      final expVal = g.expense <= 0
                          ? 0.3 * animValue
                          : g.expense * animValue;

                      return BarChartGroupData(
                        x: i,
                        barsSpace: 4.w,
                        barRods: [
                          // Income Bar
                          BarChartRodData(
                            toY: incVal.clamp(0.1, double.infinity),
                            color: incomeColor,
                            width: 7.w,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          // Expense Bar
                          BarChartRodData(
                            toY: expVal.clamp(0.1, double.infinity),
                            color: expenseColor,
                            width: 7.w,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ],
                      );
                    }),
                  ),
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
