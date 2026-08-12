import 'package:flutter/material.dart';
import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_progress_bar.dart';

/// Reusable onboarding step header displaying top progress bar, step labels, and an optional Skip button.
class OnboardingHeader extends StatelessWidget {
  final double progress;
  final String stepLabel;
  final String titleLabel;
  final VoidCallback? onSkip;

  const OnboardingHeader({
    super.key,
    required this.progress,
    required this.stepLabel,
    required this.titleLabel,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppProgressBar(
                progress: progress,
                stepLabel: stepLabel,
                titleLabel: titleLabel,
              ),
            ),
            if (onSkip != null) ...[
              horizontalMarginSmall,
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  l10n.skip,
                  style: (textTheme.labelLarge ?? const TextStyle()).copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeights.semiBold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
