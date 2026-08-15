import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';

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
      extendBodyBehindAppBar: true,
      appBar: LiquidGlassAppBar(
        titleText: l10n.aboutExpendly,
        onLeadingPressed: () => context.router.maybePop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
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
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: context.customColors.glassStroke,
                      width: 1.5,
                    ),
                  ),
                  child: (Theme.of(context).brightness == Brightness.light
                      ? Assets.images.expendlyLogoLight.image(
                          fit: BoxFit.contain,
                        )
                      : Assets.images.expendlyLogo.image(
                          fit: BoxFit.contain,
                        )),
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
                      _HighlightItem(
                        icon: Icons.groups_rounded,
                        iconColor: colorScheme.primary,
                        title: 'Group Bill Split & Share',
                        description:
                            'Organize shared events for trips, dinners, and flatmates. Split bills equally or with custom percentages, calculate direct pairwise balances, and settle debts with complete clarity.',
                      ),
                      Divider(
                          height: 24, color: context.customColors.glassStroke),
                      _HighlightItem(
                        icon: Icons.shield_outlined,
                        iconColor: context.customColors.semanticGreen,
                        title: '100% Offline & Private',
                        description:
                            'All personal ledger records and group shared events are stored strictly on your device. Zero cloud sync, no tracking, zero telemetry.',
                      ),
                      Divider(
                          height: 24, color: context.customColors.glassStroke),
                      _HighlightItem(
                        icon: Icons.donut_large_rounded,
                        iconColor: colorScheme.secondary,
                        title: 'Budgets & Insights',
                        description:
                            'Set multi-category budgets, visualize monthly cashflows, customize primary currencies, and manage offline CSV export & restore.',
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
