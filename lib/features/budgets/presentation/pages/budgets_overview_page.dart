import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/amount_formatting_extensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
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
    final result = await context.router.push(CreateNewBudgetRoute(
      onSaved: () {
        cubit.loadBudgets();
      },
    ));
    if (result == true && mounted) {
      cubit.loadBudgets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
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
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                context.l10n.budgets,
                style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStateContent(context, state, colorScheme, customTypography),
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
  ) {
    if (state is BudgetLoading) {
      return const BudgetsOverviewShimmer(key: ValueKey('loading'));
    }

    if (state is BudgetLoaded) {
      final budgets = state.budgets;
      if (budgets.isEmpty) {
        return Center(
          key: const ValueKey('empty'),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.noBudgetsSet,
                  style: customTypography.bodyLargeBold.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 20.sp,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.noBudgetsDesc,
                  textAlign: TextAlign.center,
                  style: customTypography.bodyMedium.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _openCreateBudgetScreen(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.l10n.setFirstBudget),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
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

      return RefreshIndicator(
        key: const ValueKey('loaded_content'),
        color: AppColors.primary,
        onRefresh: () => context.read<BudgetCubit>().loadBudgets(),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
          children: [
            // Total Budget Health Summary Card (Stagger Delay 0ms)
            _StaggeredEntrance(
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

            const SizedBox(height: 24),

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

    return ValueListenableBuilder<String>(
      valueListenable: getIt<PreferenceService>().currencySymbolNotifier,
      builder: (context, currencySymbol, _) {
        final double totalSpent =
            selectedItem != null ? selectedItem!.spentAmount : budgets.fold(0.0, (sum, b) => sum + b.spentAmount);

    final double totalTarget =
        selectedItem != null ? selectedItem!.targetAmount : budgets.fold(0.0, (sum, b) => sum + b.targetAmount);

    final double ratio = totalTarget > 0 ? (totalSpent / totalTarget).clamp(0.0, 1.0) : 0.0;
    final int percentage = (ratio * 100).round();

    final bool isOver = totalTarget > 0 && totalSpent > totalTarget;

    return GestureDetector(
      onTap: selectedItem != null ? onResetSelection : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.secondary.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selectedItem != null ? AppColors.primary.withValues(alpha: 0.5) : AppColors.glassStroke,
            width: selectedItem != null ? 1.5 : 1.0,
          ),
        ),
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
                      color: AppColors.outline,
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Show Total',
                        style: customTypography.labelMediumMono.copyWith(
                          color: AppColors.primary,
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
                        valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
                        builder: (context, isPrivacy, _) {
                          final displaySpent = totalSpent.formatCurrency(
                            currencySymbol,
                            isPrivacyMode: isPrivacy,
                          );
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              displaySpent,
                              style: customTypography.headlineLargeMonoBold.copyWith(
                                color: AppColors.onSurface,
                                fontSize: 28.sp,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOver ? 'Exceeded Limit' : 'Within Budget Limit',
                        style: customTypography.bodyMedium.copyWith(
                          color: isOver ? AppColors.semanticRed : AppColors.semanticGreen,
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
                      valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
                      builder: (context, isPrivacy, _) {
                        final displayTarget = totalTarget.formatCurrency(
                          currencySymbol,
                          isPrivacyMode: isPrivacy,
                        );
                        return Text(
                          'Limit: $displayTarget',
                          style: customTypography.labelMediumMono.copyWith(
                            color: AppColors.outline,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percentage% Utilized',
                      style: customTypography.labelMediumMono.copyWith(
                        color: isOver ? AppColors.semanticRed : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
                      isOver ? AppColors.semanticRed : AppColors.primary,
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
    final customTypography = context.customTypography;
    final catColor = _parseColor(item.categoryColorHex);
    final progress = item.progressPercentage;

    Color progressColor = AppColors.primary;
    if (item.isOverBudget) {
      progressColor = AppColors.semanticRed;
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
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : item.isOverBudget
                    ? AppColors.semanticRed.withValues(alpha: 0.5)
                    : AppColors.glassStroke,
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
                          color: AppColors.onSurface,
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: getIt<PreferenceService>().currencySymbolNotifier,
                        builder: (context, symbol, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
                            builder: (context, isPrivacy, _) {
                              final spent = item.spentAmount.formatCurrency(
                                symbol,
                                isPrivacyMode: isPrivacy,
                              );
                              final target = item.targetAmount.formatCurrency(
                                symbol,
                                isPrivacyMode: isPrivacy,
                              );
                              return Text(
                                '$spent / $target',
                                style: customTypography.labelMediumMono.copyWith(
                                  color: AppColors.outline,
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
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.outline, size: 20),
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
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% used',
                  style: customTypography.labelMediumMono.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.isOverBudget)
                  Text(
                    'EXCEEDED LIMIT!',
                    style: customTypography.labelMediumMono.copyWith(
                      color: AppColors.semanticRed,
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
      duration: Duration(milliseconds: 450 + delayMs),
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
