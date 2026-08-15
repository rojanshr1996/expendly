import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/shimmer_extensions.dart';
import '../../../../core/widgets/glass_container.dart';

class GroupsShimmer extends StatelessWidget {
  const GroupsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GlassContainer(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 150.w, height: 24.h, color: Colors.white),
                    Container(width: 60.w, height: 24.h, color: Colors.white),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80.w, height: 40.h, color: Colors.white),
                    Container(width: 80.w, height: 40.h, color: Colors.white),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(width: 120.w, height: 36.h, color: Colors.white),
              ],
            ),
          );
        },
      ),
    ).animateShimmer();
  }
}
