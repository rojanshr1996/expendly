import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Design Tokens for Typography matching Modern Fiscal Core specs.
/// Uses [Hanken Grotesk] for all general UI titles, body, labels, and text fields.
/// Uses [JetBrains Mono] strictly for monetary amounts, timestamps, and financial figures.
abstract class AppTypography {
  // Base TextStyles using Hanken Grotesk for General UI

  /// Headline Large (32px, Bold, Line Height 40px, Tracking -0.04em)
  static TextStyle get headlineLarge => GoogleFonts.hankenGrotesk(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -1.28,
        color: AppColors.onSurface,
      );

  /// Headline Large Mobile (28px, Bold, Line Height 34px, Tracking -0.04em)
  static TextStyle get headlineLargeMobile => GoogleFonts.hankenGrotesk(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: -1.12,
        color: AppColors.onSurface,
      );

  /// Headline Medium (24px, SemiBold 600, Line Height 32px, Tracking -0.03em)
  static TextStyle get headlineMedium => GoogleFonts.hankenGrotesk(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.72,
        color: AppColors.onSurface,
      );

  /// Body Large (16px, Regular 400, Line Height 24px, Tracking -0.01em)
  static TextStyle get bodyLarge => GoogleFonts.hankenGrotesk(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: -0.16,
        color: AppColors.onSurface,
      );

  /// Body Large Bold (16px, Bold 700)
  static TextStyle get bodyLargeBold => GoogleFonts.hankenGrotesk(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        height: 24 / 16,
        letterSpacing: -0.16,
        color: AppColors.onSurface,
      );

  /// Body Medium (14px, Regular 400, Line Height 20px, Tracking 0.0em)
  static TextStyle get bodyMedium => GoogleFonts.hankenGrotesk(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0,
        color: AppColors.onSurfaceVariant,
      );

  /// Label Medium (12px, Medium 500, Line Height 16px, Tracking 0.02em - Hanken Grotesk)
  static TextStyle get labelMedium => GoogleFonts.hankenGrotesk(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.24,
        color: AppColors.onSurfaceVariant,
      );

  // Monospaced Styles strictly for Amounts & Financial Figures (JetBrains Mono)

  /// Label Medium Monospaced (12px, Medium 500 - JetBrains Mono)
  static TextStyle get labelMediumMono => GoogleFonts.jetBrainsMono(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.24,
        color: AppColors.onSurfaceVariant,
      );

  /// Currency & Amount Monospaced Display (24px, Bold - JetBrains Mono)
  static TextStyle get amountDisplay => GoogleFonts.jetBrainsMono(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.48,
        color: AppColors.primary,
      );

  /// Amount Large Display (36px, Bold - JetBrains Mono)
  static TextStyle get amountLarge => GoogleFonts.jetBrainsMono(
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        letterSpacing: -0.72,
        color: AppColors.onSurface,
      );

  /// Headline Medium Monospaced Bold (20px, Bold - JetBrains Mono)
  static TextStyle get headlineMediumMonoBold => GoogleFonts.jetBrainsMono(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  /// Headline Large Monospaced Bold (32px, Bold - JetBrains Mono)
  static TextStyle get headlineLargeMonoBold => GoogleFonts.jetBrainsMono(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  /// Build complete ThemeData TextTheme
  static TextTheme buildTextTheme() {
    return TextTheme(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      labelMedium: labelMedium,
      titleMedium: GoogleFonts.hankenGrotesk(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      labelSmall: GoogleFonts.hankenGrotesk(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.outline,
      ),
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
