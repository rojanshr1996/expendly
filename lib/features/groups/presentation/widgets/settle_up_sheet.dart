import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/settlement.dart';
import 'participant_avatar.dart';

class SettleUpSheet extends StatefulWidget {
  final Settlement settlement;
  final Future<void> Function(double amount, String note) onConfirm;

  const SettleUpSheet({
    super.key,
    required this.settlement,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required Settlement settlement,
    required Future<void> Function(double amount, String note) onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettleUpSheet(
        settlement: settlement,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<SettleUpSheet> createState() => _SettleUpSheetState();
}

class _SettleUpSheetState extends State<SettleUpSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.settlement.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(
      text:
          'Payment: ${widget.settlement.fromParticipant.name} → ${widget.settlement.toParticipant.name}',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _isLoading = true);
    try {
      await widget.onConfirm(amount, _noteController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currencySymbol = getIt<PreferenceService>().currencySymbol;

    final greenColor =
        isLight ? const Color(0xFF15803D) : AppColors.semanticGreen;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isLight
              ? colorScheme.surface.withValues(alpha: 0.95)
              : colorScheme.surfaceContainerHigh.withValues(alpha: 0.90),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border(
            top: BorderSide(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.8)
                  : customColors.glassStroke,
              width: 1.2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20.r,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color:
                              colorScheme.outlineVariant.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Settle Up Payment',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.pop(context),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Direction Row (Debtor -> Creditor)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isLight
                            ? colorScheme.surfaceContainerLowest
                                .withValues(alpha: 0.7)
                            : colorScheme.surfaceContainerLow
                                .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isLight
                              ? colorScheme.outlineVariant
                                  .withValues(alpha: 0.3)
                              : customColors.glassStroke.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              ParticipantAvatar(
                                name: widget.settlement.fromParticipant.name,
                                colorIndex: widget
                                    .settlement.fromParticipant.colorIndex,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.settlement.fromParticipant.name,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Payer',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: greenColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: greenColor,
                              size: 20.sp,
                            ),
                          ),
                          Column(
                            children: [
                              ParticipantAvatar(
                                name: widget.settlement.toParticipant.name,
                                colorIndex:
                                    widget.settlement.toParticipant.colorIndex,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.settlement.toParticipant.name,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Recipient',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Amount Input
                    Text(
                      'AMOUNT',
                      style: customTypography.labelMediumMono.copyWith(
                        color: colorScheme.outline,
                        letterSpacing: 1.2,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isLight
                            ? colorScheme.surfaceContainerLowest
                            : colorScheme.surfaceContainerLow
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isLight
                              ? colorScheme.outlineVariant
                                  .withValues(alpha: 0.4)
                              : customColors.glassStroke,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '$currencySymbol ',
                            style: customTypography.headlineMediumMonoBold
                                .copyWith(
                              color: colorScheme.primary,
                              fontSize: 22.sp,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              style: customTypography.headlineMediumMonoBold
                                  .copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 22.sp,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Note Input
                    Text(
                      'NOTE / DESCRIPTION',
                      style: customTypography.labelMediumMono.copyWith(
                        color: colorScheme.outline,
                        letterSpacing: 1.2,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    AppTextField(
                      controller: _noteController,
                      hintText: 'Settlement Note',
                    ),
                    SizedBox(height: 20.h),

                    // Confirm Button
                    AppButton(
                      text: 'Record Settlement Payment',
                      isLoading: _isLoading,
                      onPressed: _handleConfirm,
                      variant: AppButtonVariant.primary,
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
