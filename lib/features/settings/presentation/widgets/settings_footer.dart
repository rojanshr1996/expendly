import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Footer component for Settings screen displaying app version and brand message.
class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Center(
        child: Column(
          children: [
            Text(
              '${context.l10n.appName} v1.0.0',
              style: customTypography.labelMediumMono.copyWith(
                color: colorScheme.outline,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              context.l10n.settingsFooterTagline,
              textAlign: TextAlign.center,
              style: customTypography.bodyMedium.copyWith(
                color: colorScheme.outline.withAlpha((0.7 * 255).round()),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
