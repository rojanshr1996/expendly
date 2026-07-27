import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/financial_summary.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

/// Animated line chart showing daily income vs expense for the current month.
/// Data is sourced from the database via [DashboardCubit].
/// Uses fl_chart with a draw animation triggered on first build.
class DashboardCashFlowChart extends StatefulWidget {
  const DashboardCashFlowChart({super.key});

  @override
  State<DashboardCashFlowChart> createState() => _DashboardCashFlowChartState();
}

class _DashboardCashFlowChartState extends State<DashboardCashFlowChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) return const SizedBox.shrink();
        final points = state.summary.dailyCashFlow;
        if (points.isEmpty) return const SizedBox.shrink();

        return _CashFlowLineChart(
          points: points,
          animation: _animation,
          currencySymbol: state.summary.currencySymbol,
        );
      },
    );
  }
}

class _CashFlowLineChart extends StatelessWidget {
  final List<DailyCashFlowPoint> points;
  final Animation<double> animation;
  final String currencySymbol;

  const _CashFlowLineChart({
    required this.points,
    required this.animation,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    const incomeColor = AppColors.semanticGreen;
    const expenseColor = AppColors.semanticRed;

    // Build FlSpots for income and expense
    final incomeSpots =
        points.map((p) => FlSpot(p.day.toDouble(), p.income)).toList();
    final expenseSpots =
        points.map((p) => FlSpot(p.day.toDouble(), p.expense)).toList();

    // Find max Y for scaling
    final allValues = points
        .expand((p) => [p.income, p.expense])
        .where((v) => v > 0)
        .toList();
    final maxY =
        allValues.isEmpty ? 100.0 : allValues.reduce((a, b) => a > b ? a : b);
    final yInterval = _niceInterval(maxY);

    // X axis: show only a few labels to avoid clutter
    final totalDays = points.length;
    final xInterval = totalDays <= 7 ? 1.0 : (totalDays / 5).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.cashFlow,
              style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeights.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                _buildLegend(incomeColor, context.l10n.income, textTheme),
                horizontalMarginSmall,
                _buildLegend(expenseColor, context.l10n.expenses, textTheme),
              ],
            ),
          ],
        ),
        verticalMarginSmall,

        GlassContainer(
          padding: EdgeInsets.only(
            top: 20.h,
            bottom: 8.h,
            left: 8.w,
            right: 16.w,
          ),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final progress = animation.value;
              // Clip the spots to animate the draw from left to right
              final animatedIncome = _clipSpots(incomeSpots, progress);
              final animatedExpense = _clipSpots(expenseSpots, progress);

              return SizedBox(
                height: 180.h,
                child: LineChart(
                  LineChartData(
                    minX: 1,
                    maxX: totalDays.toDouble(),
                    minY: 0,
                    maxY: maxY * 1.15, // 15% headroom
                    clipData: const FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: yInterval,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: colorScheme.outlineVariant
                            .withAlpha((0.4 * 255).round()),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44.w,
                          interval: yInterval,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            return Text(
                              _formatCompact(value, currencySymbol),
                              style: customTypography.labelMediumMono.copyWith(
                                fontSize: 9.sp,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20.h,
                          interval: xInterval,
                          getTitlesWidget: (value, meta) {
                            final day = value.toInt();
                            if (day < 1 || day > totalDays) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '$day',
                              style: customTypography.labelMediumMono.copyWith(
                                fontSize: 9.sp,
                                color: colorScheme.onSurfaceVariant,
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
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) =>
                            colorScheme.surfaceContainerHigh,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final isIncome = spot.barIndex == 0;
                            return LineTooltipItem(
                              '${isIncome ? '▲' : '▼'} $currencySymbol${spot.y.toStringAsFixed(2)}',
                              (textTheme.labelSmall ?? const TextStyle())
                                  .copyWith(
                                color: isIncome ? incomeColor : expenseColor,
                                fontWeight: FontWeights.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      // Income line
                      LineChartBarData(
                        spots: animatedIncome,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: incomeColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, pct, bar, idx) =>
                              FlDotCirclePainter(
                            radius: 3,
                            color: incomeColor,
                            strokeWidth: 1.5,
                            strokeColor: colorScheme.surface,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              incomeColor.withAlpha((0.25 * 255).round()),
                              incomeColor.withAlpha((0.02 * 255).round()),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Expense line
                      LineChartBarData(
                        spots: animatedExpense,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: expenseColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, pct, bar, idx) =>
                              FlDotCirclePainter(
                            radius: 3,
                            color: expenseColor,
                            strokeWidth: 1.5,
                            strokeColor: colorScheme.surface,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              expenseColor.withAlpha((0.2 * 255).round()),
                              expenseColor.withAlpha((0.01 * 255).round()),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Clips spots to simulate a left-to-right draw animation.
  List<FlSpot> _clipSpots(List<FlSpot> spots, double progress) {
    if (spots.isEmpty) return spots;
    if (progress >= 1.0) return spots;
    final maxX = spots.last.x;
    final minX = spots.first.x;
    final cutX = minX + (maxX - minX) * progress;
    return spots.where((s) => s.x <= cutX).toList();
  }

  /// Returns a "nice" Y interval for the grid lines.
  double _niceInterval(double maxY) {
    if (maxY <= 0) return 50;
    if (maxY <= 100) return 25;
    if (maxY <= 500) return 100;
    if (maxY <= 2000) return 500;
    if (maxY <= 10000) return 2000;
    return (maxY / 4).roundToDouble();
  }

  /// Compact number formatting for axis labels (e.g. 1200 → "1.2k").
  String _formatCompact(double value, String symbol) {
    if (value >= 1000) {
      return '$symbol${(value / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol${value.toStringAsFixed(0)}';
  }

  Widget _buildLegend(Color color, String label, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        horizontalMarginXXSmall,
        Text(
          label,
          style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
