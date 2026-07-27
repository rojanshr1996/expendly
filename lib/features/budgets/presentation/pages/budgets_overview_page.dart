import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/budget_local_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget_item.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import 'create_new_budget_page.dart';

class BudgetsOverviewPage extends StatelessWidget {
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const BudgetsOverviewPage({super.key, this.isPrivacyModeNotifier});

  void _openCreateBudgetModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateNewBudgetModal(
        onSaved: () {
          context.read<BudgetCubit>().loadBudgets();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return BlocProvider(
      create: (_) {
        try {
          return getIt<BudgetCubit>()..loadBudgets();
        } catch (_) {
          final db = getIt<AppDatabase>();
          final ds = BudgetLocalDataSourceImpl(db);
          final repo = BudgetRepositoryImpl(ds);
          return BudgetCubit(repo)..loadBudgets();
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
                context.l10n.budgets,
                style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add_rounded,
                      color: colorScheme.primary, size: 28),
                  onPressed: () => _openCreateBudgetModal(context),
                ),
              ],
            ),
            body: BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, state) {
                if (state is BudgetLoading) {
                  return Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary),
                  );
                }

                if (state is BudgetLoaded) {
                  final budgets = state.budgets;
                  if (budgets.isEmpty) {
                    return Center(
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
                                fontSize: 20,
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
                              onPressed: () => _openCreateBudgetModal(context),
                              icon: const Icon(Icons.add_rounded),
                              label: Text(context.l10n.setFirstBudget),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
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

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context.read<BudgetCubit>().loadBudgets(),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 120),
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final item = budgets[index];
                        return _BudgetCard(
                          item: item,
                          isPrivacyModeNotifier: isPrivacyModeNotifier,
                          onDelete: () {
                            context.read<BudgetCubit>().deleteBudget(item.id);
                          },
                        );
                      },
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

class _BudgetCard extends StatelessWidget {
  final BudgetItem item;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.item,
    this.isPrivacyModeNotifier,
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
      progressColor =
          const Color(0xFFFFAC5A); // Warning Orange matching tertiary-container
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isOverBudget
              ? AppColors.semanticRed.withOpacity(0.5)
              : AppColors.glassStroke,
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
                  color: catColor.withOpacity(0.15),
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
                    ValueListenableBuilder<bool>(
                      valueListenable:
                          isPrivacyModeNotifier ?? ValueNotifier(false),
                      builder: (context, isPrivacy, _) {
                        final spent = isPrivacy
                            ? '•••••'
                            : '\$${item.spentAmount.toStringAsFixed(2)}';
                        final target = isPrivacy
                            ? '•••••'
                            : '\$${item.targetAmount.toStringAsFixed(2)}';
                        return Text(
                          '$spent / $target',
                          style: customTypography.labelMediumMono.copyWith(
                            color: AppColors.outline,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.outline, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
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
