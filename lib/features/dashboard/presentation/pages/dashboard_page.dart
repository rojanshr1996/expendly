import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../analytics/presentation/pages/refined_reports_page.dart';
import '../../../budgets/presentation/pages/budgets_overview_page.dart';
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
  final GlobalKey<QuickActionFabState> _fabKey =
      GlobalKey<QuickActionFabState>();

  @override
  void dispose() {
    _isPrivacyModeNotifier.dispose();
    _currentTabNotifier.dispose();
    super.dispose();
  }

  void _openAddTransaction(BuildContext context) async {
    final result = await context.router.push(const ModernAddTransactionRoute());
    if (!mounted) return;
    if (result == true) {
      context.read<DashboardCubit>().loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        try {
          return getIt<DashboardCubit>()..loadDashboardData();
        } catch (_) {
          return DashboardCubit(_FallbackGetFinancialSummary())
            ..loadDashboardData();
        }
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: context.colorScheme.surface,
            body: ValueListenableBuilder<int>(
              valueListenable: _currentTabNotifier,
              builder: (context, currentTab, _) {
                return IndexedStack(
                  index: currentTab,
                  children: [
                    // Tab 0: Overview
                    _buildOverviewTab(context),

                    // Tab 1: Activity / All Transactions
                    AllTransactionsPage(
                        isPrivacyModeNotifier: _isPrivacyModeNotifier),

                    // Tab 2: Budgets Overview
                    BudgetsOverviewPage(
                        isPrivacyModeNotifier: _isPrivacyModeNotifier),

                    // Tab 3: Reports & Analytics
                    RefinedReportsPage(
                        isPrivacyModeNotifier: _isPrivacyModeNotifier),
                  ],
                );
              },
            ),

            // Quick Action Speed Dial FAB
            floatingActionButton: QuickActionFab(
              key: _fabKey,
              onAddExpense: () => _openAddTransaction(context),
              onAddIncome: () => _openAddTransaction(context),
              onTransfer: () => _openAddTransaction(context),
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
                      top: BorderSide(
                          color: colorScheme.outlineVariant, width: 1.0),
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
                        activeIcon:
                            const Icon(Icons.account_balance_wallet_rounded),
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
          onSettingsPressed: () {},
        ),

        // Scrollable Dashboard Body
        Expanded(
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return Center(
                  child: CircularProgressIndicator(
                      color: context.colorScheme.primary),
                );
              }

              if (state is DashboardError) {
                return Center(
                  child: Text(
                    context.l10n.errorMessage(state.message),
                    style: (context.textTheme.bodyLarge ?? const TextStyle())
                        .copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                );
              }

              if (state is DashboardLoaded) {
                final summary = state.summary;
                final bool isEmptyState = summary.recentTransactions.isEmpty &&
                    summary.totalIncome == 0 &&
                    summary.totalExpense == 0;

                if (isEmptyState) {
                  return EmptyDashboardView(
                    onAddTransaction: () {
                      _openAddTransaction(context);
                    },
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<DashboardCubit>().loadDashboardData(),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            verticalMarginSmall,

                            // Summary Bento Grid Cards
                            DashboardBentoGrid(
                              summary: summary,
                              isPrivacyModeNotifier: _isPrivacyModeNotifier,
                            ),
                            verticalMarginMedium,

                            // Cash Flow Summary Section
                            const DashboardCashFlowChart(),
                            verticalMarginMedium,

                            // Recent Activity Section
                            DashboardRecentActivity(
                              transactions: summary.recentTransactions,
                              currencySymbol: summary.currencySymbol,
                              isPrivacyModeNotifier: _isPrivacyModeNotifier,
                              onSeeAllPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => AllTransactionsPage(
                                      isPrivacyModeNotifier:
                                          _isPrivacyModeNotifier,
                                    ),
                                  ),
                                );
                              },
                            ),
                            verticalMarginLarge,
                          ],
                        ).defaultCanvasPadding(),
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
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
      currencySymbol: '\$',
      periodStart: DateTime(now.year, now.month, 1),
      periodEnd: now,
      recentTransactions: const [],
      categoryBreakdowns: const [],
    );
  }
}
