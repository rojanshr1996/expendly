import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Reusable stateless avatar widget to display user profile image or fallback icon.
class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final IconData fallbackIcon;
  final double? iconSize;

  const UserAvatar({
    super.key,
    this.imagePath,
    this.radius = 20.0,
    this.borderColor,
    this.borderWidth = 1.5,
    this.fallbackIcon = Icons.person_rounded,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final effectiveBorderColor =
        borderColor ?? colorScheme.primary.withAlpha((0.35 * 255).round());

    final bool hasValidImage = imagePath != null &&
        imagePath!.trim().isNotEmpty &&
        File(imagePath!).existsSync();

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: hasValidImage
            ? Image.file(
                File(imagePath!),
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(colorScheme),
              )
            : _buildFallback(colorScheme),
      ),
    );
  }

  Widget _buildFallback(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        fallbackIcon,
        color: colorScheme.primary,
        size: iconSize ?? (radius * 1.1).sp,
      ),
    );
  }
}
