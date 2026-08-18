import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/ads/ad_helper.dart';
import '../../../../core/ads/interstitial_ad_helper.dart';
import '../../../../core/ads/widgets/banner_ad_widget.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_empty_state_hero.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/status_components.dart';
import '../../data/datasources/budget_local_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget_item.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../widgets/budgets_overview_shimmer.dart';

class BudgetsOverviewPage extends StatefulWidget {
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const BudgetsOverviewPage({super.key, this.isPrivacyModeNotifier});

  @override
  State<BudgetsOverviewPage> createState() => _BudgetsOverviewPageState();
}

class _BudgetsOverviewPageState extends State<BudgetsOverviewPage> {
  int? _selectedBudgetId;

  void _openCreateBudgetScreen(BuildContext context) async {
    final cubit = context.read<BudgetCubit>();
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    return BlocProvider.value(
      value: () {
        try {
          final cubit = getIt<BudgetCubit>();
          if (!cubit.isClosed) {
            cubit.loadBudgets();
          }
          return cubit;
        } catch (_) {
          final db = getIt<AppDatabase>();
          final ds = BudgetLocalDataSourceImpl(db);
          final repo = BudgetRepositoryImpl(ds);
          return BudgetCubit(repo)..loadBudgets();
        }
      }(),
      child: Builder(
        builder: (context) {
          final topInset = MediaQuery.of(context).padding.top;
          final headerPaddingTop = topInset + kToolbarHeight;

          return Scaffold(
            backgroundColor: colorScheme.surface,
            extendBodyBehindAppBar: true,
            appBar: LiquidGlassAppBar(
              showLeading: false,
              titleText: context.l10n.budgets,
            ),
            body: BlocBuilder<BudgetCubit, BudgetState>(
              buildWhen: (previous, current) {
                if (previous.runtimeType != current.runtimeType) return true;
                if (previous is BudgetLoaded && current is BudgetLoaded) {
                  return previous.budgets != current.budgets;
                }
                return true;
              },
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
                  child: _buildStateContent(context, state, colorScheme,
                      customTypography, headerPaddingTop),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    BudgetState state,
    ColorScheme colorScheme,
    dynamic customTypography,
    double headerPaddingTop,
  ) {
    if (state is BudgetLoading) {
      return Padding(
        padding: EdgeInsets.only(top: headerPaddingTop),
        child: const BudgetsOverviewShimmer(key: ValueKey('loading')),
      );
    }

    if (state is BudgetLoaded) {
      final budgets = state.budgets;
      if (budgets.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: headerPaddingTop),
          child: Center(
            key: const ValueKey('empty'),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedEmptyStateHero(
                    primaryIcon: Icons.account_balance_wallet_rounded,
                    primaryColor: colorScheme.primary,
                    secondaryBadgeTop: Icons.pie_chart_rounded,
                    secondaryColorTop: colorScheme.primary,
                    secondaryBadgeBottom: Icons.savings_outlined,
                    secondaryColorBottom: colorScheme.secondary,
                    containerSize: 110.w,
                    heroSize: 160.w,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    context.l10n.noBudgetsSet,
                    style: customTypography.bodyLargeBold.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.l10n.noBudgetsDesc,
                    textAlign: TextAlign.center,
                    style: customTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  ElevatedButton.icon(
                    onPressed: () => _openCreateBudgetScreen(context),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(context.l10n.setFirstBudget),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Find selected budget item if tap selection is active
      BudgetItem? selectedItem;
      if (_selectedBudgetId != null) {
        try {
          selectedItem = budgets.firstWhere(
            (b) => b.id == _selectedBudgetId,
          );
        } catch (_) {
          selectedItem = null;
        }
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          // 1. Scrollable Content (Banner Ad, Category Header, Budget Cards scroll UNDER pinned Total Budget Health section)
          Positioned.fill(
            child: RefreshIndicator(
              key: const ValueKey('loaded_content'),
              color: AppColors.primary,
              edgeOffset: headerPaddingTop,
              onRefresh: () => context.read<BudgetCubit>().loadBudgets(),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: headerPaddingTop + 215.h,
                  bottom: 120.h,
                ),
                children: [
                  // Banner Ad
                  BannerAdWidget(adUnitId: AdHelper.bannerAdUnitId),

                  const SizedBox(height: 12),

                  // Section Header (Stagger Delay 100ms)
                  _StaggeredEntrance(
                    delayMs: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: customTypography.bodyLargeBold.copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          '${budgets.length} Active',
                          style: customTypography.labelMediumMono.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Budgets List with Staggered Entrance Animations
                  ...budgets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = item.id == _selectedBudgetId;

                    return _StaggeredEntrance(
                      delayMs: 150 + (index * 60),
                      child: _BudgetCard(
                        item: item,
                        isSelected: isSelected,
                        isPrivacyModeNotifier: widget.isPrivacyModeNotifier,
                        onTap: () {
                          setState(() {
                            if (_selectedBudgetId == item.id) {
                              _selectedBudgetId = null;
                            } else {
                              _selectedBudgetId = item.id;
                            }
                          });
                        },
                        onDelete: () {
                          if (_selectedBudgetId == item.id) {
                            _selectedBudgetId = null;
                          }
                          context.read<BudgetCubit>().deleteBudget(item.id);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 2. Fixed Non-Scrollable Pinned Total Budget Health Component at Top
          Positioned(
            top: headerPaddingTop + 12.h,
            left: 20.w,
            right: 20.w,
            child: _StaggeredEntrance(
              delayMs: 0,
              child: _TotalBudgetHealthCard(
                budgets: budgets,
                selectedItem: selectedItem,
                isPrivacyModeNotifier: widget.isPrivacyModeNotifier,
                onResetSelection: () {
                  setState(() {
                    _selectedBudgetId = null;
                  });
                },
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink(key: ValueKey('none'));
  }
}

class _TotalBudgetHealthCard extends StatelessWidget {
  final List<BudgetItem> budgets;
  final BudgetItem? selectedItem;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final VoidCallback onResetSelection;

  const _TotalBudgetHealthCard({
    required this.budgets,
    this.selectedItem,
    this.isPrivacyModeNotifier,
    required this.onResetSelection,
  });

  @override
  Widget build(BuildContext context) {
    final customTypography = context.customTypography;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return ValueListenableBuilder<String>(
      valueListenable: getIt<PreferenceService>().currencySymbolNotifier,
      builder: (context, currencySymbol, _) {
        final double totalSpent = selectedItem != null
            ? selectedItem!.spentAmount
            : budgets.fold(0.0, (sum, b) => sum + b.spentAmount);

        final double totalTarget = selectedItem != null
            ? selectedItem!.targetAmount
            : budgets.fold(0.0, (sum, b) => sum + b.targetAmount);

        final double ratio =
            totalTarget > 0 ? (totalSpent / totalTarget).clamp(0.0, 1.0) : 0.0;
        final int percentage = (ratio * 100).round();

        final bool isOver = totalTarget > 0 && totalSpent > totalTarget;

        return GestureDetector(
          onTap: selectedItem != null ? onResetSelection : null,
          child: _BudgetsLiquidGlassCard(
            padding: const EdgeInsets.all(20),
            customBorder: selectedItem != null
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.6),
                    width: 1.5,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedItem != null
                            ? '${selectedItem!.categoryName.toUpperCase()} BUDGET HEALTH'
                            : 'TOTAL BUDGET HEALTH',
                        style: customTypography.labelMediumMono.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selectedItem != null)
                      InkWell(
                        onTap: onResetSelection,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Show Total',
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable:
                                isPrivacyModeNotifier ?? ValueNotifier(false),
                            builder: (context, isPrivacy, _) {
                              return CompactAmountText(
                                amount: totalSpent,
                                currencySymbol: currencySymbol,
                                isPrivacyMode: isPrivacy,
                                compact: true,
                                animate: true,
                                style: customTypography.headlineLargeMonoBold
                                    .copyWith(
                                  color: colorScheme.onSurface,
                                  fontSize: 28.sp,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOver ? 'Exceeded Limit' : 'Within Budget Limit',
                            style: customTypography.bodyMedium.copyWith(
                              color: isOver
                                  ? customColors.semanticRed
                                  : customColors.semanticGreen,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              isPrivacyModeNotifier ?? ValueNotifier(false),
                          builder: (context, isPrivacy, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Limit: ',
                                  style:
                                      customTypography.labelMediumMono.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                CompactAmountText(
                                  amount: totalTarget,
                                  currencySymbol: currencySymbol,
                                  isPrivacyMode: isPrivacy,
                                  compact: true,
                                  animate: true,
                                  style:
                                      customTypography.labelMediumMono.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          key: ValueKey(
                              'total_perc_${percentage}_$selectedItem'),
                          tween: Tween<double>(
                              begin: 0.0, end: percentage.toDouble()),
                          duration: const Duration(milliseconds: 750),
                          curve: Curves.easeOutCubic,
                          builder: (context, animVal, _) {
                            return Text(
                              '${animVal.round()}% Utilized',
                              style: customTypography.labelMediumMono.copyWith(
                                color: isOver
                                    ? customColors.semanticRed
                                    : colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Animated Linear Progress Indicator from 0.0 to target ratio
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: ratio),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedRatio, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: animatedRatio,
                        minHeight: 10,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOver
                              ? customColors.semanticRed
                              : colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetItem item;
  final bool isSelected;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.item,
    required this.isSelected,
    this.isPrivacyModeNotifier,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final catColor = _parseColor(item.categoryColorHex);
    final progress = item.progressPercentage;

    Color progressColor = colorScheme.primary;
    if (item.isOverBudget) {
      progressColor = customColors.semanticRed;
    } else if (item.isWarning) {
      progressColor = const Color(0xFFFFAC5A);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : item.isOverBudget
                    ? customColors.semanticRed.withValues(alpha: 0.5)
                    : customColors.glassStroke,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(item.categoryIcon),
                    color: catColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.categoryName,
                        style: customTypography.bodyLargeBold.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable:
                            getIt<PreferenceService>().currencySymbolNotifier,
                        builder: (context, symbol, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable:
                                isPrivacyModeNotifier ?? ValueNotifier(false),
                            builder: (context, isPrivacy, _) {
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CompactAmountText(
                                      amount: item.spentAmount,
                                      currencySymbol: symbol,
                                      isPrivacyMode: isPrivacy,
                                      compact: true,
                                      animate: true,
                                      style: customTypography.labelMediumMono
                                          .copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      ' / ',
                                      style: customTypography.labelMediumMono
                                          .copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    CompactAmountText(
                                      amount: item.targetAmount,
                                      currencySymbol: symbol,
                                      isPrivacyMode: isPrivacy,
                                      compact: true,
                                      animate: true,
                                      style: customTypography.labelMediumMono
                                          .copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: colorScheme.onSurfaceVariant, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Animated Progress Bar from 0.0 to progress ratio
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: animatedProgress,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey(
                      'card_perc_${item.id}_${item.spentAmount}_${item.targetAmount}'),
                  tween: Tween<double>(
                      begin: 0.0, end: (progress * 100).clamp(0.0, 9999.0)),
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  builder: (context, animVal, _) {
                    return Text(
                      '${animVal.round()}% used',
                      style: customTypography.labelMediumMono.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                if (item.isOverBudget)
                  Text(
                    'EXCEEDED LIMIT!',
                    style: customTypography.labelMediumMono.copyWith(
                      color: customColors.semanticRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
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
      default:
        return Icons.account_balance_wallet_rounded;
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
      duration: Duration(milliseconds: 400 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * 16.h),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _BudgetsLiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Border? customBorder;

  const _BudgetsLiquidGlassCard({
    required this.child,
    this.padding,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = BorderRadius.circular(24.r);

    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.85),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.60),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.58),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.35),
                ],
        ),
        border: customBorder ??
            Border.all(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.85)
                  : customColors.glassStroke.withValues(alpha: 0.60),
              width: 1.2,
            ),
        boxShadow: [
          // Specular top rim reflection
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.75 : 0.08),
            blurRadius: 8.r,
            spreadRadius: -1.r,
            offset: const Offset(0, -1),
          ),
          // Faint, soft ambient shadow around the container perimeter
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.07 : 0.28),
            blurRadius: 22.r,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          // Subtle primary glow
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: isLight ? 0.03 : 0.08),
            blurRadius: 26.r,
            spreadRadius: -2.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
