import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/widgets/user_avatar.dart';
import '../../../settings/presentation/pages/settings_page.dart';

/// Top App Bar matching the Modern Fiscal Core glass header specs.
/// Includes user profile avatar ring, app title, privacy mode toggle (hides balance with •••••), and reports.
class DashboardHeader extends StatelessWidget {
  final ValueNotifier<bool> isPrivacyModeNotifier;
  final VoidCallback? onReportsPressed;

  const DashboardHeader({
    super.key,
    required this.isPrivacyModeNotifier,
    this.onReportsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.20),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.25),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.15),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: isLight
                ? Colors.white.withValues(alpha: 0.50)
                : context.customColors.glassStroke.withValues(alpha: 0.40),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.15),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<ProfileCubit, ProfileState>(
                    bloc: getIt<ProfileCubit>(),
                    builder: (context, state) {
                      final profile =
                          state is ProfileLoaded ? state.profile : null;

                      return Row(
                        children: [
                          // User Avatar with glowing primary ring (taps to open SettingsPage)
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const SettingsPage(),
                                ),
                              );
                            },
                            child: UserAvatar(
                              imagePath: profile?.imagePath,
                              radius: 19.w,
                              borderWidth: 1.5,
                              iconSize: 22.sp,
                            ),
                          ),
                          horizontalMarginSmall,

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                profile != null && profile.name.isNotEmpty
                                    ? profile.name
                                    : context.l10n.appName,
                                style:
                                    (textTheme.titleMedium ?? const TextStyle())
                                        .copyWith(
                                  fontWeight: FontWeights.bold,
                                  color: colorScheme.onSurface,
                                  fontSize: 16.sp,
                                ),
                              ),
                              if (profile != null && profile.name.isNotEmpty)
                                Text(
                                  context.l10n.appName,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    children: [
                      // Privacy Mode Obfuscation Toggle Button
                      ValueListenableBuilder<bool>(
                        valueListenable: isPrivacyModeNotifier,
                        builder: (context, isPrivacyMode, _) {
                          return IconButton(
                            tooltip: isPrivacyMode
                                ? context.l10n.showBalances
                                : context.l10n.hideBalances,
                            icon: Icon(
                              isPrivacyMode
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: isPrivacyMode
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              size: 22.sp,
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              isPrivacyModeNotifier.value = !isPrivacyMode;
                            },
                          );
                        },
                      ),

                      // Reports Button
                      IconButton(
                        tooltip: context.l10n.reports,
                        icon: Icon(
                          Icons.bar_chart_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 22.sp,
                        ),
                        onPressed: onReportsPressed,
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
