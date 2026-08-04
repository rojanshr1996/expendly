import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/ads/interstitial_ad_helper.dart';
import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/status_components.dart';
import '../../../analytics/presentation/pages/refined_reports_page.dart';
import '../../../budgets/presentation/cubit/budget_cubit.dart';
import '../../../budgets/presentation/cubit/budget_state.dart';
import '../../../budgets/presentation/pages/budgets_overview_page.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../settings/presentation/pages/settings_page.dart';
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

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ValueNotifier<int> _currentTabNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isPrivacyModeNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isPrivacyModeNotifier.dispose();
    _currentTabNotifier.dispose();
    super.dispose();
  }

  void _openAddTransaction(BuildContext context) async {
    final result = await context.router.push(ModernAddTransactionRoute());
    if (result == true && mounted) {
      context.read<DashboardCubit>().loadDashboardData();
    }
  }

  void _handleCenterFabPress(BuildContext context, int currentTab) async {
    if (currentTab == 2) {
      final cubit = getIt<BudgetCubit>();
      int currentBudgetCount = 0;
      if (cubit.state is BudgetLoaded) {
        currentBudgetCount = (cubit.state as BudgetLoaded).budgets.length;
      }

      if (currentBudgetCount >= 4) {
        StatusComponents.showToast(
          context,
          message: 'Maximum limit of 4 budgets reached.',
          isError: true,
        );
        return;
      }

      Future<void> navigateToCreate() async {
        final result = await context.router.push(CreateNewBudgetRoute(
          onSaved: () {
            cubit.loadBudgets();
          },
        ));
        if (result == true && mounted) {
          cubit.loadBudgets();
        }
      }

      if (currentBudgetCount >= 2) {
        InterstitialAdHelper.showAd(
          onAdDismissed: () {
            if (mounted) {
              navigateToCreate();
            }
          },
        );
      } else {
        navigateToCreate();
      }
    } else {
      _openAddTransaction(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (_) => getIt<DashboardCubit>()..loadDashboardData(),
        ),
        BlocProvider<BudgetCubit>.value(
          value: () {
            try {
              final cubit = getIt<BudgetCubit>();
              if (!cubit.isClosed) {
                cubit.loadBudgets();
              }
              return cubit;
            } catch (_) {
              return getIt<BudgetCubit>();
            }
          }(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return ValueListenableBuilder<int>(
            valueListenable: _currentTabNotifier,
            builder: (context, currentTab, _) {
              return PopScope(
                canPop: currentTab == 0,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    _currentTabNotifier.value = 0;
                  }
                },
                child: Scaffold(
                  extendBody: true,
                  backgroundColor: context.colorScheme.surface,
                  body: IndexedStack(
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

                      // Tab 3: Settings
                      const SettingsPage(),
                    ],
                  ),

                  // Floating Bottom Navigation Bar with Center Add FAB
                  bottomNavigationBar: ValueListenableBuilder<int>(
                    valueListenable: _currentTabNotifier,
                    builder: (context, currentTab, _) {
                      return _FloatingBottomNavBar(
                        currentTab: currentTab,
                        onTabSelected: (index) =>
                            _currentTabNotifier.value = index,
                        onCenterFabPressed: () =>
                            _handleCenterFabPress(context, currentTab),
                      );
                    },
                  ),
                ),
              );
            },
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
          onReportsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => RefinedReportsPage(
                  isPrivacyModeNotifier: _isPrivacyModeNotifier,
                ),
              ),
            );
          },
        ),

        // Scrollable Dashboard Body with Smooth Animated Shimmer Cross-Fade
        Expanded(
          child: BlocBuilder<DashboardCubit, DashboardState>(
            buildWhen: (previous, current) {
              if (previous.runtimeType != current.runtimeType) return true;
              if (previous is DashboardLoaded && current is DashboardLoaded) {
                return previous.summary != current.summary;
              }
              return true;
            },
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const DashboardShimmer(key: ValueKey('shimmer'));
              }
              return _buildLoadedOrErrorContent(context, state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedOrErrorContent(
      BuildContext context, DashboardState state) {
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
      final bool isEmptyState = summary.recentTransactions.isEmpty &&
          summary.totalIncome == 0 &&
          summary.totalExpense == 0;

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
          padding: EdgeInsets.only(bottom: 120.h),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
    return child;
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

class _FloatingBottomNavBar extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCenterFabPressed;

  const _FloatingBottomNavBar({
    required this.currentTab,
    required this.onTabSelected,
    required this.onCenterFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final l10n = context.l10n;

    final isLight = Theme.of(context).brightness == Brightness.light;
    final double fabSize = 54.w;
    final double barHeight = 64.h;
    final double bottomMargin =
        16.h + MediaQuery.of(context).viewPadding.bottom * 0.4;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // 1. Liquid Glass Floating Bar Container
        Container(
          margin: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: bottomMargin,
          ),
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLight
                  ? [
                      colorScheme.surfaceContainerLowest
                          .withValues(alpha: 0.50),
                      colorScheme.surfaceContainerHigh.withValues(alpha: 0.40),
                    ]
                  : [
                      colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
                      colorScheme.surfaceContainerLow.withValues(alpha: 0.35),
                    ],
            ),
            border: Border.all(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.6)
                  : customColors.glassStroke,
              width: 1.2,
            ),
            boxShadow: [
              // Liquid Ambient Highlight Glow
              BoxShadow(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.5)
                    : colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 10.r,
                spreadRadius: -2.r,
                offset: const Offset(0, -2),
              ),
              // Soft Liquid Glass Drop Shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.12 : 0.28),
                blurRadius: 30.r,
                spreadRadius: 2.r,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Row(
                children: [
                  // Tab 0: Overview
                  Expanded(
                    child: _NavBarItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: l10n.overview,
                      isSelected: currentTab == 0,
                      onTap: () => onTabSelected(0),
                    ),
                  ),

                  // Tab 1: Activity
                  Expanded(
                    child: _NavBarItem(
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long_rounded,
                      label: l10n.activity,
                      isSelected: currentTab == 1,
                      onTap: () => onTabSelected(1),
                    ),
                  ),

                  // Gap space for docked center FAB
                  SizedBox(width: fabSize + 8.w),

                  // Tab 2: Budgets
                  Expanded(
                    child: _NavBarItem(
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet_rounded,
                      label: l10n.budgets,
                      isSelected: currentTab == 2,
                      onTap: () => onTabSelected(2),
                    ),
                  ),

                  // Tab 3: Settings
                  Expanded(
                    child: _NavBarItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                      label: l10n.settings,
                      isSelected: currentTab == 3,
                      onTap: () => onTabSelected(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Clean Liquid FAB (Expanded Touch Target for Effortless Taps)
        Positioned(
          bottom: bottomMargin + barHeight - (fabSize / 2) - 10.h,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.heavyImpact();
              onCenterFabPressed();
            },
            child: Container(
              width: fabSize + 20.w,
              height: fabSize + 20.h,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 10.r,
                      spreadRadius: 0.r,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.onPrimary,
                  size: 32.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    final color =
        isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: color,
            size: 22.sp,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: customTypography.labelMediumMono.copyWith(
              color: color,
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
