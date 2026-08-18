import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class ParticipantAvatar extends StatelessWidget {
  final String name;
  final int colorIndex;

  const ParticipantAvatar({
    super.key,
    required this.name,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colors = [
      AppColors.semanticGreen,
      AppColors.semanticRed,
      context.colorScheme.primary,
      context.colorScheme.secondary,
      Colors.orange,
      Colors.purple,
    ];
    final color = colors[colorIndex % colors.length];

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.10),
                ]
              : [
                  color.withValues(alpha: 0.30),
                  color.withValues(alpha: 0.16),
                ],
        ),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.75)
              : color.withValues(alpha: 0.50),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.6 : 0.0),
            blurRadius: 4.r,
            spreadRadius: -1.r,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: color.withValues(alpha: isLight ? 0.18 : 0.30),
            blurRadius: 6.r,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: context.customTypography.labelMediumMono.copyWith(
          color: isLight ? color.withValues(alpha: 0.95) : color,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
