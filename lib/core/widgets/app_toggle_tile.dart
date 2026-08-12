import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/margin_constants.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/font_weights.dart';
import 'glass_container.dart';

/// A reusable settings / preference toggle card widget built with [GlassContainer].
class AppToggleTile extends StatelessWidget {
  const AppToggleTile({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.icon,
    this.iconColor,
    this.iconBgColor,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final effectiveIconColor = iconColor ?? colorScheme.primary;
    final effectiveIconBgColor = iconBgColor ?? AppColors.surfaceContainer;

    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: effectiveIconBgColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 22.sp,
              ),
            ),
            horizontalMarginSmall,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                    fontWeight: FontWeights.semiBold,
                  ),
                ),
                Text(
                  description,
                  style: (textTheme.labelMedium ?? const TextStyle()).copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
