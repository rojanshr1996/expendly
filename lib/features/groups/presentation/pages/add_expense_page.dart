import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/status_components.dart';
import '../../domain/entities/event_participant.dart';
import '../../domain/entities/expense_split.dart';
import '../../domain/repositories/groups_repository.dart';
import '../../domain/usecases/calculate_splits.dart';
import '../cubit/add_expense_cubit.dart';
import '../cubit/add_expense_state.dart';
import '../widgets/participant_avatar.dart';
import '../widgets/split_participant_tile.dart';

@RoutePage()
class AddExpensePage extends StatefulWidget {
  final int eventId;
  final List<EventParticipant> participants;

  const AddExpensePage({
    super.key,
    required this.eventId,
    required this.participants,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _showPaidByPickerBottomSheet(
    BuildContext context,
    AddExpenseCubit cubit,
    AddExpenseState state,
  ) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet = Breakpoints.isTablet(context);

    AdaptiveSheet.show<void>(
      context: context,
      isScrollControlled: true,
      maxDialogWidth: 480.0,
      builder: (modalContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: isTablet
                ? 560.0
                : MediaQuery.of(modalContext).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: isLight
                ? colorScheme.surface
                : colorScheme.surfaceContainerHigh,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle (phone only)
                if (!isTablet)
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
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
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Who Paid',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: colorScheme.onSurfaceVariant),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: isLight
                      ? colorScheme.outlineVariant.withValues(alpha: 0.5)
                      : customColors.glassStroke,
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: widget.participants.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (ctx, index) {
                      final p = widget.participants[index];
                      final isSelected = state.paidByParticipantId == p.id;

                      return InkWell(
                        onTap: () {
                          cubit.setPaidBy(p.id);
                          Navigator.pop(modalContext);
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isLight
                                    ? colorScheme.primary
                                        .withValues(alpha: 0.15)
                                    : colorScheme.primary
                                        .withValues(alpha: 0.20))
                                : (isLight
                                    ? colorScheme.surfaceContainerLowest
                                    : colorScheme.surfaceContainerLow
                                        .withValues(alpha: 0.50)),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : isLight
                                      ? colorScheme.outlineVariant
                                          .withValues(alpha: 0.50)
                                      : customColors.glassStroke,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ParticipantAvatar(
                                name: p.name,
                                colorIndex: p.colorIndex,
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: context
                                          .customTypography.bodyLargeBold
                                          .copyWith(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    if (p.email != null && p.email!.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 2.h),
                                        child: Text(
                                          p.email!,
                                          style: context.textTheme.labelSmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.primary,
                                  size: 22.sp,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return BlocProvider(
      create: (_) => AddExpenseCubit(
        getIt<GroupsRepository>(),
        getIt<CalculateSplits>(),
        widget.eventId,
        widget.participants,
      ),
      child: BlocConsumer<AddExpenseCubit, AddExpenseState>(
        listenWhen: (previous, current) =>
            previous.isSaved != current.isSaved ||
            (current.validationMessage != null &&
                previous.validationMessage != current.validationMessage) ||
            (current.errorMessage != null &&
                previous.errorMessage != current.errorMessage),
        listener: (context, state) {
          if (state.isSaved) {
            StatusComponents.showToast(
              context,
              message: context.l10n.expenseAddedSuccess,
            );
            context.router.popForced(true);
          } else if (state.validationMessage != null) {
            StatusComponents.showToast(
              context,
              message: state.validationMessage!,
              isError: true,
            );
          } else if (state.errorMessage != null) {
            StatusComponents.showToast(
              context,
              message: context.l10n.operationFailed,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AddExpenseCubit>();
          final selectedPaidBy = widget.participants
              .where((p) => p.id == state.paidByParticipantId)
              .firstOrNull;

          final redColor =
              isLight ? const Color(0xFFDC2626) : AppColors.semanticRed;
          final greenColor =
              isLight ? const Color(0xFF15803D) : AppColors.semanticGreen;

          final calcResult = state.splitCalculationResult;
          final isBalanced = calcResult?.isValid ?? true;
          final statusMessage = calcResult?.errorMessage;

          final topInset = MediaQuery.of(context).padding.top;
          final headerPaddingTop = topInset + kToolbarHeight;

          final isTablet = Breakpoints.isTablet(context);

          return Scaffold(
            backgroundColor: colorScheme.surface,
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: LiquidGlassAppBar(
              titleText: context.l10n.addExpense,
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
                    text: '${context.l10n.saveExpense} →',
                    isLoading: state.isSaving,
                    onPressed: () => cubit.saveExpense(),
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
                child: ListView(
                  padding: EdgeInsets.only(
                    left: isTablet ? 24.0 : 20.w,
                    right: isTablet ? 24.0 : 20.w,
                    top: headerPaddingTop + (isTablet ? 20.0 : 16.h),
                    bottom: 96.h + MediaQuery.of(context).viewPadding.bottom,
                  ),
                  children: [
                    // Amount Card
                    _LiquidGlassCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.0 : 20.w,
                        vertical: isTablet ? 24.0 : 20.h,
                      ),
                      child: GestureDetector(
                        onTap: () => _amountFocusNode.requestFocus(),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            Text(
                              context.l10n.amount.toUpperCase(),
                              style: customTypography.labelMediumMono.copyWith(
                                color: colorScheme.outline,
                                letterSpacing: 1.5,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ValueListenableBuilder<String>(
                                    valueListenable: getIt<PreferenceService>()
                                        .currencySymbolNotifier,
                                    builder: (context, currencySymbol, _) {
                                      return Text(
                                        '$currencySymbol ',
                                        style: customTypography
                                            .headlineLargeMonoBold
                                            .copyWith(
                                          color: colorScheme.primary,
                                          fontSize: 36.sp,
                                        ),
                                      );
                                    },
                                  ),
                                  IntrinsicWidth(
                                    child: TextField(
                                      controller: _amountController,
                                      focusNode: _amountFocusNode,
                                      autofocus: true,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}')),
                                      ],
                                      style: customTypography
                                          .headlineLargeMonoBold
                                          .copyWith(
                                        color: colorScheme.primary,
                                        fontSize: 36.sp,
                                      ),
                                      cursorColor: colorScheme.primary,
                                      decoration: InputDecoration(
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        hintText: '0',
                                        hintStyle: customTypography
                                            .headlineLargeMonoBold
                                            .copyWith(
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.35),
                                          fontSize: 36.sp,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      onChanged: (val) {
                                        final parsed =
                                            double.tryParse(val) ?? 0.0;
                                        cubit.setAmount(parsed);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Description Card
                    _LiquidGlassCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.description.toUpperCase(),
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.outline,
                              letterSpacing: 1.2,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: _descriptionController,
                            hintText: 'e.g. Seafood Dinner',
                            onChanged: (val) => cubit.setDescription(val),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Paid By Card (Triggering Modal Bottom Sheet)
                    _LiquidGlassCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PAID BY',
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.outline,
                              letterSpacing: 1.2,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          InkWell(
                            onTap: () => _showPaidByPickerBottomSheet(
                                context, cubit, state),
                            borderRadius: BorderRadius.circular(14.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? colorScheme.surfaceContainerLowest
                                        .withValues(alpha: 0.8)
                                    : colorScheme.surfaceContainerHigh
                                        .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isLight
                                      ? colorScheme.outlineVariant
                                          .withValues(alpha: 0.5)
                                      : customColors.glassStroke,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (selectedPaidBy != null) ...[
                                    ParticipantAvatar(
                                      name: selectedPaidBy.name,
                                      colorIndex: selectedPaidBy.colorIndex,
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedPaidBy.name,
                                            style: customTypography
                                                .bodyLargeBold
                                                .copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          if (selectedPaidBy.email != null &&
                                              selectedPaidBy.email!.isNotEmpty)
                                            Text(
                                              selectedPaidBy.email!,
                                              style: context
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ] else
                                    Expanded(
                                      child: Text(
                                        'Select who paid...',
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: colorScheme.primary,
                                    size: 22.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Split Among Card
                    _LiquidGlassCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.splitAmong.toUpperCase(),
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.outline,
                              letterSpacing: 1.2,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Visually Even Liquid Glass Animated Tab Bar
                          _LiquidGlassSplitModeTabBar(
                            currentMode: state.splitMode,
                            onModeChanged: (mode) => cubit.setSplitMode(mode),
                          ),

                          // Real-time allocation status badge
                          if (state.splitMode != SplitMode.equal &&
                              state.amount > 0) ...[
                            SizedBox(height: 12.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isBalanced
                                    ? greenColor.withValues(alpha: 0.12)
                                    : redColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isBalanced
                                      ? greenColor.withValues(alpha: 0.35)
                                      : redColor.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isBalanced
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.info_outline_rounded,
                                    color: isBalanced ? greenColor : redColor,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      isBalanced
                                          ? (state.splitMode ==
                                                  SplitMode.percentage
                                              ? '100% allocated'
                                              : 'Total amount balanced')
                                          : (statusMessage ??
                                              'Split amounts must balance'),
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                        color:
                                            isBalanced ? greenColor : redColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: 12.h),
                          Divider(
                            color: isLight
                                ? colorScheme.outlineVariant
                                    .withValues(alpha: 0.35)
                                : customColors.glassStroke,
                            height: 1,
                          ),
                          SizedBox(height: 8.h),

                          // List of participants to split with
                          ...widget.participants.map((p) {
                            final isSelected =
                                state.participantSelection[p.id] ?? false;
                            final splitResult = state.calculatedSplits
                                .where((s) => s.participantId == p.id)
                                .firstOrNull;
                            final splitAmount = splitResult?.amount ?? 0.0;
                            final splitPercentage = splitResult?.percentage;

                            final isCustomized = state.splitMode ==
                                    SplitMode.exact
                                ? (state.customAmounts.containsKey(p.id) &&
                                    state.customAmounts[p.id] != null)
                                : state.splitMode == SplitMode.percentage
                                    ? (state.customPercentages
                                            .containsKey(p.id) &&
                                        state.customPercentages[p.id] != null)
                                    : false;

                            final dummySplit = ExpenseSplit(
                              id: p.id,
                              expenseId: 0,
                              participantId: p.id,
                              participantName: p.name,
                              isSelected: isSelected,
                              customPercentage: splitPercentage,
                              splitAmount: splitAmount,
                            );

                            return SplitParticipantTile(
                              split: dummySplit,
                              splitMode: state.splitMode,
                              isEqually: state.splitMode == SplitMode.equal,
                              isCustomized: isCustomized,
                              customAmount: state.customAmounts[p.id],
                              customPercentage: state.customPercentages[p.id],
                              onToggle: (_) => cubit.toggleParticipant(p.id),
                              onAmountChanged: (val) {
                                final amt = double.tryParse(val);
                                cubit.setCustomAmount(p.id, amt);
                              },
                              onPercentageChanged: (val) {
                                final pct = double.tryParse(val);
                                cubit.setCustomPercentage(p.id, pct);
                              },
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Visually even animated liquid glass tab bar for split mode selection.
class _LiquidGlassSplitModeTabBar extends StatelessWidget {
  final SplitMode currentMode;
  final ValueChanged<SplitMode> onModeChanged;

  const _LiquidGlassSplitModeTabBar({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currencySymbol = getIt<PreferenceService>().currencySymbol;

    final modes = [
      (SplitMode.equal, '=', 'Equally'),
      (SplitMode.exact, currencySymbol, 'Exact'),
      (SplitMode.percentage, '%', 'Percent'),
    ];

    final selectedIndex = modes.indexWhere((m) => m.$1 == currentMode);
    final effectiveIndex = selectedIndex == -1 ? 0 : selectedIndex;

    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: isLight
            ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.70)
            : colorScheme.surfaceContainerLow.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isLight
              ? colorScheme.outlineVariant.withValues(alpha: 0.35)
              : customColors.glassStroke.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / 3;
                return Stack(
                  children: [
                    // Sliding liquid glass highlight pill
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      left: effectiveIndex * tabWidth,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isLight
                                ? [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(alpha: 0.88),
                                  ]
                                : [
                                    colorScheme.primary.withValues(alpha: 0.90),
                                    colorScheme.primary.withValues(alpha: 0.75),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: isLight ? 0.35 : 0.20),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary
                                  .withValues(alpha: isLight ? 0.20 : 0.35),
                              blurRadius: 8.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3 Evenly distributed tab buttons
                    Row(
                      children: modes.map((mode) {
                        final isSelected = mode.$1 == currentMode;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onModeChanged(mode.$1),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    mode.$2,
                                    style: TextStyle(
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    mode.$3,
                                    style: TextStyle(
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _LiquidGlassCard({
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = BorderRadius.circular(18.r);

    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.70),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.30),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.18),
                ],
        ),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.65)
              : customColors.glassStroke.withValues(alpha: 0.50),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.6 : 0.0),
            blurRadius: 8.r,
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
            padding: padding ?? EdgeInsets.zero,
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLight
              ? [
                  colorScheme.surface.withValues(alpha: 0.68),
                  colorScheme.surface.withValues(alpha: 0.90),
                ]
              : [
                  colorScheme.surface.withValues(alpha: 0.60),
                  colorScheme.surface.withValues(alpha: 0.85),
                ],
        ),
        border: Border(
          top: BorderSide(
            color: isLight
                ? Colors.white.withValues(alpha: 0.65)
                : customColors.glassStroke.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.25),
            blurRadius: 16.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
