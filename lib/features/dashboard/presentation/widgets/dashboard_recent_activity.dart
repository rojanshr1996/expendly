import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../../../core/widgets/compact_amount_text.dart';
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
    return CategoryIconHelper.getIcon(iconName);
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
            final customColors = context.customColors;

            return Column(
              children: transactions.map((tx) {
                final iconData = tx.type == TransactionType.transfer
                    ? Icons.swap_horiz_rounded
                    : _parseIcon(tx.iconName);
                final color = tx.type == TransactionType.income
                    ? customColors.semanticGreen
                    : tx.type == TransactionType.transfer
                        ? customColors.semanticBlue
                        : customColors.semanticRed;

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
                        note: tx.note,
                      );
                      context.router.push(
                        TransactionDetailsRoute(
                          transaction: item,
                          isPrivacyModeNotifier: isPrivacyModeNotifier,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16.r),
                        border:
                            Border.all(color: context.customColors.glassStroke),
                      ),
                      child: Row(
                        children: [
                          // Category Icon Avatar
                          Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              iconData,
                              color: color,
                              size: 22.r,
                            ),
                          ),
                          SizedBox(width: 14.w),

                          // Title & Note (matching AllTransactionsPage)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.type == TransactionType.transfer
                                      ? l10n.transfer
                                      : tx.categoryName,
                                  style:
                                      customTypography.bodyLargeBold.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                if (tx.note?.isNotEmpty == true)
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Text(
                                      tx.note!,
                                      style:
                                          customTypography.bodyMedium.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Amount Display
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
                            style: customTypography.headlineMediumMonoBold
                                .copyWith(
                              color: color,
                              fontSize: 16.sp,
                            ),
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
