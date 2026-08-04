import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Application ThemeData configuring Dark Mode, Theme Extensions, and Material 3 design system.
abstract class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = AppTypography.buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),
      textTheme: textTheme,

      // Register Theme Extensions for custom design system colors & typography
      extensions: [
        AppCustomColors.dark,
        AppCustomTypography.dark,
      ],

      // Card Theme (Glassmorphic outline, surfaceLow background)
      cardTheme: CardThemeData(
        color: AppColors.surfaceLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: const BorderSide(color: AppColors.glassStroke, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),

      // App Bar Theme (Clean glass surface)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),

      // Input Field Theme (Surface Mid fill, 1px outline glowing primary on focus)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMid,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        labelStyle: AppTypography.labelMediumMono,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.outline),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderDefault,
          borderSide:
              const BorderSide(color: AppColors.glassStroke, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderDefault,
          borderSide:
              const BorderSide(color: AppColors.glassStroke, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderDefault,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderDefault,
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
      ),

      // Primary Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderDefault,
          ),
          textStyle: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 12.h,
          ),
          side: const BorderSide(color: AppColors.glassStroke, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderDefault,
          ),
          textStyle: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderXl,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        selectedLabelStyle: AppTypography.labelMediumMono,
        unselectedLabelStyle: AppTypography.labelMediumMono,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  /// Application ThemeData configuring Light Mode (Sky Fiscal design system).
  static ThemeData get lightTheme {
    final textTheme =
        AppTypography.buildTextTheme(brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        primaryContainer: AppColors.lightPrimaryContainer,
        onPrimaryContainer: AppColors.lightOnPrimaryContainer,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnSecondary,
        secondaryContainer: AppColors.lightSecondaryContainer,
        onSecondaryContainer: AppColors.lightOnSecondaryContainer,
        tertiary: AppColors.lightTertiary,
        onTertiary: AppColors.lightOnTertiary,
        tertiaryContainer: AppColors.lightTertiaryContainer,
        onTertiaryContainer: AppColors.lightOnTertiaryContainer,
        error: AppColors.lightError,
        onError: AppColors.lightOnError,
        errorContainer: AppColors.lightErrorContainer,
        onErrorContainer: AppColors.lightOnErrorContainer,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
        inverseSurface: AppColors.lightInverseSurface,
        onInverseSurface: AppColors.lightInverseOnSurface,
        inversePrimary: AppColors.lightInversePrimary,
        surfaceTint: AppColors.lightSurfaceTint,
      ),
      textTheme: textTheme,

      // Register Theme Extensions for Light Mode
      extensions: [
        AppCustomColors.light,
        AppCustomTypography.light,
      ],

      // Card Theme (Light container & outline variant stroke)
      cardTheme: CardThemeData(
        color: AppColors.lightSurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side:
              const BorderSide(color: AppColors.lightOutlineVariant, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),

      // App Bar Theme (Clean light background surface)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium
            .copyWith(color: AppColors.lightOnSurface),
        iconTheme: const IconThemeData(color: AppColors.lightOnSurface),
      ),

      // Input Field Theme (Surface Low fill, outline border)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceContainerLow,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        labelStyle: AppTypography.labelMediumMono
            .copyWith(color: AppColors.lightOnSurfaceVariant),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: AppColors.lightOutline),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderDefault,
          borderSide:
              const BorderSide(color: AppColors.lightOutlineVariant, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderDefault,
          borderSide:
              const BorderSide(color: AppColors.lightOutlineVariant, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderDefault,
          borderSide:
              const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderDefault,
          borderSide:
              const BorderSide(color: AppColors.lightError, width: 1.0),
        ),
      ),

      // Primary Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderDefault,
          ),
          textStyle: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.lightOnPrimary,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 12.h,
          ),
          side:
              const BorderSide(color: AppColors.lightOutlineVariant, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderDefault,
          ),
          textStyle: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.lightPrimary,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderXl,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurfaceContainerLow,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightOutline,
        selectedLabelStyle: AppTypography.labelMediumMono
            .copyWith(color: AppColors.lightPrimary),
        unselectedLabelStyle: AppTypography.labelMediumMono
            .copyWith(color: AppColors.lightOutline),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
