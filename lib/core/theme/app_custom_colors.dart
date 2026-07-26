import 'package:flutter/material.dart';

import 'app_colors.dart';

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
