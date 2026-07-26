import 'package:flutter/material.dart';

import 'app_typography.dart';

/// ThemeExtension for financial & domain-specific text styles not part of standard Material 3 TextTheme.
class AppCustomTypography extends ThemeExtension<AppCustomTypography> {
  final TextStyle headlineLargeMobile;
  final TextStyle labelMediumMono;
  final TextStyle amountDisplay;
  final TextStyle amountLarge;

  const AppCustomTypography({
    required this.headlineLargeMobile,
    required this.labelMediumMono,
    required this.amountDisplay,
    required this.amountLarge,
  });

  static final dark = AppCustomTypography(
    headlineLargeMobile: AppTypography.headlineLargeMobile,
    labelMediumMono: AppTypography.labelMediumMono,
    amountDisplay: AppTypography.amountDisplay,
    amountLarge: AppTypography.amountLarge,
  );

  @override
  AppCustomTypography copyWith({
    TextStyle? headlineLargeMobile,
    TextStyle? labelMediumMono,
    TextStyle? amountDisplay,
    TextStyle? amountLarge,
  }) {
    return AppCustomTypography(
      headlineLargeMobile: headlineLargeMobile ?? this.headlineLargeMobile,
      labelMediumMono: labelMediumMono ?? this.labelMediumMono,
      amountDisplay: amountDisplay ?? this.amountDisplay,
      amountLarge: amountLarge ?? this.amountLarge,
    );
  }

  @override
  AppCustomTypography lerp(ThemeExtension<AppCustomTypography>? other, double t) {
    if (other is! AppCustomTypography) return this;
    return AppCustomTypography(
      headlineLargeMobile: TextStyle.lerp(headlineLargeMobile, other.headlineLargeMobile, t)!,
      labelMediumMono: TextStyle.lerp(labelMediumMono, other.labelMediumMono, t)!,
      amountDisplay: TextStyle.lerp(amountDisplay, other.amountDisplay, t)!,
      amountLarge: TextStyle.lerp(amountLarge, other.amountLarge, t)!,
    );
  }
}
