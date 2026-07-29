import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../analytics/presentation/pages/refined_reports_page.dart';
import '../../../budgets/presentation/cubit/budget_cubit.dart';
import '../../../budgets/presentation/pages/budgets_overview_page.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../transactions/presentation/pages/all_transactions_page.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_financial_summary.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/dashboard_bento_grid.dart';
import '../widgets/dashboard_cash_flow_chart.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_recent_activity.dart';
import '../widgets/dashboard_shimmer.dart';
import '../widgets/empty_dashboard_view.dart';
import '../widgets/quick_action_fab.dart';

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ValueNotifier<bool> _isPrivacyModeNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> _currentTabNotifier = ValueNotifier<int>(0);
  final GlobalKey<QuickActionFabState> _fabKey = GlobalKey<QuickActionFabState>();

  @override
  void initState() {
    super.initState();
    try {
      getIt<ProfileCubit>().loadProfile();
    } catch (_) {}
  }

  @override
  void dispose() {
    _isPrivacyModeNotifier.dispose();
    _currentTabNotifier.dispose();
    super.dispose();
  }

  void _openAddTransaction(BuildContext context) async {
    final dashboardCubit = context.read<DashboardCubit>();
    final result = await context.router.push(ModernAddTransactionRoute());
    if (!mounted) return;
    if (result == true) {
      dashboardCubit.loadDashboardData();
      try {
        getIt<BudgetCubit>().loadBudgets();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: () {
        try {
          final cubit = getIt<DashboardCubit>();
          if (!cubit.isClosed) {
            cubit.loadDashboardData();
          }
          return cubit;
        } catch (_) {
          return DashboardCubit(_FallbackGetFinancialSummary())..loadDashboardData();
        }
      }(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: context.colorScheme.surface,
            body: ValueListenableBuilder<int>(
              valueListenable: _currentTabNotifier,
              builder: (context, currentTab, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey('tab_$currentTab'),
                    child: IndexedStack(
                      index: currentTab,
                      children: [
                        // Tab 0: Overview
                        _buildOverviewTab(context),

                        // Tab 1: Activity / All Transactions
                        AllTransactionsPage(isPrivacyModeNotifier: _isPrivacyModeNotifier),

                        // Tab 2: Budgets Overview
                        BudgetsOverviewPage(isPrivacyModeNotifier: _isPrivacyModeNotifier),

                        // Tab 3: Reports & Analytics
                        RefinedReportsPage(isPrivacyModeNotifier: _isPrivacyModeNotifier),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Floating Action Button with tab-aware routing
            floatingActionButton: ValueListenableBuilder<int>(
              valueListenable: _currentTabNotifier,
              builder: (context, currentTab, _) {
                if (currentTab == 2) {
                  // Budget Tab: FAB opens Add Budget screen
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.primary
                              .withAlpha((0.4 * 255).round()),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      onPressed: () async {
                        await context.router.push(CreateNewBudgetRoute());
                      },
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      child: const Icon(Icons.add_rounded, size: 30),
                    ),
                  );
                }

                return QuickActionFab(
                  key: _fabKey,
                  onAddExpense: () => _openAddTransaction(context),
                  onAddIncome: () => _openAddTransaction(context),
                  onTransfer: () => _openAddTransaction(context),
                );
              },
            ),

            // Bottom Navigation Bar
            bottomNavigationBar: ValueListenableBuilder<int>(
              valueListenable: _currentTabNotifier,
              builder: (context, currentTab, _) {
                final colorScheme = context.colorScheme;
                final customTypography = context.customTypography;

                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
                    ),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: currentTab,
                    onTap: (index) => _currentTabNotifier.value = index,
                    backgroundColor: colorScheme.surfaceContainerLow,
                    selectedItemColor: colorScheme.primary,
                    unselectedItemColor: colorScheme.outline,
                    selectedLabelStyle: customTypography.labelMediumMono,
                    unselectedLabelStyle: customTypography.labelMediumMono,
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.dashboard_outlined),
                        activeIcon: const Icon(Icons.dashboard_rounded),
                        label: context.l10n.overview,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.receipt_long_outlined),
                        activeIcon: const Icon(Icons.receipt_long_rounded),
                        label: context.l10n.activity,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        activeIcon: const Icon(Icons.account_balance_wallet_rounded),
                        label: context.l10n.budgets,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.bar_chart_outlined),
                        activeIcon: const Icon(Icons.bar_chart_rounded),
                        label: context.l10n.reports,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return Column(
      children: [
        // Glass Header
        DashboardHeader(
          isPrivacyModeNotifier: _isPrivacyModeNotifier,
          onSettingsPressed: () {
            context.router.push(const SettingsRoute());
          },
        ),

        // Scrollable Dashboard Body with Smooth Animated Shimmer Cross-Fade
        Expanded(
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final isLoading = state is DashboardLoading;

              return AnimatedCrossFade(
                duration: const Duration(milliseconds: 550),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeInCubic,
                sizeCurve: Curves.easeInOutCubic,
                crossFadeState: isLoading
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: const DashboardShimmer(key: ValueKey('shimmer')),
                secondChild: _buildLoadedOrErrorContent(context, state),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedOrErrorContent(BuildContext context, DashboardState state) {
    if (state is DashboardError) {
      return Center(
        key: const ValueKey('error'),
        child: Text(
          context.l10n.errorMessage(state.message),
          style: (context.textTheme.bodyLarge ?? const TextStyle()).copyWith(
            color: context.colorScheme.error,
          ),
        ),
      );
    }

    if (state is DashboardLoaded) {
      final summary = state.summary;
      final bool isEmptyState =
          summary.recentTransactions.isEmpty && summary.totalIncome == 0 && summary.totalExpense == 0;

      if (isEmptyState) {
        return EmptyDashboardView(
          key: const ValueKey('empty'),
          onAddTransaction: () {
            _openAddTransaction(context);
          },
        );
      }

      return RefreshIndicator(
        key: const ValueKey('loaded_content'),
        color: AppColors.primary,
        onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalMarginSmall,

                  // Summary Bento Grid Cards (Stagger Delay 0ms)
                  _StaggeredEntrance(
                    delayMs: 0,
                    child: DashboardBentoGrid(
                      summary: summary,
                      isPrivacyModeNotifier: _isPrivacyModeNotifier,
                    ),
                  ),
                  verticalMarginMedium,

                  // Cash Flow Summary Section (Stagger Delay 100ms)
                  const _StaggeredEntrance(
                    delayMs: 100,
                    child: DashboardCashFlowChart(),
                  ),
                  verticalMarginMedium,

                  // Recent Activity Section (Stagger Delay 200ms)
                  _StaggeredEntrance(
                    delayMs: 200,
                    child: DashboardRecentActivity(
                      transactions: summary.recentTransactions,
                      currencySymbol: summary.currencySymbol,
                      isPrivacyModeNotifier: _isPrivacyModeNotifier,
                      onSeeAllPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => AllTransactionsPage(
                              isPrivacyModeNotifier: _isPrivacyModeNotifier,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  verticalMarginLarge,
                ],
              ).defaultCanvasPadding(),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink(key: ValueKey('none'));
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
      tween: Tween<double>(begin: 0.2, end: 1.0),
      duration: Duration(milliseconds: 500 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * 12.h),
            child: child,
          ),
        );
      },
      child: child,
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
      totalBalance: 0.0,
      totalIncome: 0.0,
      totalExpense: 0.0,
      monthlyBudgetLimit: 5000.00,
      currencySymbol: getIt<PreferenceService>().currencySymbol,
      periodStart: DateTime(now.year, now.month, 1),
      periodEnd: now,
      recentTransactions: const [],
      categoryBreakdowns: const [],
    );
  }
}
