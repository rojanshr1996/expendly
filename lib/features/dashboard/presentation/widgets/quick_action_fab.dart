import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';

/// Speed Dial Floating Action Button triggering quick logging for Expense, Income, and Transfer.
class QuickActionFab extends StatefulWidget {
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddIncome;
  final VoidCallback? onTransfer;

  const QuickActionFab({
    super.key,
    this.onAddExpense,
    this.onAddIncome,
    this.onTransfer,
  });

  @override
  State<QuickActionFab> createState() => QuickActionFabState();
}

class QuickActionFabState extends State<QuickActionFab> {
  void openSpeedDial(BuildContext context) {
    HapticFeedback.heavyImpact();
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GlassContainer(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant
                      .withAlpha((0.4 * 255).round()),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              verticalMarginMedium,

              Text(
                l10n.addTransaction,
                style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                  fontWeight: FontWeights.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              verticalMarginMedium,

              // Add Expense Option
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: customColors.glassStroke),
                  ),
                  tileColor: colorScheme.surfaceContainerLow,
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: customColors.semanticRed
                          .withAlpha((0.15 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_downward_rounded,
                        color: customColors.semanticRed, size: 20.sp),
                  ),
                  title: Text(
                    l10n.addExpense,
                    style: (textTheme.bodyLarge ?? const TextStyle())
                        .copyWith(fontWeight: FontWeights.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onAddExpense?.call();
                  },
                ),
              ),
              verticalMarginSmall,

              // Add Income Option
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: customColors.glassStroke),
                  ),
                  tileColor: colorScheme.surfaceContainerLow,
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: customColors.semanticGreen
                          .withAlpha((0.15 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_upward_rounded,
                        color: customColors.semanticGreen, size: 20.sp),
                  ),
                  title: Text(
                    l10n.income,
                    style: (textTheme.bodyLarge ?? const TextStyle())
                        .copyWith(fontWeight: FontWeights.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onAddIncome?.call();
                  },
                ),
              ),
              verticalMarginSmall,

              // Account Transfer Option
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: customColors.glassStroke),
                  ),
                  tileColor: colorScheme.surfaceContainerLow,
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primary.withAlpha((0.15 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.swap_horiz_rounded,
                        color: colorScheme.primary, size: 20.sp),
                  ),
                  title: Text(
                    l10n.accountTransfer,
                    style: (textTheme.bodyLarge ?? const TextStyle())
                        .copyWith(fontWeight: FontWeights.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTransfer?.call();
                  },
                ),
              ),
              verticalMarginMedium,
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha((0.4 * 255).round()),
            blurRadius: 16.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          widget.onAddExpense?.call();
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        child: Icon(Icons.add_rounded, size: 30.sp),
      ),
    );
  }
}
