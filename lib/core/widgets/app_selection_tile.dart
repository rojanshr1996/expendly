import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/margin_constants.dart';
import '../extensions/context_extensions.dart';
import '../theme/font_weights.dart';
import 'glass_container.dart';

/// A reusable selectable GlassContainer tile for lists (e.g., currency selection).
class AppSelectionTile extends StatelessWidget {
  const AppSelectionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badgeText,
    this.badgeIcon,
    this.padding,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badgeText;
  final IconData? badgeIcon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;

    return GlassContainer(
      onTap: onTap,
      backgroundColor: isSelected
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerLow.withAlpha((0.7 * 255).round()),
      borderStrokeColor:
          isSelected ? colorScheme.primary : customColors.glassStroke,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          if (badgeText != null || badgeIcon != null) ...[
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withAlpha((0.2 * 255).round())
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: badgeText != null
                  ? Text(
                      badgeText!,
                      style:
                          (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                        fontWeight: FontWeights.bold,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    )
                  : Icon(
                      badgeIcon,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      size: 20.sp,
                    ),
            ),
            horizontalMarginMedium,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                    fontWeight: FontWeights.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: (textTheme.labelMedium ?? const TextStyle()).copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: colorScheme.primary,
              size: 22.sp,
            ),
        ],
      ),
    );
  }
}
