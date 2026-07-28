import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/margin_constants.dart';
import '../extensions/context_extensions.dart';
import '../extensions/padding_extensions.dart';
import '../extensions/shimmer_extensions.dart';
import '../theme/app_colors.dart';

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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        content: GlassContainer(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          backgroundColor: AppColors.surfaceLow.withAlpha((0.95 * 255).round()),
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

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassContainer(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          backgroundColor: AppColors.surfaceLow,
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              verticalMargin20,
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
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelLabel),
                    ),
                  ),
                  horizontalMarginSmall,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceMid.withAlpha((0.5 * 255).round()),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassStroke),
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
