import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/ads/ad_helper.dart';
import '../../../../core/ads/widgets/banner_ad_widget.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/widgets/animated_entrance_item.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../domain/entities/sharing_event.dart';
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

class _GroupsListPageState extends State<GroupsListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getIt<GroupsCubit>().loadEvents(isSilent: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                Icon(
                  Icons.error_outline,
                  color: customColors.semanticRed,
                  size: 48.w,
                ),
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
      final activeEvents = state.events
          .where((e) => e.status.toLowerCase() != 'settled')
          .toList();
      final settledEvents = state.events
          .where((e) => e.status.toLowerCase() == 'settled')
          .toList();

      return Stack(
        key: const ValueKey('groups_tabbed_content'),
        fit: StackFit.expand,
        children: [
          // 1. Scrollable TabBarView (scrolls UNDER the floating tab bar)
          Positioned.fill(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsList(
                  context,
                  events: activeEvents,
                  isActive: true,
                  headerPaddingTop: headerPaddingTop,
                ),
                _buildEventsList(
                  context,
                  events: settledEvents,
                  isActive: false,
                  headerPaddingTop: headerPaddingTop,
                ),
              ],
            ),
          ),

          // 2. Pinned Floating Liquid Glass Tab Bar
          Positioned(
            top: headerPaddingTop + 4.h,
            left: 0,
            right: 0,
            child: _buildLiquidGlassTabBar(
              context,
              activeCount: activeEvents.length,
              settledCount: settledEvents.length,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink(key: ValueKey('groups_none'));
  }

  Widget _buildLiquidGlassTabBar(
    BuildContext context, {
    required int activeCount,
    required int settledCount,
  }) {
    final colorScheme = context.colorScheme;

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final tabs = [
          {
            'index': 0,
            'label': activeCount > 0
                ? '${context.l10n.active} ($activeCount)'
                : context.l10n.active,
          },
          {
            'index': 1,
            'label': settledCount > 0
                ? '${context.l10n.settled} ($settledCount)'
                : context.l10n.settled,
          },
        ];

        return _GroupsLiquidGlassCard(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          borderRadius: BorderRadius.circular(14.r),
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: tabs.map((t) {
              final tabIndex = t['index'] as int;
              final tabLabel = t['label'] as String;
              final isSelected = _tabController.index == tabIndex;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(tabIndex);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        tabLabel,
                        textAlign: TextAlign.center,
                        style:
                            context.customTypography.labelMediumMono.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEventsList(
    BuildContext context, {
    required List<SharingEvent> events,
    required bool isActive,
    required double headerPaddingTop,
  }) {
    final colorScheme = context.colorScheme;

    if (events.isEmpty) {
      return RefreshIndicator(
        color: colorScheme.primary,
        edgeOffset: headerPaddingTop + 54.h,
        displacement: 20.h,
        onRefresh: () => getIt<GroupsCubit>().loadEvents(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20.w,
            headerPaddingTop + 68.h,
            20.w,
            96.h,
          ),
          children: [
            AnimatedEntranceItem(
              index: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: BannerAdWidget(adUnitId: AdHelper.bannerAdUnitId),
              ),
            ),
            AnimatedEntranceItem(
              index: 1,
              child: GlassContainer(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 32.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isActive
                            ? Icons.diversity_3_outlined
                            : Icons.check_circle_outline_rounded,
                        color: colorScheme.primary,
                        size: 28.w,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      isActive ? context.l10n.noEventsYet : 'No Settled Events',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isActive
                          ? 'Create your first event to start splitting bills and expenses.'
                          : 'Events marked as settled will appear here for archive and records.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isActive) ...[
                      SizedBox(height: 20.h),
                      AppButton(
                        text: context.l10n.createNewEvent,
                        width: 180.w,
                        onPressed: () => context.router.push(NewEventRoute()),
                        variant: AppButtonVariant.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: ValueKey('groups_list_${isActive ? "active" : "settled"}'),
      color: colorScheme.primary,
      edgeOffset: headerPaddingTop + 54.h,
      displacement: 20.h,
      onRefresh: () => getIt<GroupsCubit>().loadEvents(),
      child: ListView.separated(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: headerPaddingTop + 60.h,
          bottom: 96.h,
        ),
        itemCount: events.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          if (index == 0) {
            return AnimatedEntranceItem(
              index: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: BannerAdWidget(adUnitId: AdHelper.bannerAdUnitId),
              ),
            );
          }
          final event = events[index - 1];
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
}

class _GroupsLiquidGlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _GroupsLiquidGlassCard({
    required this.child,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = borderRadius ?? BorderRadius.circular(16.r);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.3 : 0.0),
            blurRadius: 6.r,
            spreadRadius: -1.r,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.12),
            blurRadius: 12.r,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding ?? EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: br,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLight
                    ? [
                        colorScheme.surfaceContainerLowest
                            .withValues(alpha: 0.35),
                        colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.18),
                      ]
                    : [
                        colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.22),
                        colorScheme.surfaceContainerLow.withValues(alpha: 0.12),
                      ],
              ),
              border: Border.all(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.45)
                    : customColors.glassStroke.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
