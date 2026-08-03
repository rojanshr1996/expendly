import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../transactions/domain/entities/transaction_item.dart';
import '../../domain/entities/financial_summary.dart';

/// Section displaying recent transactions with category icons, desaturated semantic colors, and monospaced amounts.
/// Uses [CompactAmountText] for scale down fitting and tap-to-view full exact amount tooltip.
class DashboardRecentActivity extends StatelessWidget {
  final List<DashboardTransactionItem> transactions;
  final String currencySymbol;
  final ValueNotifier<bool> isPrivacyModeNotifier;
  final VoidCallback? onSeeAllPressed;

  const DashboardRecentActivity({
    super.key,
    required this.transactions,
    required this.currencySymbol,
    required this.isPrivacyModeNotifier,
    this.onSeeAllPressed,
  });

  IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'home':
        return Icons.home_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'movie':
        return Icons.movie_outlined;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'work':
        return Icons.work_outline_rounded;
      case 'payments':
        return Icons.payments_outlined;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _parseColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentActivity,
              style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeights.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: onSeeAllPressed,
              child: Text(
                l10n.seeAll,
                style: customTypography.labelMediumMono.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeights.bold,
                ),
              ),
            ),
          ],
        ),
        verticalMarginSmall,
        ValueListenableBuilder<bool>(
          valueListenable: isPrivacyModeNotifier,
          builder: (context, isPrivacyMode, _) {
            return Column(
              children: transactions.map((tx) {
                final iconData = _parseIcon(tx.iconName);
                final color = tx.type == TransactionType.income
                    ? AppColors.semanticGreen
                    : tx.type == TransactionType.transfer
                        ? colorScheme.secondary
                        : AppColors.semanticRed;

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: InkWell(
                    onTap: () {
                      final item = TransactionItem(
                        id: tx.id,
                        type: tx.type,
                        amount: tx.amount,
                        currencyCode: currencySymbol,
                        categoryId: tx.categoryId,
                        categoryName: tx.categoryName,
                        categoryIcon: tx.iconName,
                        categoryColorHex: tx.colorHex,
                        timestamp: tx.date,
                        note: tx.title != tx.categoryName ? tx.title : null,
                      );
                      context.router.push(
                        TransactionDetailsRoute(
                          transaction: item,
                          isPrivacyModeNotifier: isPrivacyModeNotifier,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: GlassContainer(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          // Category Icon Avatar
                          Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: color.withAlpha((0.15 * 255).round()),
                              border: Border.all(
                                color: color.withAlpha((0.3 * 255).round()),
                              ),
                            ),
                            child: Icon(iconData, color: color, size: 20.sp),
                          ),
                          horizontalMarginSmall,

                          // Title & Category
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.title,
                                  style:
                                      (textTheme.bodyLarge ?? const TextStyle())
                                          .copyWith(
                                    fontWeight: FontWeights.bold,
                                    color: colorScheme.onSurface,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  tx.categoryName,
                                  style: (textTheme.bodyMedium ??
                                          const TextStyle())
                                      .copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Amount & Date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CompactAmountText(
                                amount: tx.amount,
                                currencySymbol: currencySymbol,
                                isPrivacyMode: isPrivacyMode,
                                showSign: true,
                                type: tx.type,
                                isIncome: tx.type == TransactionType.income
                                    ? true
                                    : (tx.type == TransactionType.expense
                                        ? false
                                        : null),
                                style:
                                    (customTypography.labelMediumMono).copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeights.bold,
                                  color: tx.type == TransactionType.income
                                      ? AppColors.semanticGreen
                                      : tx.type == TransactionType.transfer
                                          ? colorScheme.secondary
                                          : AppColors.semanticRed,
                                ),
                              ),
                              verticalMarginXXSmall,
                              Text(
                                l10n.today,
                                style:
                                    customTypography.labelMediumMono.copyWith(
                                  fontSize: 10.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
