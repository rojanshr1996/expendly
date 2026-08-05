import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';
import 'user_avatar.dart';

/// Reusable stateless avatar picker widget with camera edit badge overlay.
class ProfileAvatarPicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTapPick;
  final VoidCallback? onTapRemove;

  const ProfileAvatarPicker({
    super.key,
    this.imagePath,
    required this.onTapPick,
    this.onTapRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: onTapPick,
            child: UserAvatar(
              imagePath: imagePath,
              radius: 58.r,
              borderWidth: 2.0,
              iconSize: 52.sp,
            ),
          ),
          Positioned(
            bottom: 2.h,
            right: 2.w,
            child: GestureDetector(
              onTap: onTapPick,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          colorScheme.primary.withAlpha((0.35 * 255).round()),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: colorScheme.onPrimary,
                  size: 18.sp,
                ),
              ),
            ),
          ),
          if (hasImage && onTapRemove != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTapRemove,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onErrorContainer,
                    size: 12.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
