import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/status_components.dart';
import '../../../../core/ads/ad_helper.dart';
import '../../../../core/ads/widgets/banner_ad_widget.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../domain/entities/transaction_item.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';

@RoutePage()
class TransactionDetailsPage extends StatelessWidget {
  final TransactionItem transaction;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
    this.isPrivacyModeNotifier,
  });

  Future<void> _editTransaction(BuildContext context) async {
    final result = await context.router.push(
      ModernAddTransactionRoute(initialTransaction: transaction),
    );
    if (result == true && context.mounted) {
      context.router.maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;

    return BlocProvider.value(
      value: getIt<TransactionCubit>(),
      child: BlocListener<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionActionSuccess) {
            try {
              getIt<DashboardCubit>().loadDashboardData();
            } catch (_) {}
            StatusComponents.showToast(
              context,
              message: l10n.transactionDeletedSuccess,
              isSuccess: true,
            );
            context.router.maybePop(true);
          }
        },
        child: Builder(
          builder: (context) {
            final topInset = MediaQuery.of(context).padding.top;
            final headerPaddingTop = topInset + kToolbarHeight;

            return Scaffold(
              backgroundColor: colorScheme.surface,
              extendBodyBehindAppBar: true,
              appBar: LiquidGlassAppBar(
                titleText: l10n.transactionDetails,
                onLeadingPressed: () => context.router.maybePop(),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_rounded,
                      color: colorScheme.primary,
                    ),
                    tooltip: 'Edit transaction',
                    onPressed: () => _editTransaction(context),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.only(top: headerPaddingTop),
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        verticalMarginMedium,

                        // Hero Header Card (Delay 0ms)
                        _StaggeredEntrance(
                          delayMs: 0,
                          child: _HeroHeaderCard(
                            transaction: transaction,
                            isPrivacyModeNotifier: isPrivacyModeNotifier,
                          ),
                        ),
                        verticalMarginMedium,

                        // Metadata Details Section (Delay 100ms)
                        _StaggeredEntrance(
                          delayMs: 100,
                          child: _MetadataDetailsCard(transaction: transaction),
                        ),
                        verticalMarginLarge,

                        // Delete Action Button (Delay 200ms)
                        _StaggeredEntrance(
                          delayMs: 200,
                          child: _DeleteTransactionButton(
                            onDeletePressed: () => _confirmAndDelete(context),
                          ),
                        ),
                        verticalMarginLarge,

                        // Banner Ad
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child:
                              BannerAdWidget(adUnitId: AdHelper.bannerAdUnitId),
                        ),
                      ],
                    ).defaultCanvasPadding(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await StatusComponents.showConfirmationBottomSheet(
      context,
      title: l10n.deleteTransactionConfirmTitle,
      message: l10n.deleteTransactionConfirmDesc,
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<TransactionCubit>().deleteTransaction(transaction.id);
    }
  }
}

