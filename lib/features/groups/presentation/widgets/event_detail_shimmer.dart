import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/shimmer_extensions.dart';
import '../../../../core/widgets/glass_container.dart';

class EventDetailShimmer extends StatelessWidget {
  const EventDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassContainer(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Container(
                      width: double.infinity,
                      height: 24.h,
                      color: Colors.white),
                  SizedBox(height: 16.h),
                  Container(width: 150.w, height: 48.h, color: Colors.white),
                  SizedBox(height: 16.h),
                  Container(width: 120.w, height: 36.h, color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(width: 200.w, height: 40.h, color: Colors.white),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return GlassContainer(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Container(
                            width: 48.w, height: 48.w, color: Colors.white),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 120.w,
                                  height: 16.h,
                                  color: Colors.white),
                              SizedBox(height: 8.h),
                              Container(
                                  width: 80.w,
                                  height: 12.h,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                        Container(
                            width: 60.w, height: 20.h, color: Colors.white),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).animateShimmer();
  }
}
