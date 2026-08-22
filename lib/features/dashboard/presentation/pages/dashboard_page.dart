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
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/tablet_spacing.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/adaptive_navigation_rail.dart';
import '../../../../core/widgets/status_components.dart';
import '../../../analytics/presentation/pages/refined_reports_page.dart';
import '../../../budgets/presentation/cubit/budget_cubit.dart';
import '../../../budgets/presentation/cubit/budget_state.dart';
import '../../../budgets/presentation/pages/budgets_overview_page.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../../groups/presentation/pages/groups_list_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../transactions/presentation/pages/all_transactions_page.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/dashboard_bento_grid.dart';
import '../widgets/dashboard_cash_flow_chart.dart';
import '../widgets/dashboard_categories_donut.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_recent_activity.dart';
import '../widgets/dashboard_recent_groups.dart';
import '../widgets/dashboard_shimmer.dart';
import '../widgets/dashboard_tablet_header.dart';
import '../widgets/dashboard_tablet_summary_row.dart';
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
  final ValueNotifier<bool> _isNavRailExpandedNotifier =
      ValueNotifier<bool>(true);

  /// Maps tablet tab indices to the total tab count.
  /// Compact: 0=Overview, 1=Activity, 2=Budgets (3 tabs)
  /// Tablet:  0=Overview, 1=Activity, 2=Budgets, 3=Reports, 4=Groups, 5=Settings (6 tabs)
  static const int _compactTabCount = 3;
  static const int _tabletTabCount = 6;

  @override
  void dispose() {
    _isPrivacyModeNotifier.dispose();
    _currentTabNotifier.dispose();
    _isNavRailExpandedNotifier.dispose();
    super.dispose();
  }

  void _openAddTransaction(BuildContext context) async {
    final result = await context.router.push(ModernAddTransactionRoute());
    if (result == true && context.mounted) {
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
        BlocProvider<GroupsCubit>.value(
          value: () {
            try {
              final cubit = getIt<GroupsCubit>();
              if (!cubit.isClosed) {
                cubit.loadEvents(isSilent: true);
              }
              return cubit;
            } catch (_) {
              return getIt<GroupsCubit>();
            }
          }(),
        ),
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
          final isTablet = Breakpoints.isTablet(context);
          return isTablet
              ? _buildTabletLayout(context)
              : _buildCompactLayout(context);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Compact Layout (Phone) — Original bottom nav bar
  // ---------------------------------------------------------------------------

  Widget _buildCompactLayout(BuildContext context) {
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
              index: currentTab.clamp(0, _compactTabCount - 1),
              children: [
                // Tab 0: Overview
                _buildOverviewTab(context),

                // Tab 1: Activity / All Transactions
                AllTransactionsPage(
                    isPrivacyModeNotifier: _isPrivacyModeNotifier),

                // Tab 2: Budgets Overview
                BudgetsOverviewPage(
                    isPrivacyModeNotifier: _isPrivacyModeNotifier),
              ],
            ),

            // Floating Bottom Navigation Bar with Center Add FAB
            bottomNavigationBar: ValueListenableBuilder<int>(
              valueListenable: _currentTabNotifier,
              builder: (context, currentTab, _) {
                return _FloatingBottomNavBar(
                  currentTab: currentTab,
                  onTabSelected: (index) {
                    if (index == 3) {
                      context.router.push(const SettingsRoute());
                    } else {
                      _currentTabNotifier.value = index;
                    }
                  },
                  onCenterFabPressed: () =>
                      _handleCenterFabPress(context, currentTab),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tablet Layout — Navigation Rail + expanded content
  // ---------------------------------------------------------------------------

  Widget _buildTabletLayout(BuildContext context) {
    final l10n = context.l10n;

    // Define navigation rail items for tablet
    final navItems = [
      NavRailItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: l10n.overview,
        index: 0,
      ),
      NavRailItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: l10n.activity,
        index: 1,
      ),
      NavRailItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: l10n.budgets,
        index: 2,
      ),
      NavRailItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: l10n.reports,
        index: 3,
      ),
      NavRailItem(
        icon: Icons.group_outlined,
        activeIcon: Icons.group_rounded,
        label: l10n.groups,
        index: 4,
      ),
    ];

    final bottomNavItems = [
      NavRailItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: l10n.settings,
        index: 5,
      ),
    ];

    final isWideTablet = MediaQuery.sizeOf(context).width >= 900;

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
            backgroundColor: context.colorScheme.surface,
            body: Row(
              children: [
                // Left: Navigation Rail
                AdaptiveNavigationRail(
                  selectedIndex: currentTab,
                  isExpanded: isWideTablet,
                  items: navItems,
                  bottomItems: bottomNavItems,
                  onDestinationSelected: (index) {
                    _currentTabNotifier.value = index;
                  },
                  onNewEntryPressed: () =>
                      _handleCenterFabPress(context, currentTab),
                ),

                // Right: Main content area
                Expanded(
                  child: IndexedStack(
                    index: currentTab.clamp(0, _tabletTabCount - 1),
                    children: [
                      // Tab 0: Overview (without DashboardHeader — nav rail handles navigation)
                      _buildOverviewTabTablet(context),

                      // Tab 1: Activity / All Transactions
                      AllTransactionsPage(
                          isPrivacyModeNotifier: _isPrivacyModeNotifier),

                      // Tab 2: Budgets Overview
                      BudgetsOverviewPage(
                          isPrivacyModeNotifier: _isPrivacyModeNotifier),

                      // Tab 3: Reports & Analytics
                      RefinedReportsPage(
                          isPrivacyModeNotifier: _isPrivacyModeNotifier),

                      // Tab 4: Groups & Splits
                      const GroupsListPage(),

                      // Tab 5: Settings
                      const SettingsPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Overview Tab — Compact (Phone)
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTab(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + 64.h;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Scrollable Dashboard Body (Scrolls UNDER the glass header)
        Positioned.fill(
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
                return Padding(
                  padding: EdgeInsets.only(top: headerPaddingTop),
                  child: const DashboardShimmer(key: ValueKey('shimmer')),
                );
              }
              return _buildLoadedOrErrorContent(
                context,
                state,
                headerPaddingTop,
              );
            },
          ),
        ),

        // 2. Pinned Liquid Glass Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DashboardHeader(
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
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Overview Tab — Tablet
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTabTablet(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is DashboardLoaded && current is DashboardLoaded) {
          return previous.summary != current.summary;
        }
        return true;
      },
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Padding(
            padding: EdgeInsets.only(top: TabletSpacing.canvasPadding),
            child: DashboardShimmer(key: ValueKey('tablet_shimmer')),
          );
        }
        return _buildTabletLoadedOrErrorContent(context, state);
      },
    );
  }

  Widget _buildTabletLoadedOrErrorContent(
    BuildContext context,
    DashboardState state,
  ) {
    if (state is DashboardError) {
      return Center(
        key: const ValueKey('tablet_error'),
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
        return RefreshIndicator(
          key: const ValueKey('tablet_empty_content'),
          color: AppColors.primary,
          onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: TabletSpacing.canvasPadding,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardTabletHeader(
                  isPrivacyModeNotifier: _isPrivacyModeNotifier,
                  onNewEntryPressed: () => _openAddTransaction(context),
                  onRefreshPressed: () =>
                      context.read<DashboardCubit>().loadDashboardData(),
                ),
                const SizedBox(height: TabletSpacing.sectionGap),
                EmptyDashboardView(
                  key: const ValueKey('tablet_empty'),
                  onAddTransaction: () {
                    _openAddTransaction(context);
                  },
                ),
                const SizedBox(height: TabletSpacing.sectionGap),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        key: const ValueKey('tablet_loaded_content'),
        color: AppColors.primary,
        onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: TabletSpacing.canvasPadding,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tablet Header Bar with greetings & action buttons
              DashboardTabletHeader(
                isPrivacyModeNotifier: _isPrivacyModeNotifier,
                onNewEntryPressed: () => _openAddTransaction(context),
                onRefreshPressed: () =>
                    context.read<DashboardCubit>().loadDashboardData(),
              ),
              const SizedBox(height: TabletSpacing.sectionGap),

              // 2. Horizontal 3-card Summary Row
              DashboardTabletSummaryRow(
                summary: summary,
                isPrivacyModeNotifier: _isPrivacyModeNotifier,
              ),
              const SizedBox(height: TabletSpacing.sectionGap),

              // 3. Side-by-Side Cash Flow Chart (flex 5) + Categories Donut (flex 3)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 5,
                    child: DashboardCashFlowChart(),
                  ),
                  const SizedBox(width: TabletSpacing.gridGutter),
                  Expanded(
                    flex: 3,
                    child: DashboardCategoriesDonut(
                      summary: summary,
                      isPrivacyModeNotifier: _isPrivacyModeNotifier,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TabletSpacing.sectionGap),

              // 4. Recent Activity Section (Full Width)
              DashboardRecentActivity(
                transactions: summary.recentTransactions,
                currencySymbol: summary.currencySymbol,
                isPrivacyModeNotifier: _isPrivacyModeNotifier,
                onSeeAllPressed: () {
                  // On tablet, switch to the Transactions tab
                  _currentTabNotifier.value = 1;
                },
              ),
              const SizedBox(height: TabletSpacing.sectionGap),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink(key: ValueKey('tablet_none'));
  }

  // ---------------------------------------------------------------------------
  // Compact — Loaded/Error Content (Original)
  // ---------------------------------------------------------------------------

  Widget _buildLoadedOrErrorContent(
    BuildContext context,
    DashboardState state,
    double headerPaddingTop,
  ) {
    if (state is DashboardError) {
      return Padding(
        padding: EdgeInsets.only(top: headerPaddingTop),
        child: Center(
          key: const ValueKey('error'),
          child: Text(
            context.l10n.errorMessage(state.message),
            style: (context.textTheme.bodyLarge ?? const TextStyle()).copyWith(
              color: context.colorScheme.error,
            ),
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
        return RefreshIndicator(
          key: const ValueKey('empty_content'),
          color: AppColors.primary,
          edgeOffset: headerPaddingTop,
          displacement: 30.h,
          onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.only(
              top: headerPaddingTop + 8.h,
              bottom: 120.h,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Empty Dashboard Hero & CTA
                    EmptyDashboardView(
                      key: const ValueKey('empty'),
                      onAddTransaction: () {
                        _openAddTransaction(context);
                      },
                    ),
                    verticalMarginMedium,

                    // Shared Groups / Split Bill Section (Always accessible)
                    _StaggeredEntrance(
                      delayMs: 150,
                      child: DashboardRecentGroups(
                        onSeeAllPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const GroupsListPage(),
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

      return RefreshIndicator(
        key: const ValueKey('loaded_content'),
        color: AppColors.primary,
        edgeOffset: headerPaddingTop,
        displacement: 30.h,
        onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.only(
            top: headerPaddingTop + 8.h,
            bottom: 120.h,
          ),
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

                  // Shared Groups / Split Bill Section (Stagger Delay 200ms)
                  _StaggeredEntrance(
                    delayMs: 200,
                    child: DashboardRecentGroups(
                      onSeeAllPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const GroupsListPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  verticalMarginMedium,

                  // Recent Activity Section (Stagger Delay 300ms)
                  _StaggeredEntrance(
                    delayMs: 300,
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

    final borderRadius = BorderRadius.circular(32.r);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // 1. Liquid Glass Floating Bar Container (Matching LiquidGlassAppBar)
        Container(
          margin: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: bottomMargin,
          ),
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLight
                  ? [
                      colorScheme.surfaceContainerLowest
                          .withValues(alpha: 0.15),
                      colorScheme.surfaceContainerHigh.withValues(alpha: 0.08),
                    ]
                  : [
                      colorScheme.surfaceContainerHigh.withValues(alpha: 0.12),
                      colorScheme.surfaceContainerLow.withValues(alpha: 0.05),
                    ],
            ),
            border: Border.all(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.35)
                  : customColors.glassStroke.withValues(alpha: 0.25),
              width: 1.0,
            ),
            boxShadow: [
              // Specular Top Highlight Glow
              BoxShadow(
                color: Colors.white.withValues(alpha: isLight ? 0.40 : 0.05),
                blurRadius: 4.r,
                spreadRadius: -1.r,
                offset: const Offset(0, -1),
              ),
              // Subtle contact separation shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.15),
                blurRadius: 8.r,
                spreadRadius: 1.r,
                offset: const Offset(0, 2),
              ),
              // Soft Ambient Elevation Shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.07 : 0.25),
                blurRadius: 16.r,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    // Tab 0: Overview (Left 1)
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard_rounded,
                        label: l10n.overview,
                        isSelected: currentTab == 0,
                        onTap: () => onTabSelected(0),
                      ),
                    ),

                    // Tab 1: Activity (Left 2)
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long_rounded,
                        label: l10n.activity,
                        isSelected: currentTab == 1,
                        onTap: () => onTabSelected(1),
                      ),
                    ),

                    // Symmetrical gap space for docked center FAB
                    SizedBox(width: 46.w),

                    // Tab 2: Budgets (Right 1)
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.account_balance_wallet_outlined,
                        activeIcon: Icons.account_balance_wallet_rounded,
                        label: l10n.budgets,
                        isSelected: currentTab == 2,
                        onTap: () => onTabSelected(2),
                      ),
                    ),

                    // Tab 3: Settings (Right 2)
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
        ),

        // 2. Clean Liquid FAB with Animated Press Feedback
        Positioned(
          bottom: bottomMargin + barHeight - (fabSize / 2) - 10.h,
          child: _LiquidCenterFab(
            fabSize: fabSize,
            onPressed: () {
              HapticFeedback.heavyImpact();
              onCenterFabPressed();
            },
          ),
        ),
      ],
    );
  }
}

class _LiquidCenterFab extends StatefulWidget {
  final double fabSize;
  final VoidCallback onPressed;

  const _LiquidCenterFab({
    required this.fabSize,
    required this.onPressed,
  });

  @override
  State<_LiquidCenterFab> createState() => _LiquidCenterFabState();
}

class _LiquidCenterFabState extends State<_LiquidCenterFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          width: widget.fabSize + 20.w,
          height: widget.fabSize + 20.h,
          alignment: Alignment.center,
          color: Colors.transparent,
          child: Container(
            width: widget.fabSize,
            height: widget.fabSize,
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
                // Top inner/specular highlight
                BoxShadow(
                  color: Colors.white.withValues(alpha: isLight ? 0.5 : 0.20),
                  blurRadius: 4.r,
                  spreadRadius: -1.r,
                  offset: const Offset(0, -1),
                ),
                // Soft glowing drop shadow
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.20),
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
    );
  }
}

class _NavBarItem extends StatefulWidget {
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
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final primaryColor = colorScheme.primary;
    final activeColor = primaryColor;
    final inactiveColor = colorScheme.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.86 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: widget.isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  widget.isSelected ? widget.activeIcon : widget.icon,
                  color: widget.isSelected ? activeColor : inactiveColor,
                  size: 22.sp,
                  shadows: widget.isSelected
                      ? [
                          Shadow(
                            color: primaryColor.withValues(
                              alpha: isLight ? 0.25 : 0.35,
                            ),
                            blurRadius: 8.r,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
              SizedBox(height: 3.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
                    color: widget.isSelected ? activeColor : inactiveColor,
                    fontSize: 10.5.sp,
                    fontWeight:
                        widget.isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  child: Text(
                    widget.label,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
