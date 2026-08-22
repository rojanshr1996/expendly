import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/glass_container.dart';

/// Reusable carousel slide visual card for onboarding slides.
class OnboardingSlideCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String badgeTag;

  const OnboardingSlideCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.badgeTag,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hero Badge Icon Container
        GlassContainer(
          width: 140.w,
          height: 140.w,
          borderRadius: BorderRadius.circular(32.r),
          blur: isLight ? 0 : 10,
          backgroundColor: isLight
              ? colorScheme.surfaceContainerLowest
              : colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
          borderStrokeColor: isLight
              ? iconColor.withValues(alpha: 0.25)
              : iconColor.withValues(alpha: 0.35),
          child: Center(
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: isLight ? 0.12 : 0.18),
                border: Border.all(
                  color: iconColor.withValues(alpha: isLight ? 0.30 : 0.35),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 40.sp,
                color: iconColor,
              ),
            ),
          ),
        ),
        verticalMarginLarge,

        // Tag Chip
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: iconColor.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: iconColor.withAlpha((0.25 * 255).round()),
            ),
          ),
          child: Text(
            badgeTag.toUpperCase(),
            style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
              color: iconColor,
              letterSpacing: 1.8,
            ),
          ),
        ),
        verticalMarginMedium,

        // Title
        Text(
          title,
          style: customTypography.headlineLargeMobile,
          textAlign: TextAlign.center,
        ),
        verticalMarginXSmall,

        // Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
