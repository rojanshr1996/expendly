import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/analytics_local_datasource.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics_report.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';

class RefinedReportsPage extends StatelessWidget {
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const RefinedReportsPage({super.key, this.isPrivacyModeNotifier});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return BlocProvider(
      create: (_) {
        try {
          return getIt<AnalyticsCubit>()..loadAnalytics();
        } catch (_) {
          final db = getIt<AppDatabase>();
          final ds = AnalyticsLocalDataSourceImpl(db);
          final repo = AnalyticsRepositoryImpl(ds);
          return AnalyticsCubit(repo)..loadAnalytics();
        }
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                context.l10n.reports,
                style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary),
                  );
                }

                if (state is AnalyticsLoaded) {
                  final report = state.report;
                  final isEmpty = report.totalIncome == 0 &&
                      report.totalExpense == 0 &&
                      report.categoryBreakdowns.isEmpty;

                  if (isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart_outlined,
                              size: 64,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.noFinancialReportsYet,
                              style: customTypography.bodyLargeBold.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.noReportsDesc,
                              textAlign: TextAlign.center,
                              style: customTypography.bodyMedium.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: colorScheme.primary,
                    onRefresh: () =>
                        context.read<AnalyticsCubit>().loadAnalytics(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Net Savings & Rate Summary Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.surfaceContainerLow,
                                  colorScheme.surfaceContainerHigh,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border:
                                  Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.netSavingsThisPeriod,
                                  style:
                                      customTypography.labelMediumMono.copyWith(
                                    color: colorScheme.outline,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ValueListenableBuilder<bool>(
                                  valueListenable: isPrivacyModeNotifier ??
                                      ValueNotifier(false),
                                  builder: (context, isPrivacy, _) {
                                    final text = isPrivacy
                                        ? '•••••'
                                        : '\$${report.netSavings.toStringAsFixed(2)}';
                                    return Text(
                                      text,
                                      style: customTypography
                                          .headlineLargeMonoBold
                                          .copyWith(
                                        color: report.netSavings >= 0
                                            ? colorScheme.primary
                                            : colorScheme.error,
                                        fontSize: 32,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _StatBox(
                                      label: context.l10n.savingsRate,
                                      value:
                                          '${report.savingsRatePercentage.toStringAsFixed(1)}%',
                                      valueColor: colorScheme.primary,
                                    ),
                                    _StatBox(
                                      label: context.l10n.income,
                                      value:
                                          '\$${report.totalIncome.toStringAsFixed(2)}',
                                      valueColor: colorScheme.secondary,
                                      isPrivacyModeNotifier:
                                          isPrivacyModeNotifier,
                                    ),
                                    _StatBox(
                                      label: context.l10n.expenses,
                                      value:
                                          '\$${report.totalExpense.toStringAsFixed(2)}',
                                      valueColor: colorScheme.error,
                                      isPrivacyModeNotifier:
                                          isPrivacyModeNotifier,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Spending Category Distribution Section
                          Text(
                            context.l10n.expenseBreakdownByCategory,
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.outline,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...report.categoryBreakdowns.map((cat) {
                            return _CategoryBreakdownRow(
                              item: cat,
                              isPrivacyModeNotifier: isPrivacyModeNotifier,
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const _StatBox({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final customTypography = context.customTypography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: customTypography.labelMediumMono.copyWith(
            color: AppColors.outline,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        ValueListenableBuilder<bool>(
          valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
          builder: (context, isPrivacy, _) {
            final textStr =
                isPrivacy && label != 'Savings Rate' ? '•••••' : value;
            return Text(
              textStr,
              style: customTypography.headlineMediumMonoBold.copyWith(
                color: valueColor,
                fontSize: 14,
              ),
            );
          },
        ),
      ],
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
    final customTypography = context.customTypography;
    final catColor = _parseColor(item.colorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconData(item.iconName),
                  color: catColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.categoryName,
                  style: customTypography.bodyLargeBold.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
                builder: (context, isPrivacy, _) {
                  final textStr = isPrivacy
                      ? '•••••'
                      : '\$${item.amount.toStringAsFixed(2)}';
                  return Text(
                    textStr,
                    style: customTypography.headlineMediumMonoBold.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 15,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (item.percentage / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(catColor),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${item.percentage.toStringAsFixed(1)}%',
              style: customTypography.labelMediumMono.copyWith(
                color: catColor,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return AppColors.primary;
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
