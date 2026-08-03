import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/shimmer_extensions.dart';
import '../../../../core/widgets/glass_container.dart';

/// Skeleton shimmer loader widget for [RefinedReportsPage] (Reports & Analytics screen).
class ReportsShimmer extends StatelessWidget {
  const ReportsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Skeleton Row
          Row(
            children: List.generate(4, (i) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                width: 70.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              );
            }),
          ),

          verticalMarginMedium,

          // Summary Cards Row Skeleton
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL INCOME', style: TextStyle(fontSize: 10.sp)),
                      SizedBox(height: 8.h),
                      Text('\$0.00', style: TextStyle(fontSize: 18.sp)),
                    ],
                  ),
                ),
              ),
              horizontalMarginSmall,
              Expanded(
                child: GlassContainer(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL EXPENSE', style: TextStyle(fontSize: 10.sp)),
                      SizedBox(height: 8.h),
                      Text('\$0.00', style: TextStyle(fontSize: 18.sp)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          verticalMarginMedium,

          // Chart Section Skeleton Placeholder
          GlassContainer(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EXPENSE BREAKDOWN', style: TextStyle(fontSize: 10.sp)),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 160.h,
                  child: Center(
                    child: Container(
                      width: 130.w,
                      height: 130.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceContainerHigh,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          verticalMarginMedium,

          // Category Share List Skeleton
          Column(
            children: List.generate(3, (i) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                child: GlassContainer(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.surfaceContainerHigh,
                            ),
                          ),
                          horizontalMarginSmall,
                          Text('Category Share',
                              style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                      Text('\$0.00 (0%)', style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ).animateShimmer();
  }
}
