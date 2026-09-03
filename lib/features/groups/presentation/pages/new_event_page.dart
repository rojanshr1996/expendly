import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/ads/ad_helper.dart';
import '../../../../core/ads/widgets/banner_ad_widget.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/animated_entrance_item.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/status_components.dart';
import '../../domain/entities/sharing_event.dart';
import '../../domain/repositories/groups_repository.dart';
import '../cubit/groups_cubit.dart';
import '../widgets/participant_avatar.dart';

class _EventCategoryMeta {
  final String key;
  final String Function(BuildContext) getLabel;
  final IconData icon;
  final Color color;

  const _EventCategoryMeta({
    required this.key,
    required this.getLabel,
    required this.icon,
    required this.color,
  });
}

class _ParticipantItem {
  final int? id;
  final String name;
  final String? email;
  final bool isOwner;
  final int colorIndex;

  const _ParticipantItem({
    this.id,
    required this.name,
    this.email,
    this.isOwner = false,
    required this.colorIndex,
  });

  _ParticipantItem copyWith({
    int? id,
    String? name,
    String? email,
    bool? isOwner,
    int? colorIndex,
  }) {
    return _ParticipantItem(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email != null ? (email.isEmpty ? null : email) : this.email,
      isOwner: isOwner ?? this.isOwner,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
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
  final Set<int> _removedParticipantIds = {};
  bool _isLoading = false;

  static final List<_EventCategoryMeta> _eventCategories = [
    _EventCategoryMeta(
      key: 'trip',
      getLabel: (ctx) => ctx.l10n.trip,
      icon: Icons.flight_takeoff_rounded,
      color: const Color(0xFF38BDF8),
    ),
    _EventCategoryMeta(
      key: 'dinner',
      getLabel: (ctx) => ctx.l10n.dinner,
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFFB923C),
    ),
    _EventCategoryMeta(
      key: 'home',
      getLabel: (ctx) => ctx.l10n.home,
      icon: Icons.home_rounded,
      color: const Color(0xFF34D399),
    ),
    _EventCategoryMeta(
      key: 'party',
      getLabel: (ctx) => ctx.l10n.party,
      icon: Icons.celebration_rounded,
      color: const Color(0xFFF472B6),
    ),
    _EventCategoryMeta(
      key: 'groceries',
      getLabel: (_) => 'Groceries',
      icon: Icons.shopping_cart_rounded,
      color: const Color(0xFFA3E635),
    ),
    _EventCategoryMeta(
      key: 'utilities',
      getLabel: (_) => 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFFFBBF24),
    ),
    _EventCategoryMeta(
      key: 'entertainment',
      getLabel: (_) => 'Entertainment',
      icon: Icons.movie_rounded,
      color: const Color(0xFFA78BFA),
    ),
    _EventCategoryMeta(
      key: 'transport',
      getLabel: (_) => 'Transport',
      icon: Icons.directions_car_rounded,
      color: const Color(0xFF22D3EE),
    ),
    _EventCategoryMeta(
      key: 'shopping',
      getLabel: (_) => 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFFFB7185),
    ),
    _EventCategoryMeta(
      key: 'sports',
      getLabel: (_) => 'Sports & Fitness',
      icon: Icons.sports_soccer_rounded,
      color: const Color(0xFF2DD4BF),
    ),
    _EventCategoryMeta(
      key: 'work',
      getLabel: (_) => 'Work & Projects',
      icon: Icons.business_center_rounded,
      color: const Color(0xFF818CF8),
    ),
    _EventCategoryMeta(
      key: 'others',
      getLabel: (_) => 'Others',
      icon: Icons.category_rounded,
      color: const Color(0xFF94A3B8),
    ),
  ];

  static _EventCategoryMeta _getCategoryMeta(BuildContext context, String cat) {
    final clean = cat.toLowerCase().trim();
    for (final meta in _eventCategories) {
      if (meta.key == clean) return meta;
    }
    return _EventCategoryMeta(
      key: cat,
      getLabel: (_) =>
          cat.isNotEmpty ? '${cat[0].toUpperCase()}${cat.substring(1)}' : cat,
      icon: CategoryIconHelper.getIcon(cat, cat),
      color: const Color(0xFF94A3B8),
    );
  }

  static Color _adjustColorForTheme(BuildContext context, Color color) {
    if (Theme.of(context).brightness == Brightness.light) {
      final hsl = HSLColor.fromColor(color);
      if (hsl.lightness > 0.5) {
        return hsl
            .withLightness((hsl.lightness - 0.25).clamp(0.2, 0.45))
            .toColor();
      }
    }
    return color;
  }

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
                id: p.id,
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

  void _showCategoryPickerBottomSheet() {
    AdaptiveSheet.show<void>(
      context: context,
      isScrollControlled: true,
      maxDialogWidth: 600.0,
      builder: (modalContext) {
        return _EventCategoryPickerSheet(
          selectedCategory: _selectedCategory,
          onCategorySelected: (cat) {
            setState(() => _selectedCategory = cat);
          },
        );
      },
    );
  }

  Future<void> _showEditParticipantBottomSheet(int index) async {
    final participant = _participants[index];

    await AdaptiveSheet.show<void>(
      context: context,
      isScrollControlled: true,
      maxDialogWidth: 480.0,
      builder: (modalContext) {
        return _EditParticipantModalContent(
          participant: participant,
          index: index,
          participants: _participants,
          onSave: (newName, newEmail) {
            setState(() {
              _participants[index] = participant.copyWith(
                name: newName,
                email: newEmail.isNotEmpty ? newEmail : '',
              );
            });
            Navigator.pop(modalContext);
            StatusComponents.showToast(
              context,
              message: 'Updated $newName',
            );
          },
          onClearEmail: () {
            setState(() {
              _participants[index] = participant.copyWith(email: '');
            });
            Navigator.pop(modalContext);
            StatusComponents.showToast(
              context,
              message: 'Email removed for ${participant.name}',
            );
          },
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

  Future<void> _removeParticipant(int index) async {
    final participant = _participants[index];
    if (participant.isOwner) {
      StatusComponents.showToast(
        context,
        message: 'Cannot remove event creator',
        isError: true,
      );
      return;
    }

    if (widget.event != null && participant.id != null) {
      final repo = getIt<GroupsRepository>();
      final expenses = await repo.getExpensesByEventId(widget.event!.id);
      final hasExpenses = expenses.any((e) =>
          e.paidByParticipantId == participant.id ||
          e.splits.any((s) => s.participantId == participant.id));

      if (hasExpenses) {
        if (mounted) {
          StatusComponents.showToast(
            context,
            message:
                'Cannot remove "${participant.name}" because they have recorded expenses in this event',
            isError: true,
          );
        }
        return;
      }

      if (mounted) {
        final confirmed = await StatusComponents.showConfirmationBottomSheet(
          context,
          title: 'Remove ${participant.name}?',
          message:
              'Are you sure you want to remove ${participant.name} from this event?',
          confirmLabel: 'Remove',
          isDestructive: true,
        );
        if (confirmed != true) return;
      }

      _removedParticipantIds.add(participant.id!);
    }

    if (mounted) {
      setState(() {
        _participants.removeAt(index);
      });
      StatusComponents.showToast(
        context,
        message: '${participant.name} removed',
      );
    }
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

        for (final removedId in _removedParticipantIds) {
          await repo.removeParticipant(removedId);
        }

        for (final p in _participants) {
          if (p.id != null) {
            await repo.updateParticipant(
              participantId: p.id!,
              name: p.name,
              email: p.email,
            );
          } else {
            await repo.addParticipant(
              eventId: widget.event!.id,
              name: p.name,
              email: p.email,
              isOwner: p.isOwner,
              colorIndex: p.colorIndex,
            );
          }
        }
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
        try {
          context.router.maybePop();
        } catch (_) {
          Navigator.of(context).maybePop();
        }
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet = Breakpoints.isTablet(context);
    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + kToolbarHeight;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: LiquidGlassAppBar(
        onLeadingPressed: () => context.router.popForced(),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 720.0 : double.infinity,
          ),
          child: _LiquidGlassBottomBar(
            child: AppButton(
              text: isEdit
                  ? context.l10n.editEvent
                  : '${context.l10n.createEvent} →',
              isLoading: _isLoading,
              onPressed: _saveEvent,
              variant: AppButtonVariant.primary,
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 720.0 : double.infinity,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.only(
                left: isTablet ? 24.0 : 20.w,
                right: isTablet ? 24.0 : 20.w,
                top: headerPaddingTop + (isTablet ? 20.0 : 16.h),
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
                      Builder(
                        builder: (context) {
                          final meta =
                              _getCategoryMeta(context, _selectedCategory);
                          final catColor =
                              _adjustColorForTheme(context, meta.color);
                          final catLabel = meta.getLabel(context);

                          return InkWell(
                            onTap: _showCategoryPickerBottomSheet,
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? colorScheme.surfaceContainerLowest
                                    : colorScheme.surfaceContainerHigh
                                        .withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isLight
                                      ? colorScheme.outlineVariant
                                          .withValues(alpha: 0.50)
                                      : customColors.glassStroke
                                          .withValues(alpha: 0.45),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38.w,
                                          height: 38.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: catColor.withValues(
                                                alpha: isLight ? 0.14 : 0.20),
                                            border: Border.all(
                                              color: catColor.withValues(
                                                  alpha: isLight ? 0.30 : 0.40),
                                              width: 1.0,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            meta.icon,
                                            color: catColor,
                                            size: 20.sp,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                context.l10n.categoryLabel,
                                                style: context
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(
                                                catLabel,
                                                style: context
                                                    .customTypography.bodyLarge
                                                    .copyWith(
                                                  color: colorScheme.onSurface,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                              color:
                                  colorScheme.primary.withValues(alpha: 0.15),
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
                        backgroundColor: isLight
                            ? const Color(0xFF15803D)
                            : const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0.0,
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: _addParticipant,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EVENT PARTICIPANTS',
                            style: context.customTypography.labelMediumMono
                                .copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '${_participants.length} member${_participants.length == 1 ? '' : 's'}',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Participants list
                      ..._participants.asMap().entries.map((entry) {
                        final index = entry.key;
                        final p = entry.value;
                        final hasEmail = p.email != null && p.email!.isNotEmpty;

                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isLight
                                ? colorScheme.surfaceContainerLowest
                                    .withValues(alpha: 0.70)
                                : colorScheme.surfaceContainerHigh
                                    .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isLight
                                  ? colorScheme.outlineVariant
                                      .withValues(alpha: 0.40)
                                  : customColors.glassStroke
                                      .withValues(alpha: 0.45),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              ParticipantAvatar(
                                name: p.name,
                                colorIndex: p.colorIndex,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      _showEditParticipantBottomSheet(index),
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              p.name,
                                              style: context
                                                  .customTypography.bodyLarge
                                                  .copyWith(
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (p.isOwner) ...[
                                            SizedBox(width: 6.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6.w,
                                                  vertical: 1.5.h),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                                border: Border.all(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.25),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                context.l10n.owner,
                                                style: context
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 3.h),
                                      if (hasEmail)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.mail_outline_rounded,
                                              size: 12.sp,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            SizedBox(width: 4.w),
                                            Flexible(
                                              child: Text(
                                                p.email!,
                                                style: context
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: 11.sp,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 12.sp,
                                              color: colorScheme.primary,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Add email',
                                              style: context
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              if (!p.isOwner)
                                IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 18.w,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  tooltip: context.l10n.removeParticipant,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: 32.w,
                                    minHeight: 32.h,
                                  ),
                                  onPressed: () => _removeParticipant(index),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Banner Ad (Initial build entrance animation)
                AnimatedEntranceItem(
                  index: 2,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: BannerAdWidget(adUnitId: AdHelper.bannerAdUnitId),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
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

class _EditParticipantModalContent extends StatefulWidget {
  final _ParticipantItem participant;
  final int index;
  final List<_ParticipantItem> participants;
  final void Function(String newName, String newEmail) onSave;
  final VoidCallback onClearEmail;

  const _EditParticipantModalContent({
    required this.participant,
    required this.index,
    required this.participants,
    required this.onSave,
    required this.onClearEmail,
  });

  @override
  State<_EditParticipantModalContent> createState() =>
      _EditParticipantModalContentState();
}

class _EditParticipantModalContentState
    extends State<_EditParticipantModalContent> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.participant.name);
    _emailCtrl = TextEditingController(text: widget.participant.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet = Breakpoints.isTablet(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color:
              isLight ? colorScheme.surface : colorScheme.surfaceContainerHigh,
          borderRadius: isTablet
              ? BorderRadius.circular(24.0)
              : BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(
            color: isLight
                ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                : customColors.glassStroke.withValues(alpha: 0.45),
            width: 1.0,
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 24.0 : 20.w,
                isTablet ? 20.0 : 12.h,
                isTablet ? 24.0 : 20.w,
                isTablet ? 20.0 : 20.h,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle (phone only)
                    if (!isTablet) ...[
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isLight
                                ? colorScheme.outline.withValues(alpha: 0.4)
                                : colorScheme.outlineVariant
                                    .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                participant.isOwner
                                    ? (participant.email != null &&
                                            participant.email!.isNotEmpty
                                        ? 'Edit Email Address'
                                        : 'Add Email Address')
                                    : 'Edit Participant',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                participant.isOwner
                                    ? 'For ${participant.name} (Owner)'
                                    : 'Update details for ${participant.name}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Adding an email allows you to send settlement reminders directly from the balances tab.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!participant.isOwner) ...[
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _nameCtrl,
                        labelText: "Participant's Name",
                        hintText: 'e.g. Sarah',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (val) {
                          final trimmed = val?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Please enter a participant name';
                          }
                          final isDuplicate =
                              widget.participants.asMap().entries.any(
                                    (e) =>
                                        e.key != widget.index &&
                                        e.value.name.trim().toLowerCase() ==
                                            trimmed.toLowerCase(),
                                  );
                          if (isDuplicate) {
                            return 'A participant named "$trimmed" already exists';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _emailCtrl,
                      labelText: 'Email Address',
                      hintText:
                          'e.g. ${participant.name.toLowerCase().replaceAll(' ', '')}@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      validator: (val) {
                        final trimmed = val?.trim() ?? '';
                        if (trimmed.isNotEmpty &&
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(trimmed)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        if (participant.email != null &&
                            participant.email!.isNotEmpty) ...[
                          Expanded(
                            flex: 1,
                            child: AppButton(
                              text: 'Clear Email',
                              height: 44.h,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              textStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              onPressed: widget.onClearEmail,
                              variant: AppButtonVariant.outlined,
                            ),
                          ),
                          SizedBox(width: 12.w),
                        ],
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'Save Changes',
                            height: 44.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              final newName = participant.isOwner
                                  ? participant.name
                                  : _nameCtrl.text.trim();
                              final newEmail = _emailCtrl.text.trim();
                              widget.onSave(newName, newEmail);
                            },
                            variant: AppButtonVariant.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCategoryPickerSheet extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _EventCategoryPickerSheet({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<_EventCategoryPickerSheet> createState() =>
      _EventCategoryPickerSheetState();
}

class _EventCategoryPickerSheetState extends State<_EventCategoryPickerSheet> {
  late final TextEditingController _searchController;
  late final ValueNotifier<String> _searchQueryNotifier;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchQueryNotifier = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final customColors = context.customColors;
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet = Breakpoints.isTablet(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        height: isTablet ? 560.0 : MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color:
              isLight ? colorScheme.surface : colorScheme.surfaceContainerHigh,
          borderRadius: isTablet
              ? BorderRadius.circular(24.0)
              : BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(
            color: isLight
                ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                : customColors.glassStroke.withValues(alpha: 0.45),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 20.w,
          vertical: isTablet ? 20.0 : 16.h,
        ),
        child: Column(
          children: [
            // Sheet Handle & Drag Bar (mobile only)
            if (!isTablet) ...[
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isLight
                        ? colorScheme.outline.withValues(alpha: 0.4)
                        : colorScheme.outlineVariant.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.categoryLabel,
                  style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                    fontWeight: FontWeights.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Search Bar Component
            ValueListenableBuilder<String>(
              valueListenable: _searchQueryNotifier,
              builder: (context, query, _) {
                final br = BorderRadius.circular(16.r);
                return Container(
                  decoration: BoxDecoration(
                    color: isLight
                        ? colorScheme.surfaceContainerLow
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: br,
                    border: Border.all(
                      color: isLight
                          ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                          : customColors.glassStroke.withValues(alpha: 0.45),
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _searchQueryNotifier.value = val,
                    style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.searchCategoryHint,
                      hintStyle:
                          (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: 18.sp,
                                color: colorScheme.outline,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchQueryNotifier.value = '';
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),

            // Category Grid
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQueryNotifier,
                builder: (context, query, _) {
                  final cleanQuery = query.trim().toLowerCase();
                  final categories = _NewEventPageState._eventCategories;
                  final filtered = categories.where((cat) {
                    if (cleanQuery.isEmpty) return true;
                    final label = cat.getLabel(context).toLowerCase();
                    return label.contains(cleanQuery) ||
                        cat.key.toLowerCase().contains(cleanQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 48.sp, color: colorScheme.outline),
                          SizedBox(height: 12.h),
                          Text(
                            l10n.noCategoriesFound,
                            style: customTypography.bodyMedium
                                .copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 4 : 3,
                      crossAxisSpacing: isTablet ? 12.0 : 10.w,
                      mainAxisSpacing: isTablet ? 12.0 : 10.h,
                      childAspectRatio: isTablet ? 1.15 : 1.05,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected =
                          widget.selectedCategory.toLowerCase() ==
                              item.key.toLowerCase();
                      final color = _NewEventPageState._adjustColorForTheme(
                          context, item.color);
                      final label = item.getLabel(context);

                      return _buildGridItem(
                        context: context,
                        isSelected: isSelected,
                        icon: item.icon,
                        iconColor: color,
                        label: label,
                        onTap: () {
                          widget.onCategorySelected(item.key);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required BuildContext context,
    required bool isSelected,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isDark = !isLight;
    final isTablet = Breakpoints.isTablet(context);
    final br = BorderRadius.circular(isTablet ? 16.0 : 16.r);
    final selectedBg = colorScheme.primary;
    final selectedFg = isLight ? Colors.white : colorScheme.onPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: br,
          color: isSelected
              ? selectedBg
              : (isLight
                  ? colorScheme.surfaceContainerLowest
                  : colorScheme.surfaceContainerLow),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : (isLight
                    ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                    : customColors.glassStroke.withValues(alpha: 0.45)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary
                        .withValues(alpha: isDark ? 0.35 : 0.25),
                    blurRadius: isTablet ? 8.0 : 8.r,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (isLight
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 6.0 : 6.w,
            vertical: isTablet ? 6.0 : 8.h,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isTablet ? 44.0 : 44.w,
                    height: isTablet ? 44.0 : 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.22)
                          : iconColor.withValues(alpha: isLight ? 0.14 : 0.20),
                      border: isSelected
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.40),
                              width: 1.0,
                            )
                          : Border.all(
                              color: iconColor.withValues(
                                  alpha: isLight ? 0.30 : 0.40),
                              width: 1.0,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      color: isSelected ? selectedFg : iconColor,
                      size: isTablet ? 22.0 : 22.sp,
                    ),
                  ),
                  SizedBox(height: isTablet ? 4.0 : 6.h),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (textTheme.bodySmall ?? const TextStyle()).copyWith(
                        fontSize: isTablet ? 11.0 : 11.sp,
                        height: 1.2,
                        fontWeight:
                            isSelected ? FontWeights.bold : FontWeights.medium,
                        color: isSelected ? selectedFg : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 2.0 : 2.r),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : colorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: isTablet ? 11.0 : 11.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
