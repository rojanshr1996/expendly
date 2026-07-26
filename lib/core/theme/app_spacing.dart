import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing tokens matching standard 8px grid ("Fiscal Step").
/// Uses `.w` and `.h` for responsive dimensions via flutter_screenutil.
abstract class AppSpacing {
  static double get stackTight => 4.h;
  static double get base => 8.h;
  static double get innerComponent => 12.h;
  static double get gutterMd => 16.h;
  static double get containerPadding => 24.h;
  static double get sectionSpacing => 32.h;

  // EdgeInsets helpers
  static EdgeInsets get paddingContainer => EdgeInsets.all(24.w);
  static EdgeInsets get paddingHorizontalContainer => EdgeInsets.symmetric(horizontal: 24.w);
  static EdgeInsets get paddingGutter => EdgeInsets.all(16.w);
  static EdgeInsets get paddingInner => EdgeInsets.all(12.w);
  static EdgeInsets get paddingBase => EdgeInsets.all(8.w);

  // Vertical SizedBox gaps
  static SizedBox get gapTight => SizedBox(height: 4.h);
  static SizedBox get gapBase => SizedBox(height: 8.h);
  static SizedBox get gapInner => SizedBox(height: 12.h);
  static SizedBox get gapGutter => SizedBox(height: 16.h);
  static SizedBox get gapContainer => SizedBox(height: 24.h);
  static SizedBox get gapSection => SizedBox(height: 32.h);

  // Horizontal SizedBox gaps
  static SizedBox get gapHorizontalTight => SizedBox(width: 4.w);
  static SizedBox get gapHorizontalBase => SizedBox(width: 8.w);
  static SizedBox get gapHorizontalInner => SizedBox(width: 12.w);
  static SizedBox get gapHorizontalGutter => SizedBox(width: 16.w);
  static SizedBox get gapHorizontalContainer => SizedBox(width: 24.w);
}
