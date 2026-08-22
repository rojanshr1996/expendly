import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Design Tokens for Typography matching Modern Fiscal Core specs.
/// Uses [Hanken Grotesk] for all general UI titles, body, labels, and text fields.
/// Uses [JetBrains Mono] strictly for monetary amounts, timestamps, and financial figures.
abstract class AppTypography {
  // Base TextStyles using Hanken Grotesk for General UI

  /// Headline Large (32px, Bold, Line Height 40px, Tracking -0.04em)
  static TextStyle get headlineLarge => GoogleFonts.hankenGrotesk(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -1.28,
        color: AppColors.onSurface,
      );

  /// Headline Large Mobile (28px, Bold, Line Height 34px, Tracking -0.04em)
  static TextStyle get headlineLargeMobile => GoogleFonts.hankenGrotesk(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: -1.12,
        color: AppColors.onSurface,
      );

  /// Headline Medium (24px, SemiBold 600, Line Height 32px, Tracking -0.03em)
  static TextStyle get headlineMedium => GoogleFonts.hankenGrotesk(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.72,
        color: AppColors.onSurface,
      );

  /// Headline Small (20px, SemiBold 600, Line Height 28px, Tracking -0.02em)
  static TextStyle get headlineSmall => GoogleFonts.hankenGrotesk(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        letterSpacing: -0.4,
        color: AppColors.onSurface,
      );

  /// Title Large (22px, Bold 700, Line Height 28px, Tracking -0.02em)
  static TextStyle get titleLarge => GoogleFonts.hankenGrotesk(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        height: 28 / 22,
        letterSpacing: -0.44,
        color: AppColors.onSurface,
      );

  /// Title Medium (18px, SemiBold 600, Line Height 24px, Tracking -0.01em)
  static TextStyle get titleMedium => GoogleFonts.hankenGrotesk(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        letterSpacing: -0.18,
        color: AppColors.onSurface,
      );

