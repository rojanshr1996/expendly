import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';

@RoutePage()
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          l10n.aboutExpendly,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeights.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: Column(
              children: [
                verticalMarginLarge,

                // App Logo Hero Container
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colorScheme.primary,
                    size: 40.sp,
                  ),
                ),
                verticalMarginMedium,

                // App Name & Version
                Text(
                  l10n.appName,
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeights.bold,
                  ),
                ),
                verticalMarginXXSmall,
                Text(
                  l10n.aboutExpendlySubtitle,
                  style: customTypography.labelMediumMono.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                verticalMarginLarge,

                // System Highlights Card
                GlassContainer(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HighlightItem(
                        icon: Icons.shield_outlined,
                        iconColor: AppColors.semanticGreen,
                        title: '100% Offline & Private',
                        description:
                            'Your financial data is stored strictly on your device. No cloud sync, no tracking, zero telemetry.',
                      ),
                      const Divider(height: 24, color: AppColors.glassStroke),
                      _HighlightItem(
                        icon: Icons.lock_outline_rounded,
                        iconColor: colorScheme.primary,
                        title: 'Local Storage',
                        description:
                            'Stored locally on your device via Android & iOS secure storage.',
                      ),
                      const Divider(height: 24, color: AppColors.glassStroke),
                      _HighlightItem(
                        icon: Icons.architecture_rounded,
                        iconColor: colorScheme.tertiary,
                        title: 'Modern Fiscal Architecture',
                        description:
                            'Engineered with Flutter Clean Architecture, Drift SQLite, and flutter_bloc Cubits.',
                      ),
                    ],
                  ),
                ),
                verticalMarginLarge,

                // Footer Note
                Text(
                  'Expendly • Designed for Fiscal Calm',
                  style: customTypography.labelMediumMono.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                verticalMarginLarge,
              ],
            ).defaultCanvasPadding(),
          ),
        ),
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _HighlightItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
        horizontalMarginSmall,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeights.bold,
                ),
              ),
              verticalMarginXXSmall,
              Text(
                description,
                style: customTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
