import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Horizontal Margins
SizedBox get horizontalMarginTiny => SizedBox(width: 2.w); // Tiny margin
SizedBox get horizontalMarginXXSmall =>
    SizedBox(width: 4.w); // Extra small margin
SizedBox get horizontalMarginXSmall => SizedBox(width: 8.w); // X Small margin
SizedBox get horizontalMarginSmall => SizedBox(width: 12.w); // Small margin
SizedBox get horizontalMarginMedium => SizedBox(width: 16.w); // Medium margin
SizedBox get horizontalMarginLarge => SizedBox(width: 24.w); // Large margin
SizedBox get horizontalMarginXLarge =>
    SizedBox(width: 32.w); // Extra-large margin
SizedBox get horizontalMarginXXLarge =>
    SizedBox(width: 48.w); // Extra-extra-large margin

// Vertical Margins
SizedBox get verticalMarginTiny => SizedBox(height: 2.h); // Tiny margin
SizedBox get verticalMarginXXSmall =>
    SizedBox(height: 4.h); // Extra small margin
SizedBox get verticalMarginXSmall => SizedBox(height: 8.h); // X Small margin
SizedBox get verticalMarginSmall => SizedBox(height: 12.h); // Small margin
SizedBox get verticalMarginMedium => SizedBox(height: 16.h); // Medium margin
SizedBox get verticalMargin20 => SizedBox(height: 20.h); // 20 margin
SizedBox get verticalMarginLarge => SizedBox(height: 24.h); // Large margin
SizedBox get verticalMargin26 => SizedBox(height: 26.h); // 24 margin
SizedBox get verticalMarginXLarge =>
    SizedBox(height: 32.h); // Extra-large margin
SizedBox get verticalMargin40 => SizedBox(height: 40.h); // 40 margin
SizedBox get verticalMarginXXLarge =>
    SizedBox(height: 48.h); // Extra-extra-large margin

SizedBox verticalMargin({required double height}) => SizedBox(height: height.h);

SizedBox get emptyBox => const SizedBox.shrink(); // Empty box
