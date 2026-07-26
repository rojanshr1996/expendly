import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/margin_constants.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/font_weights.dart';

/// A reusable linear step progress indicator widget.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    required this.stepLabel,
    required this.titleLabel,
    this.height,
  });

  /// Value between 0.0 and 1.0
  final double progress;
  final String stepLabel;
  final String titleLabel;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: height ?? 4.h,
          ),
        ),
        verticalMarginXSmall,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stepLabel,
              style: (textTheme.labelMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeights.semiBold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              titleLabel,
              style: (textTheme.labelMedium ?? const TextStyle()).copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
