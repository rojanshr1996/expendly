import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

EdgeInsets get emptyPadding => EdgeInsets.zero;

// Horizontal Padding (hp)
EdgeInsets get horizontalPaddingTiny =>
    EdgeInsets.symmetric(horizontal: 2.w); // Tiny horizontal padding
EdgeInsets get horizontalPaddingXXSmall =>
    EdgeInsets.symmetric(horizontal: 4.w); // XX small horizontal padding
EdgeInsets get horizontalPaddingXSmall =>
    EdgeInsets.symmetric(horizontal: 8.w); // X Small horizontal padding
EdgeInsets get horizontalPaddingSmall =>
    EdgeInsets.symmetric(horizontal: 12.w); // Small horizontal padding
EdgeInsets get horizontalPaddingMedium =>
    EdgeInsets.symmetric(horizontal: 16.w); // Medium horizontal padding
EdgeInsets get horizontalPaddingLarge =>
    EdgeInsets.symmetric(horizontal: 24.w); // Large horizontal padding
EdgeInsets get horizontalPaddingXLarge =>
    EdgeInsets.symmetric(horizontal: 32.w); // X-large horizontal padding
EdgeInsets get horizontalPaddingXXLarge =>
    EdgeInsets.symmetric(horizontal: 48.w); // X-X-large horizontal padding

// Vertical Padding (vp)
EdgeInsets get verticalPaddingTiny =>
    EdgeInsets.symmetric(vertical: 2.h); // Tiny vertical padding
EdgeInsets get verticalPaddingXXSmall =>
    EdgeInsets.symmetric(vertical: 4.h); // XX small vertical padding
EdgeInsets get verticalPaddingXSmall =>
    EdgeInsets.symmetric(vertical: 8.h); // X Small vertical padding
EdgeInsets get verticalPaddingSmall =>
    EdgeInsets.symmetric(vertical: 12.h); // Small vertical padding
EdgeInsets get verticalPaddingMedium =>
    EdgeInsets.symmetric(vertical: 16.h); // Medium vertical padding
EdgeInsets get verticalPaddingLarge =>
    EdgeInsets.symmetric(vertical: 24.h); // Large vertical padding
EdgeInsets get verticalPaddingXLarge =>
    EdgeInsets.symmetric(vertical: 32.h); // X-large vertical padding
EdgeInsets get verticalPaddingXXLarge =>
    EdgeInsets.symmetric(vertical: 48.h); // X-X-large vertical padding

// Symmetric Padding (both horizontal & vertical)
EdgeInsets get symmetricPaddingTiny => EdgeInsets.symmetric(
      horizontal: 2.w,
      vertical: 2.h,
    ); // Tiny symmetric padding
EdgeInsets get symmetricPaddingXXSmall => EdgeInsets.symmetric(
      horizontal: 4.w,
      vertical: 4.h,
    ); // XX small symmetric padding
EdgeInsets get symmetricPaddingXSmall => EdgeInsets.symmetric(
      horizontal: 8.w,
      vertical: 8.h,
    ); // X Small symmetric padding
EdgeInsets get symmetricPaddingSmall => EdgeInsets.symmetric(
      horizontal: 12.w,
      vertical: 12.h,
    ); // Small symmetric padding
EdgeInsets get symmetricPaddingMedium => EdgeInsets.symmetric(
      horizontal: 16.w,
      vertical: 16.h,
    ); // Medium symmetric padding
EdgeInsets get symmetricPaddingLarge => EdgeInsets.symmetric(
      horizontal: 24.w,
      vertical: 24.h,
    ); // Large symmetric padding
EdgeInsets get symmetricPaddingXLarge => EdgeInsets.symmetric(
      horizontal: 32.w,
      vertical: 32.h,
    ); // X-large symmetric padding
EdgeInsets get symmetricPaddingXXLarge => EdgeInsets.symmetric(
      horizontal: 48.w,
      vertical: 48.h,
    ); // X-X-large symmetric padding

// All Padding (uniform on all sides) - uses .w for horizontal and .h for vertical
EdgeInsets get allTiny =>
    EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h); // Tiny all padding
EdgeInsets get allXXSmall =>
    EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h); // X small all padding
EdgeInsets get allXSmall =>
    EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h); // Small all padding
EdgeInsets get allSmall =>
    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h); // Small all padding
EdgeInsets get allMedium => EdgeInsets.symmetric(
      horizontal: 16.w,
      vertical: 16.h,
    ); // Medium all padding
EdgeInsets get allLarge =>
    EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h); // Large all padding
EdgeInsets get allXLarge => EdgeInsets.symmetric(
      horizontal: 32.w,
      vertical: 32.h,
    ); // X-large all padding
EdgeInsets get allXXLarge => EdgeInsets.symmetric(
      horizontal: 48.w,
      vertical: 48.h,
    ); // X-X-large all padding
