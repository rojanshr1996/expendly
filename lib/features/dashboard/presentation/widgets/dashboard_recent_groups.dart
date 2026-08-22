import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/widgets/animated_entrance_item.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../groups/domain/entities/sharing_event.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../../groups/presentation/cubit/groups_state.dart';
import '../../../groups/presentation/widgets/participant_avatar_row.dart';
import '../../../groups/presentation/widgets/status_badge.dart';

class DashboardRecentGroups extends StatelessWidget {
  final VoidCallback onSeeAllPressed;

  const DashboardRecentGroups({
    super.key,
    required this.onSeeAllPressed,
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

  Widget _buildViewAllCard(BuildContext context, int totalCount, bool isLight) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return GestureDetector(
      onTap: onSeeAllPressed,
      child: SizedBox(
        width: 120.w,
        child: GlassContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          backgroundColor: isLight
              ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.5)
              : customColors.surfaceLow.withValues(alpha: 0.4),
          borderStrokeColor: isLight
              ? colorScheme.outlineVariant.withValues(alpha: 0.4)
              : customColors.glassStroke,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary
                      .withValues(alpha: isLight ? 0.12 : 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: colorScheme.primary,
                  size: 20.w,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'View All',
                style: context.customTypography.bodyLargeBold.copyWith(
                  color: colorScheme.primary,
                  fontSize: 13.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                '$totalCount Events',
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        final allEvents =
            state is GroupsLoaded ? state.events : const <SharingEvent>[];
        final events = allEvents
            .where((e) => e.status.toLowerCase() != 'settled')
            .toList();
        final displayEvents = events.take(2).toList();
        final totalItems = displayEvents.length + (events.isNotEmpty ? 1 : 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.diversity_3_outlined,
                        size: 16.sp,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'SPLIT BILLS & EXPENSES',
                          style:
                              context.customTypography.labelMediumMono.copyWith(
                            letterSpacing: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAllPressed,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                    child: Text(
                      'See All',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: events.isEmpty
                  ? AnimatedEntranceItem(
                      key: const ValueKey('groups_empty_banner'),
                      index: 0,
                      child: GlassContainer(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        backgroundColor: isLight
                            ? colorScheme.surfaceContainerLowest
                                .withValues(alpha: 0.6)
                            : customColors.surfaceLow.withValues(alpha: 0.45),
                        borderStrokeColor: isLight
                            ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                            : customColors.glassStroke,
                        child: Row(
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: isLight ? 0.12 : 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.call_split_rounded,
                                color: colorScheme.primary,
                                size: 22.w,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Split Bills & Expenses',
                                    style: context
                                        .customTypography.bodyLargeBold
                                        .copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Track shared expenses with friends',
                                    style:
                                        context.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            AppButton(
                              text: '+ Split Bill',
                              width: 104.w,
                              height: 38.h,
                              textStyle: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              onPressed: () =>
                                  context.router.push(NewEventRoute()),
                              variant: AppButtonVariant.primary,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      key: const ValueKey('groups_carousel'),
                      height: 156.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: totalItems,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          if (index < displayEvents.length) {
                            final event = displayEvents[index];

                            return AnimatedEntranceItem(
                              index: index,
                              initialOffset: const Offset(0.08, 0.0),
                              child: GestureDetector(
                                onTap: () => context.router.push(
                                  EventDetailRoute(eventId: event.id),
                                ),
                                child: SizedBox(
                                  width: 240.w,
                                  child: GlassContainer(
                                    padding: EdgeInsets.all(14.w),
                                    backgroundColor: isLight
                                        ? colorScheme.surfaceContainerLowest
                                            .withValues(alpha: 0.65)
                                        : customColors.surfaceLow
                                            .withValues(alpha: 0.50),
                                    borderStrokeColor: isLight
                                        ? colorScheme.outlineVariant
                                            .withValues(alpha: 0.45)
                                        : customColors.glassStroke,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Top Row: Category avatar, Name & Status
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 34.w,
                                                    height: 34.w,
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.primary
                                                          .withValues(
                                                              alpha: isLight
                                                                  ? 0.10
                                                                  : 0.16),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.r),
                                                      border: Border.all(
                                                        color: colorScheme
                                                            .primary
                                                            .withValues(
                                                                alpha: isLight
                                                                    ? 0.20
                                                                    : 0.28),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      _getCategoryIcon(
                                                          event.category),
                                                      style: TextStyle(
                                                          fontSize: 15.sp),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          event.name,
                                                          style: context
                                                              .customTypography
                                                              .bodyLargeBold
                                                              .copyWith(
                                                            color: colorScheme
                                                                .onSurface,
                                                            fontSize: 13.5.sp,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          event.category
                                                              .toUpperCase(),
                                                          style: context
                                                              .customTypography
                                                              .labelMediumMono
                                                              .copyWith(
                                                            color: colorScheme
                                                                .primary,
                                                            fontSize: 9.sp,
                                                            letterSpacing: 0.7,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            StatusBadge(status: event.status),
                                          ],
                                        ),

                                        // Middle Row: Monospaced Amounts
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'TOTAL SPEND',
                                                  style: context
                                                      .customTypography
                                                      .labelMediumMono
                                                      .copyWith(
                                                    color: colorScheme.outline,
                                                    letterSpacing: 1.0,
                                                    fontSize: 9.5.sp,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                CompactAmountText(
                                                  amount: event.totalSpent,
                                                  style: context
                                                      .customTypography
                                                      .headlineMediumMonoBold
                                                      .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'YOUR SHARE',
                                                  style: context
                                                      .customTypography
                                                      .labelMediumMono
                                                      .copyWith(
                                                    color: colorScheme.outline,
                                                    letterSpacing: 1.0,
                                                    fontSize: 9.5.sp,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                CompactAmountText(
                                                  amount: event.userShare,
                                                  style: context
                                                      .customTypography
                                                      .headlineMediumMonoBold
                                                      .copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Bottom Row: Avatars & Members
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ParticipantAvatarRow(
                                              participants: event.participants,
                                              maxAvatars: 3,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${event.participants.length} ${context.l10n.members}',
                                                  style: context
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 10.sp,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 10.sp,
                                                  color: colorScheme.outline,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return AnimatedEntranceItem(
                              index: index,
                              initialOffset: const Offset(0.08, 0.0),
                              child: _buildViewAllCard(
                                  context, events.length, isLight),
                            );
                          }
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
