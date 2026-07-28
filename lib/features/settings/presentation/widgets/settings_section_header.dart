import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Section Header component for Settings screen.
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final customTypography = context.customTypography;
    final colorScheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 8.h, top: 16.h),
      child: Text(
        title.toUpperCase(),
        style: customTypography.labelMediumMono.copyWith(
          color: colorScheme.outline,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
