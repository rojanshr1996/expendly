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
  static const Color surfaceLow =
      Color(0xFF1E293B); // Level 1: Primary card containers
  static const Color surfaceMid =
      Color(0xFF334155); // Level 2: Inputs / Active states

  // Outlines & Borders
  static const Color outline = Color(0xFF859490);
  static const Color outlineVariant = Color(0xFF3C4A46);
  static const Color glassStroke =
      Color(0x1AFFFFFF); // 10% white stroke for glassmorphism

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
  static const Color semanticRed = Color(0xFFFB7185); // Expense
  static const Color semanticGreen = Color(0xFF34D399); // Income

  // ---------------------------------------------------------------------------
  // Light Mode Design System Tokens (Sky Fiscal)
  // ---------------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFFAF8FF);
  static const Color lightOnBackground = Color(0xFF131B2E);

  static const Color lightSurface = Color(0xFFFAF8FF);
  static const Color lightSurfaceDim = Color(0xFFD2D9F4);
  static const Color lightSurfaceBright = Color(0xFFFAF8FF);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF2F3FF);
  static const Color lightSurfaceContainer = Color(0xFFEAEDFF);
  static const Color lightSurfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color lightSurfaceContainerHighest = Color(0xFFDAE2FD);

  static const Color lightOnSurface = Color(0xFF131B2E);
  static const Color lightOnSurfaceVariant = Color(0xFF3F4850);
  static const Color lightInverseSurface = Color(0xFF283044);
  static const Color lightInverseOnSurface = Color(0xFFEEF0FF);
  static const Color lightOutline = Color(0xFF707881);
  static const Color lightOutlineVariant = Color(0xFFBFC7D2);
  static const Color lightSurfaceTint = Color(0xFF006398);
  static const Color lightSurfaceVariant = Color(0xFFDAE2FD);

  // Light Tonal Elevation Layers
  static const Color lightSurfaceLowest = Color(0xFFFAF8FF);
  static const Color lightSurfaceLow = Color(0xFFF2F3FF);
  static const Color lightSurfaceMid = Color(0xFFEAEDFF);
  static const Color lightGlassStroke = Color(0x1F707881);

  // Light Primary Palette
  static const Color lightPrimary = Color(0xFF006194);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF007BB9);
  static const Color lightOnPrimaryContainer = Color(0xFFFDFCFF);
  static const Color lightInversePrimary = Color(0xFF93CCFF);

  static const Color lightPrimaryFixed = Color(0xFFCCE5FF);
  static const Color lightPrimaryFixedDim = Color(0xFF93CCFF);
  static const Color lightOnPrimaryFixed = Color(0xFF001D31);
  static const Color lightOnPrimaryFixedVariant = Color(0xFF004B73);

  // Light Secondary Palette
  static const Color lightSecondary = Color(0xFF006C49);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFF6CF8BB);
  static const Color lightOnSecondaryContainer = Color(0xFF00714D);

  static const Color lightSecondaryFixed = Color(0xFF6FFBBE);
  static const Color lightSecondaryFixedDim = Color(0xFF4EDEA3);
  static const Color lightOnSecondaryFixed = Color(0xFF002113);
  static const Color lightOnSecondaryFixedVariant = Color(0xFF005236);

  // Light Tertiary Palette
  static const Color lightTertiary = Color(0xFFA53337);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFC64B4D);
  static const Color lightOnTertiaryContainer = Color(0xFFFFFBFF);

  static const Color lightTertiaryFixed = Color(0xFFFFDAD8);
  static const Color lightTertiaryFixedDim = Color(0xFFFFB3B0);
  static const Color lightOnTertiaryFixed = Color(0xFF410006);
  static const Color lightOnTertiaryFixedVariant = Color(0xFF881D24);

  // Light Error & Status Palette
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF93000A);

  // Light Financial Semantics
  static const Color lightSemanticRed = Color(0xFFBA1A1A);
  static const Color lightSemanticGreen = Color(0xFF006C49);
}

/// ThemeExtension for custom design system colors not covered by standard Material 3 ColorScheme.
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color surfaceLowest;
  final Color surfaceLow;
  final Color surfaceMid;
  final Color semanticRed;
  final Color semanticGreen;
  final Color semanticBlue;
  final Color glassStroke;

  const AppCustomColors({
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.surfaceMid,
    required this.semanticRed,
    required this.semanticGreen,
    required this.semanticBlue,
    required this.glassStroke,
  });

  static const dark = AppCustomColors(
    surfaceLowest: AppColors.surfaceLowest,
    surfaceLow: AppColors.surfaceLow,
    surfaceMid: AppColors.surfaceMid,
    semanticRed: AppColors.semanticRed,
    semanticGreen: AppColors.semanticGreen,
    semanticBlue: Color(0xFF60A5FA),
    glassStroke: AppColors.glassStroke,
  );

  static const light = AppCustomColors(
    surfaceLowest: AppColors.lightSurfaceLowest,
    surfaceLow: AppColors.lightSurfaceLow,
    surfaceMid: AppColors.lightSurfaceMid,
    semanticRed: AppColors.lightSemanticRed,
    semanticGreen: AppColors.lightSemanticGreen,
    semanticBlue: AppColors.lightPrimary,
    glassStroke: AppColors.lightGlassStroke,
  );

  @override
  AppCustomColors copyWith({
    Color? surfaceLowest,
    Color? surfaceLow,
    Color? surfaceMid,
    Color? semanticRed,
    Color? semanticGreen,
    Color? semanticBlue,
    Color? glassStroke,
  }) {
    return AppCustomColors(
      surfaceLowest: surfaceLowest ?? this.surfaceLowest,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceMid: surfaceMid ?? this.surfaceMid,
      semanticRed: semanticRed ?? this.semanticRed,
      semanticGreen: semanticGreen ?? this.semanticGreen,
      semanticBlue: semanticBlue ?? this.semanticBlue,
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
      semanticBlue: Color.lerp(semanticBlue, other.semanticBlue, t)!,
      glassStroke: Color.lerp(glassStroke, other.glassStroke, t)!,
    );
  }
}
