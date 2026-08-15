import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/status_components.dart';
import '../../domain/entities/sharing_event.dart';
import '../../domain/repositories/groups_repository.dart';
import '../cubit/groups_cubit.dart';
import '../widgets/participant_avatar.dart';

class _ParticipantItem {
  final String name;
  final String? email;
  final bool isOwner;
  final int colorIndex;

  const _ParticipantItem({
    required this.name,
    this.email,
    this.isOwner = false,
    required this.colorIndex,
  });
}

@RoutePage()
class NewEventPage extends StatefulWidget {
  final SharingEvent? event;

  const NewEventPage({super.key, this.event});

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _participantNameController;
  late final TextEditingController _participantEmailController;

  late String _selectedCategory;
  late List<_ParticipantItem> _participants;
  bool _isLoading = false;

  static const List<String> _categories = [
    'trip',
    'dinner',
    'home',
    'party',
    'groceries',
    'utilities',
    'entertainment',
    'transport',
    'shopping',
    'sports',
    'work',
    'others',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _participantNameController = TextEditingController();
    _participantEmailController = TextEditingController();

    _selectedCategory = widget.event?.category ?? 'trip';

    if (widget.event != null) {
      _participants = widget.event!.participants
          .map((p) => _ParticipantItem(
                name: p.name,
                email: p.email,
                isOwner: p.isOwner,
                colorIndex: p.colorIndex,
              ))
          .toList();
    } else {
      _participants = [
        const _ParticipantItem(
          name: 'You',
          isOwner: true,
          colorIndex: 0,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _participantNameController.dispose();
    _participantEmailController.dispose();
    super.dispose();
  }

  String _getCategoryLabel(String cat) {
    switch (cat.toLowerCase()) {
      case 'trip':
        return context.l10n.trip;
      case 'dinner':
        return context.l10n.dinner;
      case 'home':
        return context.l10n.home;
      case 'party':
        return context.l10n.party;
      case 'groceries':
        return 'Groceries';
      case 'utilities':
        return 'Bills & Utilities';
      case 'entertainment':
        return 'Entertainment';
      case 'transport':
        return 'Transport';
      case 'shopping':
        return 'Shopping';
      case 'sports':
        return 'Sports & Fitness';
      case 'work':
        return 'Work & Projects';
      case 'others':
        return 'Others';
      default:
        return cat.isNotEmpty
            ? '${cat[0].toUpperCase()}${cat.substring(1)}'
            : cat;
    }
  }

  String _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
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

  void _showCategoryPickerBottomSheet() {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalContext).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border(
              top: BorderSide(color: customColors.glassStroke, width: 1.2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Category',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: colorScheme.onSurfaceVariant),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                ),
                Divider(color: customColors.glassStroke, height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => SizedBox(height: 4.h),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          Navigator.pop(modalContext);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                            border: isSelected
                                ? Border.all(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.4))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38.w,
                                height: 38.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  _getCategoryIcon(cat),
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Text(
                                  _getCategoryLabel(cat),
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.primary,
                                  size: 22.w,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addParticipant() {
    final name = _participantNameController.text.trim();
    if (name.isEmpty) {
      StatusComponents.showToast(
        context,
        message: 'Please enter a participant name',
        isError: true,
      );
      return;
    }

    if (_participants
        .any((p) => p.name.trim().toLowerCase() == name.toLowerCase())) {
      StatusComponents.showToast(
        context,
        message: 'A participant named "$name" already exists',
        isError: true,
      );
      return;
    }

    final email = _participantEmailController.text.trim();
    if (email.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      StatusComponents.showToast(
        context,
        message: 'Please enter a valid email address',
        isError: true,
      );
      return;
    }

    setState(() {
      _participants.add(_ParticipantItem(
        name: name,
        email: email.isNotEmpty ? email : null,
        isOwner: false,
        colorIndex: _participants.length % 6,
      ));
      _participantNameController.clear();
      _participantEmailController.clear();
    });
  }

  void _removeParticipant(int index) {
    if (_participants[index].isOwner) return;
    setState(() {
      _participants.removeAt(index);
    });
  }

  Future<void> _saveEvent() async {
    final isEdit = widget.event != null;
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      StatusComponents.showToast(
        context,
        message: 'Please enter an event name',
        isError: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_participantNameController.text.trim().isNotEmpty) {
      StatusComponents.showToast(
        context,
        message:
            'Please tap "+ Add Participant" to add "${_participantNameController.text.trim()}" or clear the field',
        isError: true,
      );
      return;
    }

    if (_participants.length < 2) {
      StatusComponents.showToast(
        context,
        message: 'Please add at least one other participant to split expenses',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = getIt<GroupsRepository>();

      if (isEdit) {
        await repo.updateEvent(
          id: widget.event!.id,
          name: name,
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
        );
      } else {
        final eventId = await repo.createEvent(
          name: name,
          description: _descriptionController.text.trim(),
          startDate: DateTime.now(),
          category: _selectedCategory,
        );

        for (final p in _participants) {
          await repo.addParticipant(
            eventId: eventId,
            name: p.name,
            email: p.email,
            isOwner: p.isOwner,
            colorIndex: p.colorIndex,
          );
        }
      }

      if (mounted) {
        getIt<GroupsCubit>().loadEvents();
        StatusComponents.showToast(
          context,
          message: isEdit
              ? context.l10n.eventUpdatedSuccess
              : context.l10n.eventCreatedSuccess,
        );
        context.router.popForced();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final rawMsg = e.toString().replaceAll('Exception: ', '').trim();
        final errorMessage = rawMsg.isNotEmpty
            ? rawMsg
            : (isEdit ? 'Failed to update event' : 'Failed to create event');
        StatusComponents.showToast(
          context,
          message: errorMessage,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + kToolbarHeight;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: LiquidGlassAppBar(
        onLeadingPressed: () => context.router.popForced(),
      ),
      bottomNavigationBar: _LiquidGlassBottomBar(
        child: AppButton(
          text:
              isEdit ? context.l10n.editEvent : '${context.l10n.createEvent} →',
          isLoading: _isLoading,
          onPressed: _saveEvent,
          variant: AppButtonVariant.primary,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: headerPaddingTop + 16.h,
            bottom: 100.h + MediaQuery.of(context).viewPadding.bottom,
          ),
          children: [
            // Hero Text
            Text(
              isEdit ? context.l10n.editEvent : context.l10n.createNewEvent,
              style: context.textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Organize and split shared expenses with friends or family.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),

            // Event Details Container
            _LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EVENT DETAILS',
                    style: context.customTypography.labelMediumMono,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    controller: _nameController,
                    labelText: context.l10n.eventName,
                    hintText: 'e.g. Trip to Bali',
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Event name is required'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    controller: _descriptionController,
                    labelText: 'Description (Optional)',
                    hintText: 'e.g. Summer vacation with friends',
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    context.l10n.category.toUpperCase(),
                    style: context.customTypography.labelMediumMono,
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: _showCategoryPickerBottomSheet,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: customColors.glassStroke,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getCategoryIcon(_selectedCategory),
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _getCategoryLabel(_selectedCategory),
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Participants Container
            _LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.participants.toUpperCase(),
                        style: context.customTypography.labelMediumMono,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          context.l10n.nAdded(_participants.length),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Add participant inputs (2 distinct rows)
                  if (!isEdit) ...[
                    AppTextField(
                      controller: _participantNameController,
                      labelText: "Friend's Name",
                      hintText: 'e.g. Sarah',
                    ),
                    SizedBox(height: 12.h),
                    AppTextField(
                      controller: _participantEmailController,
                      labelText: 'Email (Optional)',
                      hintText: 'e.g. sarah@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 12.h),
                    AppButton(
                      text: '+ Add Participant',
                      height: 44.h,
                      textStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: _addParticipant,
                      variant: AppButtonVariant.secondary,
                    ),
                    SizedBox(height: 12.h),
                    Divider(
                      color: customColors.glassStroke.withValues(alpha: 0.5),
                      height: 1.h,
                    ),
                    SizedBox(height: 10.h),
                  ],

                  // Participants list
                  ..._participants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final p = entry.value;
                    final isLast = index == _participants.length - 1;

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            children: [
                              ParticipantAvatar(
                                name: p.name,
                                colorIndex: p.colorIndex,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          p.name,
                                          style: context
                                              .customTypography.bodyLarge
                                              .copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        if (p.isOwner) ...[
                                          SizedBox(width: 6.w),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 1.h),
                                            decoration: BoxDecoration(
                                              color: colorScheme
                                                  .surfaceContainerHigh,
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              context.l10n.owner,
                                              style: context
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                fontSize: 10.sp,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (p.email != null)
                                      Text(
                                        p.email!,
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (!p.isOwner && !isEdit)
                                IconButton(
                                  icon: Icon(Icons.close,
                                      size: 18.w,
                                      color: colorScheme.onSurfaceVariant),
                                  onPressed: () => _removeParticipant(index),
                                ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            color:
                                customColors.glassStroke.withValues(alpha: 0.4),
                            height: 12.h,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _LiquidGlassCard extends StatelessWidget {
  final Widget child;

  const _LiquidGlassCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = BorderRadius.circular(20.r);

    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.85),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.20),
                ],
        ),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.8)
              : customColors.glassStroke.withValues(alpha: 0.55),
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
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.18),
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
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassBottomBar extends StatelessWidget {
  final Widget child;

  const _LiquidGlassBottomBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: 16.h + MediaQuery.of(context).viewPadding.bottom,
          ),
          decoration: BoxDecoration(
            color: isLight
                ? colorScheme.surface.withValues(alpha: 0.82)
                : colorScheme.surface.withValues(alpha: 0.70),
            border: Border(
              top: BorderSide(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.8)
                    : customColors.glassStroke.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
