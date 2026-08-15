import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/sharing_event.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import 'status_badge.dart';
import 'participant_avatar_row.dart';
import '../../../../core/extensions/context_extensions.dart';

class EventCard extends StatelessWidget {
  final SharingEvent event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'trip':
        return '✈️';
      case 'dinner':
        return '🍴';
      case 'home':
        return '🏠';
      case 'party':
        return '🎉';
      case 'groceries':
        return '🛒';
      case 'utilities':
        return '⚡';
      case 'entertainment':
        return '🎬';
      case 'transport':
        return '🚗';
      case 'shopping':
        return '🛍️';
      case 'sports':
        return '⚽';
      case 'work':
        return '💼';
      case 'others':
      default:
        return '📁';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = BorderRadius.circular(20.r);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: br,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? [
                    colorScheme.surfaceContainerLowest.withValues(alpha: 0.75),
                    colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
                  ]
                : [
                    colorScheme.surfaceContainerHigh.withValues(alpha: 0.32),
                    colorScheme.surfaceContainerLow.withValues(alpha: 0.18),
                  ],
          ),
          border: Border.all(
            color: isLight
                ? Colors.white.withValues(alpha: 0.75)
                : customColors.glassStroke.withValues(alpha: 0.50),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: isLight ? 0.6 : 0.0),
              blurRadius: 6.r,
              spreadRadius: -1.r,
              offset: const Offset(0, -1),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.16),
              blurRadius: 14.r,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: br,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Category Icon, Name, Members & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: isLight ? 0.10 : 0.16),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: isLight ? 0.20 : 0.28),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _getCategoryIcon(event.category),
                                style: TextStyle(fontSize: 20.sp),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name,
                                    style:
                                        customTypography.bodyLargeBold.copyWith(
                                      color: colorScheme.onSurface,
                                      fontSize: 15.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Row(
                                    children: [
                                      Text(
                                        event.category.toUpperCase(),
                                        style: customTypography.labelMediumMono
                                            .copyWith(
                                          color: colorScheme.primary,
                                          fontSize: 10.sp,
                                          letterSpacing: 0.8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          color: colorScheme.outline,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '${event.participants.length} ${context.l10n.members}',
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      StatusBadge(status: event.status),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Divider(
                    color: isLight
                        ? colorScheme.outlineVariant.withValues(alpha: 0.35)
                        : customColors.glassStroke,
                    height: 1,
                  ),
                  SizedBox(height: 14.h),

                  // Amounts Row with Application-Consistent Monospaced Typography
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL SPEND',
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.outline,
                              letterSpacing: 1.1,
                              fontSize: 10.5.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          CompactAmountText(
                            amount: event.totalSpent,
                            style: customTypography.headlineMediumMonoBold
                                .copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'YOUR SHARE',
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.outline,
                              letterSpacing: 1.1,
                              fontSize: 10.5.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          CompactAmountText(
                            amount: event.userShare,
                            style: customTypography.headlineMediumMonoBold
                                .copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Bottom Row: Avatars & Detail Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ParticipantAvatarRow(
                        participants: event.participants,
                        maxAvatars: 4,
                      ),
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh
                              .withValues(alpha: isLight ? 0.6 : 0.4),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isLight
                                ? colorScheme.outlineVariant
                                    .withValues(alpha: 0.3)
                                : customColors.glassStroke,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: colorScheme.primary,
                          size: 14.w,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
