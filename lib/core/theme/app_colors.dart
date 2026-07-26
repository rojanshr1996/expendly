import 'package:flutter/material.dart';

/// Design Tokens for Color Palette from Modern Fiscal Core design system.
abstract class AppColors {
  // Base & Canvas
  static const Color background = Color(0xFF0E1513);
  static const Color onBackground = Color(0xFFDDE4E1);

  // Surface System (Midnight Slate Foundation)
  static const Color surface = Color(0xFF0E1513);
  static const Color surfaceDim = Color(0xFF0E1513);
  static const Color surfaceBright = Color(0xFF333B39);
  static const Color surfaceContainerLowest = Color(0xFF09100E);
  static const Color surfaceContainerLow = Color(0xFF161D1B);
  static const Color surfaceContainer = Color(0xFF1A211F);
  static const Color surfaceContainerHigh = Color(0xFF242B2A);
  static const Color surfaceContainerHighest = Color(0xFF2F3634);

  static const Color onSurface = Color(0xFFDDE4E1);
  static const Color onSurfaceVariant = Color(0xFFBACAC5);
  static const Color inverseSurface = Color(0xFFDDE4E1);
  static const Color inverseOnSurface = Color(0xFF2B3230);
  static const Color surfaceVariant = Color(0xFF2F3634);

  // Tonal Elevation Layers
  static const Color surfaceLowest = Color(0xFF0F172A); // Level 0: Canvas
  static const Color surfaceLow = Color(0xFF1E293B);    // Level 1: Primary card containers
  static const Color surfaceMid = Color(0xFF334155);    // Level 2: Inputs / Active states

  // Outlines & Borders
  static const Color outline = Color(0xFF859490);
  static const Color outlineVariant = Color(0xFF3C4A46);
  static const Color glassStroke = Color(0x1AFFFFFF); // 10% white stroke for glassmorphism

  // Primary Palette (Refined Teal)
  static const Color primary = Color(0xFF57F1DB);
  static const Color onPrimary = Color(0xFF003731);
  static const Color primaryContainer = Color(0xFF2DD4BF);
  static const Color onPrimaryContainer = Color(0xFF00574D);
  static const Color inversePrimary = Color(0xFF006B5F);
  static const Color surfaceTint = Color(0xFF3CDDC7);

  static const Color primaryFixed = Color(0xFF62FAE3);
  static const Color primaryFixedDim = Color(0xFF3CDDC7);
  static const Color onPrimaryFixed = Color(0xFF00201C);
  static const Color onPrimaryFixedVariant = Color(0xFF005047);

  // Secondary Palette
  static const Color secondary = Color(0xFFC0C1FF);
  static const Color onSecondary = Color(0xFF1000A9);
  static const Color secondaryContainer = Color(0xFF3131C0);
  static const Color onSecondaryContainer = Color(0xFFB0B2FF);

  static const Color secondaryFixed = Color(0xFFE1E0FF);
  static const Color secondaryFixedDim = Color(0xFFC0C1FF);
  static const Color onSecondaryFixed = Color(0xFF07006C);
  static const Color onSecondaryFixedVariant = Color(0xFF2F2EBE);

  // Tertiary Palette
  static const Color tertiary = Color(0xFFFFD1AA);
  static const Color onTertiary = Color(0xFF4B2800);
  static const Color tertiaryContainer = Color(0xFFFFAC5A);
  static const Color onTertiaryContainer = Color(0xFF744000);

  static const Color tertiaryFixed = Color(0xFFFFDCC0);
  static const Color tertiaryFixedDim = Color(0xFFFFB875);
  static const Color onTertiaryFixed = Color(0xFF2D1600);
  static const Color onTertiaryFixedVariant = Color(0xFF6B3B00);

  // Error & Status Palette
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Semantic Financial Colors (Desaturated for low fatigue)
  static const Color semanticRed = Color(0xFFFB7185);   // Expense
  static const Color semanticGreen = Color(0xFF34D399); // Income
}

/// ThemeExtension for custom design system colors not covered by standard Material 3 ColorScheme.
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color surfaceLowest;
  final Color surfaceLow;
  final Color surfaceMid;
  final Color semanticRed;
  final Color semanticGreen;
  final Color glassStroke;

  const AppCustomColors({
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.surfaceMid,
    required this.semanticRed,
    required this.semanticGreen,
    required this.glassStroke,
  });

  static const dark = AppCustomColors(
    surfaceLowest: AppColors.surfaceLowest,
    surfaceLow: AppColors.surfaceLow,
    surfaceMid: AppColors.surfaceMid,
    semanticRed: AppColors.semanticRed,
    semanticGreen: AppColors.semanticGreen,
    glassStroke: AppColors.glassStroke,
  );

  @override
  AppCustomColors copyWith({
    Color? surfaceLowest,
    Color? surfaceLow,
    Color? surfaceMid,
    Color? semanticRed,
    Color? semanticGreen,
    Color? glassStroke,
  }) {
    return AppCustomColors(
      surfaceLowest: surfaceLowest ?? this.surfaceLowest,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceMid: surfaceMid ?? this.surfaceMid,
      semanticRed: semanticRed ?? this.semanticRed,
      semanticGreen: semanticGreen ?? this.semanticGreen,
      glassStroke: glassStroke ?? this.glassStroke,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      surfaceLowest: Color.lerp(surfaceLowest, other.surfaceLowest, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceMid: Color.lerp(surfaceMid, other.surfaceMid, t)!,
      semanticRed: Color.lerp(semanticRed, other.semanticRed, t)!,
      semanticGreen: Color.lerp(semanticGreen, other.semanticGreen, t)!,
      glassStroke: Color.lerp(glassStroke, other.glassStroke, t)!,
    );
  }
}
