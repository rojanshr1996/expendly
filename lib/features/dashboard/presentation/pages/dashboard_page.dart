import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_financial_summary.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/summary_card.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        try {
          return getIt<DashboardCubit>()..loadDashboardData();
        } catch (_) {
          return DashboardCubit(_FallbackGetFinancialSummary())..loadDashboardData();
        }
      },
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: (textTheme.headlineMedium ?? const TextStyle()).copyWith(
            color: colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Text(
                l10n.errorMessage(state.message),
                style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(color: colorScheme.error),
              ),
            );
          }

          if (state is DashboardLoaded) {
            return SingleChildScrollView(
              padding: AppSpacing.paddingHorizontalContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapContainer,
                  SummaryCard(summary: state.summary),
                  AppSpacing.gapContainer,
                  _buildQuickActions(context),
                  AppSpacing.gapContainer,
                  _buildRecentActivityHeader(context),
                  AppSpacing.gapGutter,
                  _buildMockTransactionList(context),
                  AppSpacing.gapSection,
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.addExpense,
          style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addTransaction),
          ),
        ),
        AppSpacing.gapHorizontalGutter,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.pie_chart_outline_rounded),
            label: Text(l10n.analytics),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.recentActivity,
          style: textTheme.titleMedium,
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            l10n.seeAll,
            style: customTypography.labelMediumMono.copyWith(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildMockTransactionList(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    final mockItems = [
      _TransactionItem(
        title: l10n.groceryShopping,
        category: l10n.foodAndDining,
        amount: '-\$124.50',
        date: '${l10n.today}, 14:30',
        icon: Icons.shopping_bag_outlined,
        color: colorScheme.tertiary,
      ),
      _TransactionItem(
        title: l10n.freelancePayout,
        category: l10n.income,
        amount: '+\$1,200.00',
        date: l10n.yesterday,
        icon: Icons.account_balance_wallet_outlined,
        color: customColors.semanticGreen,
        isIncome: true,
      ),
      _TransactionItem(
        title: l10n.netflixSubscription,
        category: l10n.entertainment,
        amount: '-\$15.99',
        date: l10n.jul22Date,
        icon: Icons.movie_creation_outlined,
        color: colorScheme.secondary,
      ),
    ];

    return Column(
      children: mockItems.map((item) => _TransactionTile(item: item)).toList(),
    );
  }
}

class _TransactionItem {
  final String title;
  final String category;
  final String amount;
  final String date;
  final IconData icon;
  final Color color;
  final bool isIncome;

  _TransactionItem({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
    this.isIncome = false,
  });
}

class _TransactionTile extends StatelessWidget {
  final _TransactionItem item;

  const _TransactionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: customColors.surfaceLow,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: customColors.glassStroke, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderLg,
            ),
            child: Icon(item.icon, color: item.color, size: 20.sp),
          ),
          AppSpacing.gapHorizontalGutter,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.gapTight,
                Text(
                  item.category,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                  fontFamily: customTypography.labelMediumMono.fontFamily,
                  color: item.isIncome ? customColors.semanticGreen : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapTight,
              Text(item.date, style: customTypography.labelMediumMono),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallbackGetFinancialSummary implements GetFinancialSummary {
  @override
  DashboardRepository get repository => throw UnimplementedError();

  @override
  Future<FinancialSummary> call(NoParams params) async {
    final now = DateTime.now();
    return FinancialSummary(
      totalBalance: 14850.50,
      totalIncome: 18500.00,
      totalExpense: 3649.50,
      currencySymbol: '\$',
      periodStart: DateTime(now.year, now.month, 1),
      periodEnd: now,
    );
  }
}
