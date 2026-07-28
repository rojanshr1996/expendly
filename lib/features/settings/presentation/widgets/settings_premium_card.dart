import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Premium Upgrade Card component for Settings screen matching the design reference.
class SettingsPremiumCard extends StatelessWidget {
  final VoidCallback? onUpgradePressed;

  const SettingsPremiumCard({
    super.key,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.primary.withAlpha((0.3 * 255).round()),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha((0.08 * 255).round()),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: colorScheme.primary.withAlpha((0.3 * 255).round()),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        context.l10n.premium,
                        style: customTypography.labelMediumMono.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      context.l10n.goProTitle,
                      style: (textTheme.titleLarge ?? const TextStyle()).copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.workspace_premium_rounded,
                color: colorScheme.primary,
                size: 36.sp,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            context.l10n.goProDesc,
            style: customTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: onUpgradePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                context.l10n.upgradeNow,
                style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
