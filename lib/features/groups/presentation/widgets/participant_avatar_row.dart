import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/event_participant.dart';
import 'participant_avatar.dart';

class ParticipantAvatarRow extends StatelessWidget {
  final List<EventParticipant> participants;
  final int maxAvatars;

  const ParticipantAvatarRow({
    super.key,
    required this.participants,
    this.maxAvatars = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final displayCount =
        participants.length > maxAvatars ? maxAvatars : participants.length;
    final overflowCount = participants.length - maxAvatars;
    final totalCount = displayCount + (overflowCount > 0 ? 1 : 0);
    final rowWidth = totalCount > 0 ? ((totalCount - 1) * 24.w + 36.w) : 0.0;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return SizedBox(
      height: 36.w,
      width: rowWidth,
      child: Stack(
        children: List.generate(
          totalCount,
          (index) {
            if (index == displayCount) {
              return Positioned(
                left: index * 24.w,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isLight
                          ? [
                              colorScheme.surfaceContainerLowest
                                  .withValues(alpha: 0.85),
                              colorScheme.surfaceContainerHigh
                                  .withValues(alpha: 0.60),
                            ]
                          : [
                              colorScheme.surfaceContainerHigh
                                  .withValues(alpha: 0.65),
                              colorScheme.surfaceContainerLow
                                  .withValues(alpha: 0.45),
                            ],
                    ),
                    border: Border.all(
                      color: isLight
                          ? Colors.white.withValues(alpha: 0.80)
                          : customColors.glassStroke.withValues(alpha: 0.60),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.white.withValues(alpha: isLight ? 0.5 : 0.0),
                        blurRadius: 4.r,
                        offset: const Offset(0, -1),
                      ),
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isLight ? 0.06 : 0.18),
                        blurRadius: 6.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+$overflowCount',
                    style: context.customTypography.labelMediumMono.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              );
            }
            final p = participants[index];
            return Positioned(
              left: index * 24.w,
              child: ParticipantAvatar(
                name: p.name,
                colorIndex: p.colorIndex,
              ),
            );
          },
        ),
      ),
    );
  }
}
