import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';

@RoutePage()
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: LiquidGlassAppBar(
        titleText: l10n.termsAndConditions,
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
                verticalMarginMedium,
                _TermsSectionCard(
                  title: l10n.termsTitle1,
                  body: l10n.termsBody1,
                  icon: Icons.folder_special_outlined,
                ),
                verticalMarginMedium,
                _TermsSectionCard(
                  title: l10n.termsTitle2,
                  body: l10n.termsBody2,
                  icon: Icons.security_rounded,
                ),
                verticalMarginMedium,
                _TermsSectionCard(
                  title: l10n.termsTitle3,
                  body: l10n.termsBody3,
                  icon: Icons.cloud_off_rounded,
                ),
                verticalMarginMedium,
                _TermsSectionCard(
                  title: l10n.termsTitle4,
                  body: l10n.termsBody4,
                  icon: Icons.gavel_rounded,
                ),
                verticalMarginLarge,
                Text(
                  'Last Updated: July 2026',
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

class _TermsSectionCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _TermsSectionCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: colorScheme.primary,
                size: 20.sp,
              ),
              horizontalMarginSmall,
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeights.bold,
                  ),
                ),
              ),
            ],
          ),
          verticalMarginSmall,
          Text(
            body,
            style: customTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
