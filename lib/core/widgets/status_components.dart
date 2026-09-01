import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/margin_constants.dart';
import '../extensions/context_extensions.dart';
import '../extensions/padding_extensions.dart';
import '../extensions/shimmer_extensions.dart';
import '../responsive/breakpoints.dart';
import 'adaptive_sheet.dart';
import 'glass_container.dart';

/// Feedback & Status Components matching modern design system standards.
abstract class StatusComponents {
  /// Show modern toast / snackbar notification
  static void showToast(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    double? bottomMargin,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final customColors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    Color iconColor = colorScheme.primary;
    IconData icon = Icons.info_outline;

    if (isError) {
      iconColor = customColors.semanticRed;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      iconColor = customColors.semanticGreen;
      icon = Icons.check_circle_outline;
    }

    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double defaultMargin = bottomMargin ?? (90.h + bottomPadding);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: EdgeInsets.only(
          bottom: defaultMargin,
          left: 16.w,
          right: 16.w,
        ),
        content: GlassContainer(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20.sp),
              horizontalMarginSmall,
              Expanded(
                child: Text(
                  message,
                  style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (actionLabel != null && onActionPressed != null) ...[
                horizontalMarginSmall,
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onActionPressed();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show standard confirmation bottom sheet
  static Future<bool?> showConfirmationBottomSheet(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isTablet = Breakpoints.isTablet(context);

    return AdaptiveSheet.show<bool>(
      context: context,
      maxDialogWidth: 440.0,
      builder: (dialogCtx) {
        return GlassContainer(
          borderRadius: isTablet
              ? BorderRadius.circular(24.0)
              : BorderRadius.vertical(top: Radius.circular(20.r)),
          padding: isTablet
              ? const EdgeInsets.all(24.0)
              : EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle (phone only)
              if (!isTablet) ...[
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                verticalMargin20,
              ],
              Text(
                title,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              verticalMarginXSmall,
              Text(
                message,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              verticalMarginLarge,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: Text(cancelLabel),
                    ),
                  ),
                  horizontalMarginSmall,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDestructive
                            ? customColors.semanticRed
                            : colorScheme.primary,
                        foregroundColor: isDestructive
                            ? Colors.white
                            : colorScheme.onPrimary,
                      ),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Standardized Empty State Component
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: customColors.glassStroke),
            ),
            child: Icon(
              icon,
              size: 36.sp,
              color: colorScheme.primary,
            ),
          ),
          verticalMarginMedium,
          Text(
            title,
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          verticalMarginXSmall,
          Text(
            description,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            verticalMarginLarge,
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ).defaultCanvasPadding(),
    );
  }
}

/// Modern Glowing Loading Indicator
class AppLoadingIndicator extends StatelessWidget {
  final String? message;

  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final customTypography = context.customTypography;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerBox(
            width: 48.w,
            height: 48.w,
            borderRadius: BorderRadius.circular(12.r),
          ).animateShimmer(),
          if (message != null) ...[
            verticalMarginSmall,
            Text(
              message!,
              style: customTypography.labelMediumMono,
            ),
          ],
        ],
      ),
    );
  }
}
