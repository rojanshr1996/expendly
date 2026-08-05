import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/shimmer_extensions.dart';
import '../../../../core/widgets/glass_container.dart';

/// Skeleton shimmer loader widget for [AllTransactionsPage] (Activity screen).
class AllTransactionsShimmer extends StatelessWidget {
  const AllTransactionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header Placeholder
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Text('TODAY', style: TextStyle(fontSize: 12.sp)),
          ),

          // Transaction List Item Skeletons
          ...List.generate(5, (i) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              padding: EdgeInsets.all(12.w),
              child: GlassContainer(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
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
                          Text('Category Name',
                              style: TextStyle(fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          Text('Note details placeholder',
                              style: TextStyle(fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    Text('\$00.00', style: TextStyle(fontSize: 14.sp)),
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
