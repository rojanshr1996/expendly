import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;

    switch (status.toUpperCase()) {
      case 'SETTLED':
        final green = customColors.semanticGreen;
        bgColor = green.withValues(alpha: isLight ? 0.10 : 0.20);
        textColor = isLight ? const Color(0xFF0E6938) : green;
        borderColor = green.withValues(alpha: isLight ? 0.35 : 0.35);
        label = context.l10n.settled;
        break;
      case 'RECURRING':
        final purple = colorScheme.tertiary;
        bgColor = purple.withValues(alpha: isLight ? 0.10 : 0.20);
        textColor = isLight ? const Color(0xFF532488) : purple;
        borderColor = purple.withValues(alpha: isLight ? 0.35 : 0.35);
        label = context.l10n.recurring;
        break;
      case 'ACTIVE':
      default:
        bgColor = colorScheme.primary.withValues(alpha: isLight ? 0.10 : 0.20);
        textColor = isLight
            ? Color.lerp(colorScheme.primary, Colors.black, 0.40)!
            : colorScheme.primary;
        borderColor =
            colorScheme.primary.withValues(alpha: isLight ? 0.35 : 0.35);
        label = context.l10n.active;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: textColor.withValues(alpha: 0.08),
                  blurRadius: 3.r,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.5.w,
            height: 5.5.w,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            label.toUpperCase(),
            style: context.customTypography.labelMediumMono.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
