import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/shimmer_extensions.dart';
import '../../../../core/widgets/glass_container.dart';

/// Skeleton shimmer loader widget for [BudgetsOverviewPage].
class BudgetsOverviewShimmer extends StatelessWidget {
  const BudgetsOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Budget Health Card Skeleton Placeholder
          GlassContainer(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MONTHLY SPENDING', style: TextStyle(fontSize: 10.sp)),
                    Text('0% Used', style: TextStyle(fontSize: 10.sp)),
                  ],
                ),
                SizedBox(height: 12.h),
                Text('\$0.00 of \$0.00', style: TextStyle(fontSize: 22.sp)),
                SizedBox(height: 14.h),
                Container(
                  height: 10.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
          ),

          verticalMarginMedium,

          // Section Header Skeleton Placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: TextStyle(fontSize: 16.sp)),
              Text('0 Active', style: TextStyle(fontSize: 12.sp)),
            ],
          ),

          verticalMarginSmall,

          // Category Budget Cards Skeletons
          ...List.generate(3, (i) {
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: GlassContainer(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        horizontalMarginSmall,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category Name', style: TextStyle(fontSize: 14.sp)),
                              SizedBox(height: 4.h),
                              Text('\$0.00 left of \$0.00', style: TextStyle(fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        Text('0%', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      height: 6.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ).animateShimmer();
  }
}