  /// Title Small (14px, SemiBold 600, Line Height 20px)
  static TextStyle get titleSmall => GoogleFonts.hankenGrotesk(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  /// Body Large (16px, Regular 400, Line Height 24px, Tracking -0.01em)
  static TextStyle get bodyLarge => GoogleFonts.hankenGrotesk(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: -0.16,
        color: AppColors.onSurface,
      );

  /// Body Large Bold (16px, Bold 700)
  static TextStyle get bodyLargeBold => GoogleFonts.hankenGrotesk(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        height: 24 / 16,
        letterSpacing: -0.16,
        color: AppColors.onSurface,
      );

  /// Body Medium (14px, Regular 400, Line Height 20px, Tracking 0.0em)
  static TextStyle get bodyMedium => GoogleFonts.hankenGrotesk(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0,
        color: AppColors.onSurfaceVariant,
      );

  /// Body Small (12px, Regular 400, Line Height 16px)
  static TextStyle get bodySmall => GoogleFonts.hankenGrotesk(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.onSurfaceVariant,
      );

  /// Label Large (14px, SemiBold 600, Line Height 20px, Tracking 0.01em)
  static TextStyle get labelLarge => GoogleFonts.hankenGrotesk(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.14,
        color: AppColors.onSurface,
      );

  /// Label Medium (12px, Medium 500, Line Height 16px, Tracking 0.02em - Hanken Grotesk)
  static TextStyle get labelMedium => GoogleFonts.hankenGrotesk(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.24,
        color: AppColors.onSurfaceVariant,
      );

  /// Label Small (10px, Medium 500, Line Height 14px)
  static TextStyle get labelSmall => GoogleFonts.hankenGrotesk(
        fontSize: 10.0,
        fontWeight: FontWeight.w500,
        height: 14 / 10,
        color: AppColors.outline,
      );

  // Monospaced Styles strictly for Amounts & Financial Figures (JetBrains Mono)

  /// Label Medium Monospaced (12px, Medium 500 - JetBrains Mono)
  static TextStyle get labelMediumMono => GoogleFonts.jetBrainsMono(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.24,
        color: AppColors.onSurfaceVariant,
      );

  /// Currency & Amount Monospaced Display (24px, Bold - JetBrains Mono)
  static TextStyle get amountDisplay => GoogleFonts.jetBrainsMono(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.48,
        color: AppColors.primary,
      );

  /// Amount Large Display (36px, Bold - JetBrains Mono)
  static TextStyle get amountLarge => GoogleFonts.jetBrainsMono(
        fontSize: 36.0,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        letterSpacing: -0.72,
        color: AppColors.onSurface,
      );

  /// Headline Medium Monospaced Bold (20px, Bold - JetBrains Mono)
  static TextStyle get headlineMediumMonoBold => GoogleFonts.jetBrainsMono(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  /// Headline Large Monospaced Bold (32px, Bold - JetBrains Mono)
  static TextStyle get headlineLargeMonoBold => GoogleFonts.jetBrainsMono(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  /// Build complete ThemeData TextTheme with Hanken Grotesk for all typography levels
  static TextTheme buildTextTheme({Brightness brightness = Brightness.dark}) {
    final isDark = brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant =
        isDark ? AppColors.onSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final outline = isDark ? AppColors.outline : AppColors.lightOutline;

    return TextTheme(
      displayLarge: GoogleFonts.hankenGrotesk(
        fontSize: 57.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.hankenGrotesk(
        fontSize: 45.0,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      displaySmall: GoogleFonts.hankenGrotesk(
        fontSize: 36.0,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      headlineLarge: headlineLarge.copyWith(color: onSurface),
      headlineMedium: headlineMedium.copyWith(color: onSurface),
      headlineSmall: headlineSmall.copyWith(color: onSurface),
      titleLarge: titleLarge.copyWith(color: onSurface),
      titleMedium: titleMedium.copyWith(color: onSurface),
      titleSmall: titleSmall.copyWith(color: onSurface),
      bodyLarge: bodyLarge.copyWith(color: onSurface),
      bodyMedium: bodyMedium.copyWith(color: onSurfaceVariant),
      bodySmall: bodySmall.copyWith(color: onSurfaceVariant),
      labelLarge: labelLarge.copyWith(color: onSurface),
      labelMedium: labelMedium.copyWith(color: onSurfaceVariant),
      labelSmall: labelSmall.copyWith(color: outline),
    );
  }
}

/// ThemeExtension for financial & domain-specific text styles not part of standard Material 3 TextTheme.
class AppCustomTypography extends ThemeExtension<AppCustomTypography> {
  final TextStyle headlineLargeMobile;
  final TextStyle labelMediumMono;
  final TextStyle amountDisplay;
  final TextStyle amountLarge;
  final TextStyle bodyLarge;
  final TextStyle bodyLargeBold;
  final TextStyle bodyMedium;
  final TextStyle headlineMediumMonoBold;
  final TextStyle headlineLargeMonoBold;

  const AppCustomTypography({
    required this.headlineLargeMobile,
    required this.labelMediumMono,
    required this.amountDisplay,
    required this.amountLarge,
    required this.bodyLarge,
    required this.bodyLargeBold,
    required this.bodyMedium,
    required this.headlineMediumMonoBold,
    required this.headlineLargeMonoBold,
  });

  static final dark = AppCustomTypography(
    headlineLargeMobile: AppTypography.headlineLargeMobile,
    labelMediumMono: AppTypography.labelMediumMono,
    amountDisplay: AppTypography.amountDisplay,
    amountLarge: AppTypography.amountLarge,
    bodyLarge: AppTypography.bodyLarge,
    bodyLargeBold: AppTypography.bodyLargeBold,
    bodyMedium: AppTypography.bodyMedium,
    headlineMediumMonoBold: AppTypography.headlineMediumMonoBold,
    headlineLargeMonoBold: AppTypography.headlineLargeMonoBold,
  );

  static final light = AppCustomTypography(
    headlineLargeMobile: AppTypography.headlineLargeMobile
        .copyWith(color: AppColors.lightOnSurface),
    labelMediumMono: AppTypography.labelMediumMono
        .copyWith(color: AppColors.lightOnSurfaceVariant),
    amountDisplay:
        AppTypography.amountDisplay.copyWith(color: AppColors.lightPrimary),
    amountLarge:
        AppTypography.amountLarge.copyWith(color: AppColors.lightOnSurface),
    bodyLarge:
        AppTypography.bodyLarge.copyWith(color: AppColors.lightOnSurface),
    bodyLargeBold:
        AppTypography.bodyLargeBold.copyWith(color: AppColors.lightOnSurface),
    bodyMedium: AppTypography.bodyMedium
        .copyWith(color: AppColors.lightOnSurfaceVariant),
    headlineMediumMonoBold: AppTypography.headlineMediumMonoBold
        .copyWith(color: AppColors.lightOnSurface),
    headlineLargeMonoBold: AppTypography.headlineLargeMonoBold
        .copyWith(color: AppColors.lightOnSurface),
  );

  @override
  AppCustomTypography copyWith({
    TextStyle? headlineLargeMobile,
    TextStyle? labelMediumMono,
    TextStyle? amountDisplay,
    TextStyle? amountLarge,
    TextStyle? bodyLarge,
    TextStyle? bodyLargeBold,
    TextStyle? bodyMedium,
    TextStyle? headlineMediumMonoBold,
    TextStyle? headlineLargeMonoBold,
  }) {
    return AppCustomTypography(
      headlineLargeMobile: headlineLargeMobile ?? this.headlineLargeMobile,
      labelMediumMono: labelMediumMono ?? this.labelMediumMono,
      amountDisplay: amountDisplay ?? this.amountDisplay,
      amountLarge: amountLarge ?? this.amountLarge,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyLargeBold: bodyLargeBold ?? this.bodyLargeBold,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      headlineMediumMonoBold:
          headlineMediumMonoBold ?? this.headlineMediumMonoBold,
      headlineLargeMonoBold:
          headlineLargeMonoBold ?? this.headlineLargeMonoBold,
    );
  }

  @override
  AppCustomTypography lerp(
      ThemeExtension<AppCustomTypography>? other, double t) {
    if (other is! AppCustomTypography) return this;
    return AppCustomTypography(
      headlineLargeMobile:
          TextStyle.lerp(headlineLargeMobile, other.headlineLargeMobile, t)!,
      labelMediumMono:
          TextStyle.lerp(labelMediumMono, other.labelMediumMono, t)!,
      amountDisplay: TextStyle.lerp(amountDisplay, other.amountDisplay, t)!,
      amountLarge: TextStyle.lerp(amountLarge, other.amountLarge, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyLargeBold: TextStyle.lerp(bodyLargeBold, other.bodyLargeBold, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      headlineMediumMonoBold: TextStyle.lerp(
          headlineMediumMonoBold, other.headlineMediumMonoBold, t)!,
      headlineLargeMonoBold: TextStyle.lerp(
          headlineLargeMonoBold, other.headlineLargeMonoBold, t)!,
    );
  }
}
