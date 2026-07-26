import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Border radius tokens for Expendly app matching Modern Fiscal Core design system.
/// Uses `.r` for responsive corner radii via flutter_screenutil.
abstract class AppRadius {
  static double get sm => 4.r;
  static double get defaultRadius => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 24.r;
  static double get full => 9999.r;

  // BorderRadius instances
  static BorderRadius get borderSm => BorderRadius.all(Radius.circular(4.r));
  static BorderRadius get borderDefault => BorderRadius.all(Radius.circular(8.r));
  static BorderRadius get borderMd => BorderRadius.all(Radius.circular(12.r));
  static BorderRadius get borderLg => BorderRadius.all(Radius.circular(16.r));
  static BorderRadius get borderXl => BorderRadius.all(Radius.circular(24.r));
  static BorderRadius get borderFull => BorderRadius.all(Radius.circular(9999.r));
}
