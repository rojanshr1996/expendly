import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/budget_item.dart';

class BudgetCardGrid extends StatelessWidget {
  final List<BudgetItem> budgets;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final int? selectedBudgetId;
  final ValueChanged<BudgetItem>? onBudgetSelected;
  final VoidCallback onCreateBudget;
  final ValueChanged<BudgetItem> onDeleteBudget;

  const BudgetCardGrid({
    super.key,
    required this.budgets,
    this.isPrivacyModeNotifier,
    this.selectedBudgetId,
    this.onBudgetSelected,
    required this.onCreateBudget,
    required this.onDeleteBudget,
  });

  Color _parseColor(String hex, Color fallback) {
    if (hex.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Active Budgets (${budgets.length}/4)',
                style: customTypography.bodyLargeBold.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (budgets.length < 4)
              TextButton.icon(
                onPressed: onCreateBudget,
                icon: Icon(Icons.add_rounded,
                    color: colorScheme.primary, size: 20),
                label: Text(
                  'Set New Budget',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid of Budget Cards (Single column on tablet panel for clean 2-column page layout)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 155,
          ),
          itemCount: budgets.length < 4 ? budgets.length + 1 : budgets.length,
          itemBuilder: (context, index) {
            if (index < budgets.length) {
              return _buildBudgetCard(context, budgets[index]);
            } else {
              return _buildAddBudgetCard(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext context, BudgetItem item) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isSelected = item.id == selectedBudgetId;
    final catColor = _parseColor(item.categoryColorHex, colorScheme.primary);
    final progress = item.progressPercentage;

    Color progressColor = colorScheme.primary;
    if (item.isOverBudget) {
      progressColor = customColors.semanticRed;
    } else if (item.isWarning) {
      progressColor = const Color(0xFFFFAC5A);
    }

    return GestureDetector(
      onTap: () => onBudgetSelected?.call(item),
      child: GlassContainer(
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
        padding: const EdgeInsets.all(18.0),
        backgroundColor:
            isSelected ? colorScheme.primary.withValues(alpha: 0.08) : null,
        borderStrokeColor: isSelected
            ? colorScheme.primary
            : item.isOverBudget
                ? customColors.semanticRed.withValues(alpha: 0.5)
                : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Category Icon, Name, and Delete Button
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(item.categoryIcon),
                    color: catColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.categoryName,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
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
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: () => onDeleteBudget(item),
                  tooltip: 'Delete Budget',
                ),
              ],
            ),

            // Middle: Progress Bar
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% used',
                      style: customTypography.labelMediumMono.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.isOverBudget)
                      Text(
                        'EXCEEDED',
                        style: customTypography.labelMediumMono.copyWith(
                          color: customColors.semanticRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBudgetCard(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onCreateBudget,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Set New Budget',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
