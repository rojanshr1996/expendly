import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_entrance_item.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../cubit/groups_cubit.dart';
import '../cubit/groups_state.dart';
import '../widgets/event_card.dart';
import '../widgets/groups_shimmer.dart';

@RoutePage()
class GroupsListPage extends StatefulWidget {
  const GroupsListPage({super.key});

  @override
  State<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  @override
  void initState() {
    super.initState();
    getIt<GroupsCubit>().loadEvents(isSilent: true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + kToolbarHeight;

    return BlocProvider<GroupsCubit>.value(
      value: getIt<GroupsCubit>(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        extendBodyBehindAppBar: true,
        appBar: const LiquidGlassAppBar(
          titleText: 'Split Bills & Expenses',
        ),
        floatingActionButton: BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, state) {
            if (state is GroupsLoaded && state.events.isNotEmpty) {
              return FloatingActionButton.extended(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 3,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  context.l10n.newEvent,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => context.router.push(NewEventRoute()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        body: BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _buildBody(context, state, headerPaddingTop),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    GroupsState state,
    double headerPaddingTop,
  ) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    if (state is GroupsLoading || state is GroupsInitial) {
      return Padding(
        padding: EdgeInsets.only(top: headerPaddingTop),
        child: const GroupsShimmer(key: ValueKey('groups_shimmer')),
      );
    }

    if (state is GroupsError) {
      return Padding(
        padding: EdgeInsets.only(top: headerPaddingTop),
        child: Center(
          key: const ValueKey('groups_error'),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    color: AppColors.semanticRed, size: 48.w),
                SizedBox(height: 16.h),
                Text(
                  context.l10n.operationFailed,
                  style: context.customTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                AppButton(
                  text: 'Retry',
                  width: 120.w,
                  onPressed: () => getIt<GroupsCubit>().loadEvents(),
                  variant: AppButtonVariant.outlined,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is GroupsLoaded) {
      if (state.events.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: headerPaddingTop),
          child: Center(
            key: const ValueKey('groups_empty'),
            child: AnimatedEntranceItem(
              index: 0,
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: customColors.glassStroke),
                      ),
                      child: Icon(
                        Icons.diversity_3_outlined,
                        color: colorScheme.primary,
                        size: 36.w,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      context.l10n.noEventsYet,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      context.l10n.createFirstEvent,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    AppButton(
                      text: context.l10n.createNewEvent,
                      width: 200.w,
                      onPressed: () => context.router.push(NewEventRoute()),
                      variant: AppButtonVariant.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        key: const ValueKey('groups_list'),
        color: colorScheme.primary,
        edgeOffset: headerPaddingTop,
        displacement: 30.h,
        onRefresh: () => getIt<GroupsCubit>().loadEvents(),
        child: ListView.separated(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: headerPaddingTop + 12.h,
            bottom: 96.h,
          ),
          itemCount: state.events.length,
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final event = state.events[index];
            return AnimatedEntranceItem(
              index: index,
              child: EventCard(
                event: event,
                onTap: () =>
                    context.router.push(EventDetailRoute(eventId: event.id)),
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink(key: ValueKey('groups_none'));
  }
}
