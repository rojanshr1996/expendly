import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/extensions/shimmer_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/widgets/glass_container.dart';

/// Skeleton loader leveraging Skeletonizer & [ShimmerExtension] for Dashboard
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final symbol = getIt<PreferenceService>().currencySymbol;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalMarginSmall,

              // Bento Grid Skeleton Placeholder
              GlassContainer(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    horizontalMarginSmall,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL BALANCE', style: TextStyle(fontSize: 10.sp)),
                        SizedBox(height: 4.h),
                        Text('$symbol 125,450.00', style: TextStyle(fontSize: 16.sp)),
                      ],
                    ),
                  ],
                ),
              ),
              verticalMarginSmall,

              Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EXPENSES', style: TextStyle(fontSize: 10.sp)),
                          SizedBox(height: 8.h),
                          Text('$symbol 3,250.00', style: TextStyle(fontSize: 18.sp)),
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
                          Text('INCOME', style: TextStyle(fontSize: 10.sp)),
                          SizedBox(height: 8.h),
                          Text('$symbol 8,400.00', style: TextStyle(fontSize: 18.sp)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              verticalMarginMedium,

              // Cash Flow Chart Skeleton Placeholder
              GlassContainer(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  height: 180.h,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 120.w, height: 14.h, color: Colors.grey),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          height: 100.h,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              verticalMarginMedium,

              // Recent Activity Skeleton Placeholder
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (i) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: GlassContainer(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          horizontalMarginSmall,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transaction Title',
                                    style: TextStyle(fontSize: 14.sp)),
                                SizedBox(height: 4.h),
                                Text('Category Name',
                                    style: TextStyle(fontSize: 12.sp)),
                              ],
                            ),
                          ),
                          Text('$symbol 150.00', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ).defaultCanvasPadding(),
        ),
      ),
    ).animateShimmer();
  }
}
