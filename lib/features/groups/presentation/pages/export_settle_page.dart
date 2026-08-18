import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/status_components.dart';
import '../cubit/event_detail_cubit.dart';
import '../cubit/event_detail_state.dart';
import '../widgets/event_detail_shimmer.dart';
import '../widgets/settlement_row.dart';

@RoutePage()
class ExportSettlePage extends StatefulWidget {
  final int eventId;

  const ExportSettlePage({super.key, required this.eventId});

  @override
  State<ExportSettlePage> createState() => _ExportSettlePageState();
}

class _ExportSettlePageState extends State<ExportSettlePage> {
  late final EventDetailCubit _cubit;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<EventDetailCubit>()..loadEventDetail(widget.eventId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _exportCsv(EventDetailLoaded state) async {
    setState(() => _isExporting = true);

    try {
      final currencySymbol = getIt<PreferenceService>().currencySymbol;
      final buffer = StringBuffer();
      final event = state.event;
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      final exportDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // 1. Header & Event Information
      buffer.writeln(
          '============================================================');
      buffer.writeln('EXPENDLY BILL & SETTLEMENT SUMMARY REPORT');
      buffer.writeln(
          '============================================================');
      buffer.writeln('Event Name,${_escapeCsv(event.name)}');
      buffer.writeln('Category,${_escapeCsv(event.category)}');
      buffer.writeln('Status,${_escapeCsv(event.status)}');
      buffer.writeln(
          'Total Group Spend,$currencySymbol${event.totalSpent.toStringAsFixed(2)}');
      buffer.writeln('Number of Expenses,${state.expenses.length}');
      buffer.writeln('Number of Participants,${event.participants.length}');
      buffer.writeln('Generated At,$exportDate');
      buffer.writeln();

      // 2. Compute Member Balances Breakdown
      final Map<int, double> totalPaidByMember = {
        for (var p in event.participants) p.id: 0.0,
      };
      final Map<int, double> totalShareByMember = {
        for (var p in event.participants) p.id: 0.0,
      };

      for (final exp in state.expenses) {
        totalPaidByMember[exp.paidByParticipantId] =
            (totalPaidByMember[exp.paidByParticipantId] ?? 0.0) + exp.amount;
        for (final split in exp.splits.where((s) => s.isSelected)) {
          totalShareByMember[split.participantId] =
              (totalShareByMember[split.participantId] ?? 0.0) +
                  split.splitAmount;
        }
      }

      buffer.writeln(
          '============================================================');
      buffer.writeln('PARTICIPANTS & BALANCE OVERVIEW');
      buffer.writeln(
          '============================================================');
      buffer.writeln(
          'Participant Name,Email,Role,Total Paid,Total Share,Net Balance,Settlement Status');
      for (final p in event.participants) {
        final paid = totalPaidByMember[p.id] ?? 0.0;
        final share = totalShareByMember[p.id] ?? 0.0;
        final net = paid - share;
        final String status;
        if (net > 0.01) {
          status = 'Gets back $currencySymbol${net.toStringAsFixed(2)}';
        } else if (net < -0.01) {
          status = 'Owes $currencySymbol${(-net).toStringAsFixed(2)}';
        } else {
          status = 'Settled';
        }

        buffer.writeln(
          '${_escapeCsv(p.name)},'
          '${_escapeCsv(p.email ?? '')},'
          '${p.isOwner ? 'Owner' : 'Member'},'
          '$currencySymbol${paid.toStringAsFixed(2)},'
          '$currencySymbol${share.toStringAsFixed(2)},'
          '${net >= 0 ? '+' : ''}$currencySymbol${net.toStringAsFixed(2)},'
          '${_escapeCsv(status)}',
        );
      }
      buffer.writeln();

      // 3. Itemized Expenses & Bill Breakdown
      buffer.writeln(
          '============================================================');
      buffer.writeln('ITEMIZED EXPENSES & BILL BREAKDOWN');
      buffer.writeln(
          '============================================================');
      buffer.writeln(
          '#,Date & Time,Expense Title,Paid By,Total Amount,Split Count,Participants & Shares');
      for (var i = 0; i < state.expenses.length; i++) {
        final exp = state.expenses[i];
        final activeSplits = exp.splits.where((s) => s.isSelected).toList();
        final splitDetails = activeSplits.map((s) {
          final pct = s.customPercentage != null
              ? ' (${s.customPercentage!.toStringAsFixed(1)}%)'
              : '';
          return '${s.participantName}: $currencySymbol${s.splitAmount.toStringAsFixed(2)}$pct';
        }).join('; ');

        buffer.writeln(
          '${i + 1},'
          '${dateFormat.format(exp.date)},'
          '${_escapeCsv(exp.title)},'
          '${_escapeCsv(exp.paidByName)},'
          '$currencySymbol${exp.amount.toStringAsFixed(2)},'
          '${activeSplits.length},'
          '${_escapeCsv(splitDetails)}',
        );
      }
      buffer.writeln();

      // 4. Simplified Debt Settlements
      buffer.writeln(
          '============================================================');
      buffer.writeln('RECOMMENDED SETTLEMENT TRANSACTIONS (SIMPLIFIED DEBTS)');
      buffer.writeln(
          '============================================================');
      if (state.settlements.isEmpty) {
        buffer.writeln(
            'All group balances are settled. No pending debt transactions.');
      } else {
        buffer.writeln('From (Debtor),To (Creditor),Amount,Payer Email,Status');
        for (final s in state.settlements) {
          buffer.writeln(
            '${_escapeCsv(s.fromParticipant.name)},'
            '${_escapeCsv(s.toParticipant.name)},'
            '$currencySymbol${s.amount.toStringAsFixed(2)},'
            '${_escapeCsv(s.fromParticipant.email ?? '')},'
            'Pending Settlement',
          );
        }
      }

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/expendly_split_${event.name.replaceAll(' ', '_').toLowerCase()}.csv');
      await file.writeAsString(buffer.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Expendly settlement and bill breakdown report for ${event.name}',
        ),
      );
    } catch (e) {
      if (mounted) {
        StatusComponents.showToast(
          context,
          message: 'Failed to export CSV',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _sendEmailSummary(EventDetailLoaded state) async {
    final currencySymbol = getIt<PreferenceService>().currencySymbol;
    final event = state.event;
    final buffer = StringBuffer();
    final dateFormat = DateFormat.yMMMd().add_jm();

    // 1. Header
    buffer.writeln('💰 EXPENDLY SETTLEMENT & BILL SUMMARY');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Event: ${event.name}');
    buffer.writeln('Category: ${event.category} | Status: ${event.status}');
    buffer.writeln(
        'Total Group Spend: $currencySymbol${event.totalSpent.toStringAsFixed(2)}');
    buffer.writeln(
        'Total Expenses: ${state.expenses.length} | Members: ${event.participants.length}');
    buffer.writeln();

    // 2. Member Balances
    final Map<int, double> totalPaidByMember = {
      for (var p in event.participants) p.id: 0.0,
    };
    final Map<int, double> totalShareByMember = {
      for (var p in event.participants) p.id: 0.0,
    };

    for (final exp in state.expenses) {
      totalPaidByMember[exp.paidByParticipantId] =
          (totalPaidByMember[exp.paidByParticipantId] ?? 0.0) + exp.amount;
      for (final split in exp.splits.where((s) => s.isSelected)) {
        totalShareByMember[split.participantId] =
            (totalShareByMember[split.participantId] ?? 0.0) +
                split.splitAmount;
      }
    }

    buffer.writeln('👥 MEMBER BALANCES OVERVIEW');
    buffer.writeln('─────────────────────────────────────');
    for (final p in event.participants) {
      final paid = totalPaidByMember[p.id] ?? 0.0;
      final share = totalShareByMember[p.id] ?? 0.0;
      final net = paid - share;
      final String status;
      if (net > 0.01) {
        status = 'Gets back $currencySymbol${net.toStringAsFixed(2)}';
      } else if (net < -0.01) {
        status = 'Owes $currencySymbol${(-net).toStringAsFixed(2)}';
      } else {
        status = 'Settled up';
      }

      buffer.writeln('• ${p.name}${p.isOwner ? ' (Owner)' : ''}:');
      buffer.writeln(
          '   Paid: $currencySymbol${paid.toStringAsFixed(2)} | Share: $currencySymbol${share.toStringAsFixed(2)} → $status');
    }
    buffer.writeln();

    // 3. Itemized Expenses
    buffer.writeln('🧾 ITEMIZED EXPENSES & BILLS');
    buffer.writeln('─────────────────────────────────────');
    if (state.expenses.isEmpty) {
      buffer.writeln('No expenses recorded yet.');
    } else {
      for (var i = 0; i < state.expenses.length; i++) {
        final exp = state.expenses[i];
        final activeSplits = exp.splits.where((s) => s.isSelected).toList();
        final splitDetails = activeSplits.map((s) {
          final pct = s.customPercentage != null
              ? ' (${s.customPercentage!.toStringAsFixed(1)}%)'
              : '';
          return '${s.participantName} ($currencySymbol${s.splitAmount.toStringAsFixed(2)}$pct)';
        }).join(', ');

        buffer.writeln('${i + 1}. ${exp.title}');
        buffer.writeln(
            '   Amount: $currencySymbol${exp.amount.toStringAsFixed(2)} | Paid by: ${exp.paidByName}');
        buffer.writeln('   Date: ${dateFormat.format(exp.date)}');
        buffer.writeln(
            '   Split between (${activeSplits.length}): $splitDetails');
        buffer.writeln();
      }
    }

    // 4. Settlements
    buffer.writeln('🤝 HOW TO SETTLE UP (OPTIMIZED DEBTS)');
    buffer.writeln('─────────────────────────────────────');
    if (state.settlements.isEmpty) {
      buffer.writeln('All balances are settled! No debts to clear.');
    } else {
      for (final s in state.settlements) {
        buffer.writeln(
            '• ${s.fromParticipant.name} pays ${s.toParticipant.name}: $currencySymbol${s.amount.toStringAsFixed(2)}');
      }
      buffer.writeln(
          '\nAll debts are simplified to minimize total transactions.');
    }

    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Generated by Expendly • Designed for Fiscal Calm');

    final subject =
        Uri.encodeComponent('Settlement & Bill Summary: ${event.name}');
    final body = Uri.encodeComponent(buffer.toString());
    final url = Uri.parse('mailto:?subject=$subject&body=$body');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (mounted) {
      StatusComponents.showToast(
        context,
        message: 'Could not open email client',
        isError: true,
      );
    }
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + kToolbarHeight;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: LiquidGlassAppBar(
          onLeadingPressed: () => context.router.popForced(),
          titleText: context.l10n.exportAndSettle,
        ),
        bottomNavigationBar: BlocBuilder<EventDetailCubit, EventDetailState>(
          builder: (context, state) {
            if (state is EventDetailLoaded) {
              return _LiquidGlassBottomBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: context.l10n.exportToCsv,
                      isLoading: _isExporting,
                      icon: const Icon(Icons.file_download_outlined, size: 20),
                      onPressed: () => _exportCsv(state),
                      variant: AppButtonVariant.primary,
                    ),
                    SizedBox(height: 10.h),
                    AppButton(
                      text: context.l10n.sendViaEmail,
                      icon: const Icon(Icons.mail_outline_rounded, size: 20),
                      onPressed: () => _sendEmailSummary(state),
                      variant: AppButtonVariant.glass,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        body: BlocBuilder<EventDetailCubit, EventDetailState>(
          builder: (context, state) {
            if (state is EventDetailLoading || state is EventDetailInitial) {
              return Padding(
                padding: EdgeInsets.only(top: headerPaddingTop),
                child: const EventDetailShimmer(),
              );
            }

            if (state is EventDetailError) {
              return Padding(
                padding: EdgeInsets.only(top: headerPaddingTop),
                child: Center(
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
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is EventDetailLoaded) {
              final event = state.event;

              return ListView(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: headerPaddingTop + 16.h,
                  bottom: 140.h + MediaQuery.of(context).viewPadding.bottom,
                ),
                children: [
                  // Summary GlassContainer
                  GlassContainer(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.settlementSummary.toUpperCase(),
                          style: context.customTypography.labelMediumMono,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.totalExpense,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                CompactAmountText(
                                  amount: event.totalSpent,
                                  style: context
                                      .customTypography.headlineMediumMonoBold
                                      .copyWith(color: colorScheme.onSurface),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  context.l10n.yourShare,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                CompactAmountText(
                                  amount: event.userShare,
                                  style: context
                                      .customTypography.headlineMediumMonoBold
                                      .copyWith(color: colorScheme.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Debts to be Cleared Section
                  Text(
                    context.l10n.debtsToCleared.toUpperCase(),
                    style: context.customTypography.labelMediumMono,
                  ),
                  SizedBox(height: 12.h),

                  if (state.settlements.isEmpty)
                    GlassContainer(
                      padding: EdgeInsets.all(24.w),
                      child: Center(
                        child: Text(
                          'All balanced! No debts pending.',
                          style: context.customTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.settlements.map(
                      (s) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: SettlementRow(
                          settlement: s,
                          selectedParticipant: state.event.participants
                              .firstWhere((p) => p.isOwner,
                                  orElse: () => state.event.participants.first),
                        ),
                      ),
                    ),

                  SizedBox(height: 16.h),
                ],
              );
            }

            return const SizedBox.shrink();
          },
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
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.20),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.25),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.15),
                ],
        ),
        border: Border(
          top: BorderSide(
            color: isLight
                ? Colors.white.withValues(alpha: 0.50)
                : customColors.glassStroke.withValues(alpha: 0.40),
            width: 1.0,
          ),
        ),
        boxShadow: [
          // Specular top highlight glow
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.45 : 0.05),
            blurRadius: 4.r,
            spreadRadius: -1.r,
            offset: const Offset(0, -1),
          ),
          // Soft ambient elevation shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.15),
            blurRadius: 14.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            top: false,
            bottom: true,
            minimum: EdgeInsets.only(bottom: 12.h),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 4.h),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
