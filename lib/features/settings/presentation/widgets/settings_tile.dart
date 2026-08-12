import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Modular Settings Tile component matching the stitch design specs.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    final effectiveIconColor =
        isDestructive ? colorScheme.error : (iconColor ?? colorScheme.primary);

    final effectiveIconBgColor = iconBackgroundColor ??
        (isDestructive
            ? colorScheme.error.withAlpha((0.15 * 255).round())
            : effectiveIconColor.withAlpha((0.12 * 255).round()));

    final titleColor =
        isDestructive ? colorScheme.error : colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // Icon Badge Container
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: effectiveIconBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),

              // Title & Subtitle Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: customTypography.bodyMedium.copyWith(
                          color: colorScheme.outline,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Widget (Default to chevron if not provided)
              if (trailing != null)
                trailing!
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.outline,
                  size: 20.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