class _HeroHeaderCard extends StatelessWidget {
  final TransactionItem transaction;
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const _HeroHeaderCard({
    required this.transaction,
    this.isPrivacyModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final amountColor = transaction.type == TransactionType.income
        ? customColors.semanticGreen
        : transaction.type == TransactionType.transfer
            ? customColors.semanticBlue
            : customColors.semanticRed;

    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        children: [
          // Category Icon Avatar (Scale & Fade)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.65 + (value * 0.35),
                  child: child,
                ),
              );
            },
            child: Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: amountColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                transaction.type == TransactionType.transfer
                    ? Icons.swap_horiz_rounded
                    : _getIconData(transaction.categoryIcon),
                color: amountColor,
                size: 32.sp,
              ),
            ),
          ),
          verticalMarginSmall,

          // Category Title (Slide & Fade)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1.0 - value) * -8.h),
                  child: child,
                ),
              );
            },
            child: Text(
              transaction.type == TransactionType.transfer
                  ? context.l10n.transfer
                  : transaction.categoryName,
              style: customTypography.bodyLargeBold.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          verticalMarginXXSmall,

          // Type Tag Chip (Scale & Fade)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + (value * 0.15),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: amountColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getTypeLabel(context, transaction.type).toUpperCase(),
                style: customTypography.labelMediumMono.copyWith(
                  color: amountColor,
                  fontWeight: FontWeights.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          verticalMarginMedium,

          // Monetary Amount Display (Bounce Scale & Fade)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.88 + (value * 0.12),
                  child: child,
                ),
              );
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
              builder: (context, isPrivacyMode, _) {
                return CompactAmountText(
                  amount: transaction.amount,
                  isPrivacyMode: isPrivacyMode,
                  showSign: true,
                  type: transaction.type,
                  isIncome: transaction.type == TransactionType.income
                      ? true
                      : (transaction.type == TransactionType.expense
                          ? false
                          : null),
                  compact: false,
                  style: customTypography.headlineLargeMonoBold.copyWith(
                    color: amountColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(BuildContext context, TransactionType type) {
    final l10n = context.l10n;
    switch (type) {
      case TransactionType.income:
        return l10n.income;
      case TransactionType.expense:
        return l10n.expense;
      case TransactionType.transfer:
        return l10n.source;
    }
  }

  IconData _getIconData(String iconName) {
    return CategoryIconHelper.getIcon(iconName);
  }
}

class _MetadataDetailsCard extends StatelessWidget {
  final TransactionItem transaction;

  const _MetadataDetailsCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDateTime =
        DateFormat.yMMMMd(locale).add_jm().format(transaction.timestamp);

    final rows = <Widget>[
      _DetailRow(
        icon: Icons.calendar_today_rounded,
        label: l10n.dateAndTimeLabel,
        value: formattedDateTime,
        isMonospace: true,
      ),
      if (transaction.type != TransactionType.transfer)
        _DetailRow(
          icon: Icons.category_outlined,
          label: l10n.categoryLabel,
          value: transaction.categoryName,
        ),
      if (transaction.paymentMethod != null)
        _DetailRow(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.paymentMethodLabel,
          value: _formatPaymentMethod(context, transaction.paymentMethod!),
        ),
      if (transaction.note?.isNotEmpty == true)
        _DetailRow(
          icon: Icons.notes_rounded,
          label: l10n.noteLabel,
          value: transaction.note!,
        ),
      _DetailRow(
        icon: Icons.tag_rounded,
        label: l10n.transactionIdLabel,
        value: '#${transaction.id}',
        isMonospace: true,
      ),
    ];

    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
        children
            .add(Divider(height: 24, color: context.customColors.glassStroke));
      }
      children.add(
        _StaggeredEntrance(
          delayMs: 120 + (i * 45),
          child: rows[i],
        ),
      );
    }

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: children,
      ),
    );
  }

  String _formatPaymentMethod(BuildContext context, PaymentMethod method) {
    final l10n = context.l10n;
    switch (method) {
      case PaymentMethod.card:
        return l10n.cardPaymentMethod;
      case PaymentMethod.cash:
        return l10n.cashPaymentMethod;
      case PaymentMethod.account:
        return l10n.accountPaymentMethod;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    return Row(
      children: [
        Icon(
          icon,
          size: 20.r,
          color: colorScheme.outline,
        ),
        horizontalMarginSmall,
        Text(
          label,
          style: customTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        horizontalMarginSmall,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: isMonospace
                ? customTypography.labelMediumMono.copyWith(
                    color: colorScheme.onSurface,
                  )
                : customTypography.bodyLargeBold.copyWith(
                    color: colorScheme.onSurface,
                  ),
          ),
        ),
      ],
    );
  }
}

class _DeleteTransactionButton extends StatelessWidget {
  final VoidCallback onDeletePressed;

  const _DeleteTransactionButton({required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final customTypography = context.customTypography;

    final customColors = context.customColors;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.94 + (value * 0.06),
            child: child,
          ),
        );
      },
      child: OutlinedButton.icon(
        onPressed: onDeletePressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: customColors.semanticRed,
          side: BorderSide(color: customColors.semanticRed),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: Icon(Icons.delete_outline_rounded, size: 20.r),
        label: Text(
          l10n.deleteTransaction,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: customTypography.bodyLargeBold.copyWith(
            color: customColors.semanticRed,
          ),
        ),
      ),
    );
  }
}

class _StaggeredEntrance extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _StaggeredEntrance({
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * 16.h),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
