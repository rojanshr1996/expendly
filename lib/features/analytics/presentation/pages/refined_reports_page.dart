import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

import '../../../../core/ads/ad_helper.dart';
import '../../../../core/ads/interstitial_ad_helper.dart';
import '../../../../core/ads/widgets/banner_ad_widget.dart';
import '../../../../core/constants/margin_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/data_export_import_service.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/status_components.dart';
import '../../data/datasources/analytics_local_datasource.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics_report.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';
import '../widgets/reports_shimmer.dart';

class RefinedReportsPage extends StatefulWidget {
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const RefinedReportsPage({super.key, this.isPrivacyModeNotifier});

  @override
  State<RefinedReportsPage> createState() => _RefinedReportsPageState();
}

class _RefinedReportsPageState extends State<RefinedReportsPage> {
  late final AnalyticsCubit _cubit;

  @override
  void initState() {
    super.initState();
    try {
      _cubit = getIt<AnalyticsCubit>();
    } catch (_) {
      final db = getIt<AppDatabase>();
      final ds = AnalyticsLocalDataSourceImpl(db);
      final repo = AnalyticsRepositoryImpl(ds);
      _cubit = AnalyticsCubit(repo);
    }
    if (_cubit.state is! AnalyticsLoaded) {
      _cubit.loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return BlocProvider<AnalyticsCubit>.value(
      value: _cubit,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              leading: ModalRoute.of(context)?.canPop == true
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
              title: Text(
                l10n.reports,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeights.bold,
                ),
              ),
              actions: [
                BlocBuilder<AnalyticsCubit, AnalyticsState>(
                  builder: (context, state) {
                    if (state is! AnalyticsLoaded) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      tooltip: 'Download Financial Report',
                      icon: Icon(
                        Icons.file_download_rounded,
                        color: colorScheme.primary,
                        size: 24.sp,
                      ),
                      onPressed: () => _exportReport(context, state.report),
                    );
                  },
                ),
              ],
            ),
            body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStateContent(
                    context: context,
                    state: state,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    customTypography: customTypography,
                    l10n: l10n,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateContent({
    required BuildContext context,
    required AnalyticsState state,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required dynamic customTypography,
    required dynamic l10n,
  }) {
    return ValueListenableBuilder<String>(
      valueListenable: getIt<PreferenceService>().currencySymbolNotifier,
      builder: (context, currencySymbol, _) {
        if (state is AnalyticsLoading) {
          return const ReportsShimmer(key: ValueKey('loading'));
        }
        if (state is AnalyticsLoaded) {
          final report = state.report;
          final isEmpty = report.totalIncome == 0 &&
              report.totalExpense == 0 &&
              report.categoryBreakdowns.isEmpty;

          return Stack(
            children: [
              // 1. Scrollable Reports Content (All original report cards scroll UNDER the pinned liquid glass tab bar)
              Positioned.fill(
                child: RefreshIndicator(
                  key: const ValueKey('reports_content'),
                  color: colorScheme.primary,
                  onRefresh: () =>
                      context.read<AnalyticsCubit>().loadAnalytics(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      top: 60.h,
                      bottom: 120.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isEmpty)
                          _StaggeredEntrance(
                            delayMs: 0,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24.w),
                              margin: EdgeInsets.only(top: 20.h),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: colorScheme.outlineVariant),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart_outlined,
                                    size: 56.sp,
                                    color: colorScheme.outline,
                                  ),
                                  verticalMarginMedium,
                                  Text(
                                    l10n.noFinancialReportsYet,
                                    style: textTheme.titleLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeights.bold,
                                    ),
                                  ),
                                  verticalMarginSmall,
                                  Text(
                                    'No transactions recorded for the selected period (${report.periodName}). Select a different period or date range above.',
                                    textAlign: TextAlign.center,
                                    style: customTypography.bodyMedium.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  verticalMarginMedium,
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context
                                          .read<AnalyticsCubit>()
                                          .loadAnalytics(period: 'Monthly');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    icon: Icon(Icons.refresh_rounded,
                                        size: 18.sp),
                                    label: Text(
                                      'Show Monthly View',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeights.bold,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          // Net Cash Flow Overview Card (Delay 0ms) - Matching top card in reference image
                          _StaggeredEntrance(
                            delayMs: 0,
                            child: _NetCashFlowCard(
                              report: report,
                              currencySymbol: currencySymbol,
                              isPrivacyModeNotifier:
                                  widget.isPrivacyModeNotifier,
                            ),
                          ),
                          verticalMarginMedium,

                          // Banner Ad
                          BannerAdWidget(adUnitId: AdHelper.bannerAdUnitId),
                          verticalMarginMedium,

                          // Distribution Donut Chart Card (Delay 50ms) - Matching second card in reference image
                          _StaggeredEntrance(
                            delayMs: 50,
                            child: _DistributionDonutChartCard(
                              report: report,
                            ),
                          ),
                          verticalMarginMedium,

                          // Net Flow Hero Card with Dynamic Flow Bar Chart (Delay 100ms)
                          _StaggeredEntrance(
                            delayMs: 100,
                            child: _NetFlowHeroCard(
                              report: report,
                              currencySymbol: currencySymbol,
                              isPrivacyModeNotifier:
                                  widget.isPrivacyModeNotifier,
                            ),
                          ),
                          verticalMarginMedium,

                          // Insights Bento Grid (Delay 150ms)
                          _StaggeredEntrance(
                            delayMs: 150,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _AvgDailySpendCard(
                                    report: report,
                                    currencySymbol: currencySymbol,
                                    isPrivacyModeNotifier:
                                        widget.isPrivacyModeNotifier,
                                  ),
                                ),
                                horizontalMarginSmall,
                                Expanded(
                                  child: _BudgetHealthCard(
                                    report: report,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          verticalMarginMedium,

                          // Top Category Highlight Trend Card (Delay 200ms)
                          if (report.topCategoryName != null) ...[
                            _StaggeredEntrance(
                              delayMs: 200,
                              child: _TopCategoryTrendCard(report: report),
                            ),
                            verticalMarginMedium,
                          ],

                          // Category Breakdown Section Header (Delay 240ms)
                          _StaggeredEntrance(
                            delayMs: 240,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.expenseBreakdownByCategory,
                                  style:
                                      customTypography.labelMediumMono.copyWith(
                                    color: colorScheme.outline,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'View All',
                                  style:
                                      customTypography.labelMediumMono.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeights.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          verticalMarginSmall,

                          // Category Breakdown Rows (Delay 280ms + idx * 40ms)
                          ...report.categoryBreakdowns
                              .asMap()
                              .entries
                              .map((entry) {
                            final idx = entry.key;
                            final cat = entry.value;
                            return _StaggeredEntrance(
                              delayMs: 280 + (idx * 40),
                              child: _CategoryBreakdownRow(
                                item: cat,
                                isPrivacyModeNotifier:
                                    widget.isPrivacyModeNotifier,
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Fixed Non-Scrollable Pinned Liquid Glass Tab Bar Component
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _PeriodSelectorRow(
                  selectedPeriod: report.periodName,
                  onPeriodSelected: (period) async {
                    if (period == 'Custom') {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && context.mounted) {
                        context.read<AnalyticsCubit>().loadAnalytics(
                              period: 'Custom',
                              customRange: picked,
                            );
                      }
                    } else {
                      context.read<AnalyticsCubit>().loadAnalytics(
                            period: period,
                          );
                    }
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink(key: ValueKey('none'));
      },
    );
  }

  Future<void> _exportReport(
      BuildContext context, AnalyticsReport report) async {
    InterstitialAdHelper.showAd(
      onAdDismissed: () async {
        if (!context.mounted) return;
        try {
          final filePath = await getIt<DataExportImportService>()
              .exportAnalyticsReportToCsv(
                  report: report, openAfterExport: true);
          if (context.mounted) {
            StatusComponents.showToast(
              context,
              message:
                  'Report saved to Downloads/Expendly/${p.basename(filePath)}',
              isSuccess: true,
            );
          }
          await OpenFile.open(filePath);
        } catch (e) {
          if (context.mounted) {
            StatusComponents.showToast(
              context,
              message: 'Report export failed: ${e.toString()}',
              isError: true,
            );
          }
        }
      },
    );
  }
}

class _ReportsLiquidGlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _ReportsLiquidGlassCard({
    required this.child,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = borderRadius ?? BorderRadius.circular(16.r);

    return Container(
      margin: margin,
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

class _PeriodSelectorRow extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const _PeriodSelectorRow({
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final periods = ['Weekly', 'Monthly', 'Yearly', 'Custom'];

    return _ReportsLiquidGlassCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      borderRadius: BorderRadius.circular(14.r),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: periods.map((p) {
          final isSelected = p == selectedPeriod;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: GestureDetector(
                onTap: () => onPeriodSelected(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8.r,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    p,
                    textAlign: TextAlign.center,
                    style: customTypography.labelMediumMono.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeights.bold : FontWeights.medium,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NetFlowHeroCard extends StatelessWidget {
  final AnalyticsReport report;
  final String currencySymbol;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const _NetFlowHeroCard({
    required this.report,
    required this.currencySymbol,
    this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final isPositive = report.netSavings >= 0;
    final flowColor = isPositive ? colorScheme.primary : colorScheme.error;

    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Flow (${report.periodName})',
                      style: customTypography.labelMediumMono.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    verticalMarginXXSmall,
                    ValueListenableBuilder<bool>(
                      valueListenable:
                          isPrivacyModeNotifier ?? ValueNotifier(false),
                      builder: (context, isPrivacy, _) {
                        return CompactAmountText(
                          amount: report.netSavings.abs(),
                          currencySymbol: currencySymbol,
                          isPrivacyMode: isPrivacy,
                          showSign: true,
                          isIncome: isPositive,
                          style:
                              customTypography.headlineLargeMonoBold.copyWith(
                            color: flowColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Savings Rate Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (isPositive
                          ? context.customColors.semanticGreen
                          : context.customColors.semanticRed)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14.sp,
                      color: isPositive
                          ? context.customColors.semanticGreen
                          : context.customColors.semanticRed,
                    ),
                    horizontalMarginXXSmall,
                    Text(
                      '${report.savingsRatePercentage.toStringAsFixed(1)}%',
                      style: customTypography.labelMediumMono.copyWith(
                        color: isPositive
                            ? context.customColors.semanticGreen
                            : context.customColors.semanticRed,
                        fontWeight: FontWeights.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalMarginLarge,

          // Clear, Dynamic Period Flow Bar Chart
          SizedBox(
            height: 140.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(
                    'hero_bar_${report.periodName}_${report.dailyFlows.length}'),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, animVal, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: report.dailyFlows.map((flow) {
                      final barWidth =
                          report.dailyFlows.length > 7 ? 22.w : 32.w;
                      final formattedAmt = flow.amount >= 1000
                          ? '$currencySymbol${(flow.amount / 1000).toStringAsFixed(1)}k'
                          : flow.amount > 0
                              ? '$currencySymbol${flow.amount.toStringAsFixed(0)}'
                              : '';

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Amount Label above peak bar
                            Text(
                              flow.isPeak ? formattedAmt : '',
                              style: customTypography.labelMediumMono.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                            verticalMarginXXSmall,
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              width: barWidth,
                              height: (85.h * flow.heightRatio * animVal)
                                  .clamp(4.h, 85.h),
                              decoration: BoxDecoration(
                                color: flow.isPeak
                                    ? colorScheme.primary
                                    : colorScheme.primary
                                        .withValues(alpha: 0.25),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6.r),
                                ),
                              ),
                            ),
                            verticalMarginXXSmall,
                            Text(
                              flow.label,
                              style: customTypography.labelMediumMono.copyWith(
                                color: flow.isPeak
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                                fontWeight: flow.isPeak
                                    ? FontWeights.bold
                                    : FontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvgDailySpendCard extends StatelessWidget {
  final AnalyticsReport report;
  final String currencySymbol;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const _AvgDailySpendCard({
    required this.report,
    required this.currencySymbol,
    this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avg. Daily Spend',
            style: customTypography.labelMediumMono.copyWith(
              color: colorScheme.outline,
            ),
          ),
          verticalMarginSmall,
          ValueListenableBuilder<bool>(
            valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
            builder: (context, isPrivacy, _) {
              return CompactAmountText(
                amount: report.avgDailySpend,
                currencySymbol: currencySymbol,
                isPrivacyMode: isPrivacy,
                style: customTypography.headlineMediumMonoBold.copyWith(
                  color: colorScheme.onSurface,
                ),
              );
            },
          ),
          verticalMarginXXSmall,
          Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 12.sp,
                color: context.customColors.semanticRed,
              ),
              horizontalMarginXXSmall,
              Expanded(
                child: Text(
                  '${report.avgDailySpendChangePct}% vs previous',
                  style: customTypography.labelMediumMono.copyWith(
                    color: context.customColors.semanticRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetHealthCard extends StatelessWidget {
  final AnalyticsReport report;

  const _BudgetHealthCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isStable = report.budgetHealthStatus == 'STABLE' ||
        report.budgetHealthStatus == 'OPTIMAL';
    final badgeColor =
        isStable ? customColors.semanticGreen : customColors.semanticRed;

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Budget Health',
                  style: customTypography.labelMediumMono.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  report.budgetHealthStatus,
                  style: customTypography.labelMediumMono.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeights.bold,
                  ),
                ),
              ),
            ],
          ),
          verticalMarginSmall,
          Center(
            child: SizedBox(
              width: 56.w,
              height: 56.w,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(
                    'health_ring_${report.periodName}_${report.budgetHealthPercentage}'),
                tween: Tween<double>(
                    begin: 0.0,
                    end: (report.budgetHealthPercentage / 100).clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, animRatio, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: animRatio,
                        strokeWidth: 5.w,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                      Text(
                        '${(animRatio * 100).toStringAsFixed(0)}%',
                        style: customTypography.labelMediumMono.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeights.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCategoryTrendCard extends StatelessWidget {
  final AnalyticsReport report;

  const _TopCategoryTrendCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'TREND REPORT',
              style: customTypography.labelMediumMono.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeights.bold,
              ),
            ),
          ),
          verticalMarginSmall,
          Text(
            'Top Category: ${report.topCategoryName}',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeights.bold,
            ),
          ),
          verticalMarginXXSmall,
          Text(
            report.topCategoryDesc ?? '',
            style: customTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownRow extends StatelessWidget {
  final CategoryReportItem item;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const _CategoryBreakdownRow({
    required this.item,
    this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final catColor = _parseColor(context, item.colorHex);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.customColors.glassStroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _getIconData(item.iconName),
                  color: catColor,
                  size: 20.sp,
                ),
              ),
              horizontalMarginSmall,
              Expanded(
                child: Text(
                  item.categoryName,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeights.bold,
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
                builder: (context, isPrivacy, _) {
                  final currencySymbol =
                      getIt<PreferenceService>().currencySymbol;
                  return CompactAmountText(
                    amount: item.amount,
                    currencySymbol: currencySymbol,
                    isPrivacyMode: isPrivacy,
                    style: customTypography.headlineMediumMonoBold.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ],
          ),
          verticalMarginSmall,
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(
                  'cat_progress_${item.categoryName}_${item.percentage}'),
              tween: Tween<double>(
                  begin: 0.0, end: (item.percentage / 100).clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, _) {
                return LinearProgressIndicator(
                  value: animValue,
                  minHeight: 7.h,
                  backgroundColor:
                      colorScheme.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(catColor),
                );
              },
            ),
          ),
          verticalMarginXXSmall,
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${item.percentage.toStringAsFixed(1)}%',
              style: customTypography.labelMediumMono.copyWith(
                color: catColor,
                fontWeight: FontWeights.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(BuildContext context, String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        final color = Color(int.parse('FF$clean', radix: 16));
        if (Theme.of(context).brightness == Brightness.light) {
          final hsl = HSLColor.fromColor(color);
          if (hsl.lightness > 0.5) {
            return hsl
                .withLightness((hsl.lightness - 0.25).clamp(0.2, 0.45))
                .toColor();
          }
        }
        return color;
      }
    } catch (_) {}
    return context.colorScheme.primary;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

class _StaggeredEntrance extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _StaggeredEntrance({
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * 18.h),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _NetCashFlowCard extends StatelessWidget {
  final AnalyticsReport report;
  final String currencySymbol;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const _NetCashFlowCard({
    required this.report,
    required this.currencySymbol,
    this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    final isPositive = report.netSavings >= 0;
    final flowColor =
        isPositive ? customColors.semanticGreen : customColors.semanticRed;
    final maxVal = report.totalIncome > 0
        ? report.totalIncome
        : (report.totalExpense > 0 ? report.totalExpense : 1.0);
    final incomeRatio = report.totalIncome > 0 ? 1.0 : 0.0;
    final expenseRatio =
        maxVal > 0 ? (report.totalExpense / maxVal).clamp(0.0, 1.0) : 0.0;

    final savingsRateText =
        '${isPositive ? '+' : ''}${report.savingsRatePercentage.toStringAsFixed(1)}% vs Last Month';

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Cash Flow',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeights.bold,
                      ),
                    ),
                    Text(
                      'Total Income vs Total Expenses',
                      style: customTypography.labelMediumMono.copyWith(
                        color: colorScheme.outline,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (isPositive
                          ? customColors.semanticGreen
                          : customColors.semanticRed)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 13.sp,
                      color: isPositive
                          ? customColors.semanticGreen
                          : customColors.semanticRed,
                    ),
                    horizontalMarginXXSmall,
                    Text(
                      savingsRateText,
                      style: customTypography.labelMediumMono.copyWith(
                        color: isPositive
                            ? customColors.semanticGreen
                            : customColors.semanticRed,
                        fontWeight: FontWeights.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalMarginSmall,
          TweenAnimationBuilder<double>(
            key: ValueKey('net_flow_amt_${report.periodName}'),
            tween: Tween<double>(begin: 0.0, end: report.netSavings.abs()),
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeOutCubic,
            builder: (context, animNetAmt, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
                builder: (context, isPrivacy, _) {
                  return CompactAmountText(
                    amount: animNetAmt,
                    currencySymbol: currencySymbol,
                    isPrivacyMode: isPrivacy,
                    showSign: false,
                    animate: false,
                    style: customTypography.headlineLargeMonoBold.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 24.sp,
                      fontWeight: FontWeights.extraBold,
                    ),
                  );
                },
              );
            },
          ),
          Text(
            isPositive ? 'Net Positive' : 'Net Deficit',
            style: customTypography.labelMediumMono.copyWith(
              color: flowColor,
              fontWeight: FontWeights.bold,
              fontSize: 11.sp,
            ),
          ),
          verticalMarginMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income',
                style: customTypography.labelMediumMono.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              TweenAnimationBuilder<double>(
                key: ValueKey('income_amt_${report.periodName}'),
                tween: Tween<double>(begin: 0.0, end: report.totalIncome),
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOutCubic,
                builder: (context, animIncomeAmt, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable:
                        isPrivacyModeNotifier ?? ValueNotifier(false),
                    builder: (context, isPrivacy, _) {
                      return CompactAmountText(
                        amount: animIncomeAmt,
                        currencySymbol: currencySymbol,
                        isPrivacyMode: isPrivacy,
                        animate: false,
                        style: customTypography.labelMediumMono.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeights.bold,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          verticalMarginXXSmall,
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: TweenAnimationBuilder<double>(
              key: ValueKey('income_bar_${report.periodName}'),
              tween: Tween<double>(begin: 0.0, end: incomeRatio),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, animRatio, _) {
                return LinearProgressIndicator(
                  value: animRatio,
                  minHeight: 6.h,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF006644)),
                );
              },
            ),
          ),
          verticalMarginSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expenses',
                style: customTypography.labelMediumMono.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              TweenAnimationBuilder<double>(
                key: ValueKey('expense_amt_${report.periodName}'),
                tween: Tween<double>(begin: 0.0, end: report.totalExpense),
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOutCubic,
                builder: (context, animExpenseAmt, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable:
                        isPrivacyModeNotifier ?? ValueNotifier(false),
                    builder: (context, isPrivacy, _) {
                      return CompactAmountText(
                        amount: animExpenseAmt,
                        currencySymbol: currencySymbol,
                        isPrivacyMode: isPrivacy,
                        animate: false,
                        style: customTypography.labelMediumMono.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeights.bold,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          verticalMarginXXSmall,
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: TweenAnimationBuilder<double>(
              key: ValueKey('expense_bar_${report.periodName}'),
              tween: Tween<double>(begin: 0.0, end: expenseRatio),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, animRatio, _) {
                return LinearProgressIndicator(
                  value: animRatio,
                  minHeight: 6.h,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      context.customColors.semanticRed),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionDonutChartCard extends StatelessWidget {
  final AnalyticsReport report;

  const _DistributionDonutChartCard({required this.report});

  static const List<Color> _donutPalette = [
    Color(0xFF005580), // Deep Teal / Blue
    Color(0xFF70C3FF), // Light Sky Blue
    Color(0xFF57F1DB), // Mint Green
    Color(0xFFFFB74D), // Soft Amber
    Color(0xFFBA68C8), // Soft Purple
    Color(0xFF4DD0E1), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    final items = report.categoryBreakdowns;
    final hasItems = items.isNotEmpty;

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribution',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeights.bold,
            ),
          ),
          verticalMarginMedium,
          SizedBox(
            height: 140.h,
            child: TweenAnimationBuilder<double>(
              key: ValueKey('donut_anim_${report.periodName}_${items.length}'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, animVal, _) {
                final sections = <PieChartSectionData>[];
                if (hasItems) {
                  for (int i = 0; i < items.length; i++) {
                    final item = items[i];
                    final color = _donutPalette[i % _donutPalette.length];
                    sections.add(
                      PieChartSectionData(
                        color: color,
                        value: (item.percentage > 0 ? item.percentage : 1) *
                            animVal,
                        title: '',
                        radius: 20.w * animVal.clamp(0.2, 1.0),
                        showTitle: false,
                      ),
                    );
                  }
                } else {
                  sections.add(
                    PieChartSectionData(
                      color: colorScheme.surfaceContainerHigh,
                      value: 100 * animVal,
                      title: '',
                      radius: 20.w,
                      showTitle: false,
                    ),
                  );
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 42.r,
                        sections: sections,
                        startDegreeOffset: 270,
                      ),
                      duration: const Duration(milliseconds: 750),
                      curve: Curves.easeOutCubic,
                    ),
                    Opacity(
                      opacity: animVal,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(100 * animVal).toStringAsFixed(0)}%',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeights.extraBold,
                            ),
                          ),
                          Text(
                            'Allocated',
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.outline,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          verticalMarginMedium,
          if (hasItems)
            TweenAnimationBuilder<double>(
              key:
                  ValueKey('donut_legend_${report.periodName}_${items.length}'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, animVal, _) {
                return Column(
                  children: items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final color = _donutPalette[idx % _donutPalette.length];

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          horizontalMarginSmall,
                          Expanded(
                            child: Text(
                              item.categoryName,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeights.medium,
                              ),
                            ),
                          ),
                          Text(
                            '${(item.percentage * animVal).toStringAsFixed(0)}%',
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeights.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            )
          else
            Center(
              child: Text(
                'No distribution data available',
                style: customTypography.bodyMedium.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
