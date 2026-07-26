import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Glassmorphic Hero Badge Icon
        GlassContainer(
          width: 140.w,
          height: 140.w,
          borderRadius: BorderRadius.circular(32.r),
          backgroundColor: AppColors.surfaceLow.withAlpha((0.7 * 255).round()),
          borderStrokeColor: iconColor.withAlpha((0.35 * 255).round()),
          child: Center(
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withAlpha((0.15 * 255).round()),
                border: Border.all(
                  color: iconColor.withAlpha((0.3 * 255).round()),
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
