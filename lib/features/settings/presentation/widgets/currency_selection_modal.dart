import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/events/transaction_events.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/status_components.dart';
import '../../../analytics/presentation/cubit/analytics_cubit.dart';
import '../../../budgets/presentation/cubit/budget_cubit.dart';
import '../../../currency/domain/repositories/exchange_rate_repository.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../../onboarding/presentation/pages/currency_setup_page.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';

/// Modal bottom sheet for changing primary application currency and converting
/// stored monetary amounts across the application using live exchange rates.
class CurrencySelectionModal extends StatefulWidget {
  const CurrencySelectionModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return AdaptiveSheet.show<bool>(
      context: context,
      isScrollControlled: true,
      maxDialogWidth: 540.0,
      builder: (ctx) => const CurrencySelectionModal(),
    );
  }

  @override
  State<CurrencySelectionModal> createState() => _CurrencySelectionModalState();
}

class _CurrencySelectionModalState extends State<CurrencySelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  final ValueNotifier<Map<String, double>> _exchangeRatesNotifier =
      ValueNotifier<Map<String, double>>({});
  final ValueNotifier<bool> _isConvertingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _convertingCurrencyCodeNotifier =
      ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    try {
      final currentCode = getIt<PreferenceService>().currencyCode;
      if (getIt.isRegistered<ExchangeRateRepository>()) {
        final rates = await getIt<ExchangeRateRepository>()
            .getExchangeRates(base: currentCode);
        if (mounted) {
          _exchangeRatesNotifier.value = rates;
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    _exchangeRatesNotifier.dispose();
    _isConvertingNotifier.dispose();
    _convertingCurrencyCodeNotifier.dispose();
    super.dispose();
  }

  Future<bool> _showConfirmationDialog(CurrencyItem item, double? rate) async {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final currentCode = getIt<PreferenceService>().currencyCode;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final rateDisplay = rate != null && rate > 0
        ? (rate >= 1 ? rate.toStringAsFixed(2) : rate.toStringAsPrecision(3))
        : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor:
            isLight ? colorScheme.surface : colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
        contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        title: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.currency_exchange_rounded,
                color: colorScheme.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Change Currency?',
                style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeights.bold,
                  fontSize: 17.sp,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to change your primary currency from $currentCode to ${item.code} (${item.symbol})?',
              style: customTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
                fontSize: 13.5.sp,
              ),
            ),
            if (rateDisplay != null) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Live Rate: 1 $currentCode ≈ $rateDisplay ${item.code}',
                        style: (textTheme.bodyMedium ?? const TextStyle())
                            .copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeights.semiBold,
                          fontSize: 12.5.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Text(
              'All existing transactions, budgets, and recurring items will be converted using this exchange rate.',
              style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeights.semiBold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text(
              'Confirm & Convert',
              style: TextStyle(
                fontWeight: FontWeights.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _selectCurrency(CurrencyItem item) async {
    final prefs = getIt<PreferenceService>();
    final currentCode = prefs.currencyCode;

    if (item.code == currentCode) {
      Navigator.pop(context, false);
      return;
    }

    final rate = _exchangeRatesNotifier.value[item.code];
    final confirmed = await _showConfirmationDialog(item, rate);
    if (!confirmed || !mounted) return;

    _isConvertingNotifier.value = true;
    _convertingCurrencyCodeNotifier.value = item.code;

    try {
      double rate = 1.0;
      if (getIt.isRegistered<ExchangeRateRepository>()) {
        rate =
            await getIt<ExchangeRateRepository>().convertAllDataToNewCurrency(
          fromCurrency: currentCode,
          toCurrency: item.code,
        );
      }

      await prefs.setCurrency(code: item.code, symbol: item.symbol);

      // Reload all active cubit states and notify event bus so all app screens refresh
      try {
        if (getIt.isRegistered<DashboardCubit>()) {
          getIt<DashboardCubit>().loadDashboardData();
        }
        if (getIt.isRegistered<TransactionCubit>()) {
          getIt<TransactionCubit>().loadTransactions();
        }
        if (getIt.isRegistered<BudgetCubit>()) {
          getIt<BudgetCubit>().loadBudgets();
        }
        if (getIt.isRegistered<AnalyticsCubit>()) {
          getIt<AnalyticsCubit>().loadAnalytics(isSilent: true);
        }
        if (getIt.isRegistered<GroupsCubit>()) {
          getIt<GroupsCubit>().loadEvents(isSilent: true);
        }
        TransactionEvents.notifyUpdated();
      } catch (_) {}

      if (mounted) {
        final rateDisplay =
            rate >= 1 ? rate.toStringAsFixed(2) : rate.toStringAsPrecision(3);
        StatusComponents.showToast(
          context,
          message:
              'Currency set to ${item.code} (${item.symbol}) • Converted at 1 $currentCode = $rateDisplay ${item.code}',
          isSuccess: true,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        StatusComponents.showToast(
          context,
          message: 'Failed to convert currency data: $e',
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        _isConvertingNotifier.value = false;
        _convertingCurrencyCodeNotifier.value = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return _buildSheetContainer(context, null, true);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return _buildSheetContainer(context, scrollController, false);
      },
    );
  }

  Widget _buildSheetContainer(
    BuildContext context,
    ScrollController? scrollController,
    bool isTablet,
  ) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final prefs = getIt<PreferenceService>();
    final currentCode = prefs.currencyCode;

    return Container(
      height: isTablet ? 600.0 : null,
      decoration: BoxDecoration(
        color: isLight ? colorScheme.surface : colorScheme.surfaceContainerHigh,
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
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24.0 : 20.w,
        isTablet ? 20.0 : 12.h,
        isTablet ? 24.0 : 20.w,
        isTablet ? 20.0 : 16.h,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle Bar (phone only)
              if (!isTablet) ...[
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.5.h,
                    decoration: BoxDecoration(
                      color: isLight
                          ? colorScheme.outline.withValues(alpha: 0.4)
                          : colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              // 2. Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.currency_exchange_rounded,
                      color: colorScheme.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.selectPrimaryCurrency,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeights.bold,
                            fontSize: 16.5.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Live rates via Open Exchange Rates API',
                          style: customTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11.5.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 22.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // 3. Search Bar
              ValueListenableBuilder<String>(
                valueListenable: _searchQueryNotifier,
                builder: (context, query, _) {
                  return AppTextField(
                    controller: _searchController,
                    onChanged: (val) => _searchQueryNotifier.value = val,
                    hintText: context.l10n.searchCurrencyHint,
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
                    fillColor: isLight
                        ? colorScheme.surfaceContainerLow
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16.r),
                  );
                },
              ),
              SizedBox(height: 14.h),

              // 4. Currency Options List
              Expanded(
                child: ValueListenableBuilder<Map<String, double>>(
                  valueListenable: _exchangeRatesNotifier,
                  builder: (context, ratesMap, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: _searchQueryNotifier,
                      builder: (context, query, _) {
                        final filtered = query.isEmpty
                            ? defaultCurrencies
                            : defaultCurrencies.where((c) {
                                final q = query.toLowerCase();
                                return c.code.toLowerCase().contains(q) ||
                                    c.name.toLowerCase().contains(q) ||
                                    c.symbol.toLowerCase().contains(q);
                              }).toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 56.w,
                                  height: 56.w,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: 28.sp,
                                    color: colorScheme.outline,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'No currencies found',
                                  style: (textTheme.titleSmall ??
                                          const TextStyle())
                                      .copyWith(
                                    fontWeight: FontWeights.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Try searching by code, symbol, or currency name.',
                                  style: customTypography.bodyMedium.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => SizedBox(height: 8.h),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final isSelected = item.code == currentCode;
                            final rate = ratesMap[item.code];

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectCurrency(item),
                                borderRadius: BorderRadius.circular(16.r),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isLight
                                            ? colorScheme.primary
                                                .withValues(alpha: 0.15)
                                            : colorScheme.primary
                                                .withValues(alpha: 0.22))
                                        : (isLight
                                            ? colorScheme.surfaceContainerLowest
                                            : colorScheme.surfaceContainerLow
                                                .withValues(alpha: 0.50)),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : (isLight
                                              ? colorScheme.outlineVariant
                                                  .withValues(alpha: 0.50)
                                              : customColors.glassStroke
                                                  .withValues(alpha: 0.45)),
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : (isLight
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.03),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                )
                                              ]
                                            : null),
                                  ),
                                  child: Row(
                                    children: [
                                      // Currency Symbol Avatar Badge
                                      Container(
                                        width: 44.w,
                                        height: 44.w,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : (isLight
                                                  ? colorScheme
                                                      .surfaceContainerLow
                                                  : colorScheme
                                                      .surfaceContainerHighest),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          item.symbol,
                                          style: (textTheme.titleMedium ??
                                                  const TextStyle())
                                              .copyWith(
                                            fontWeight: FontWeights.bold,
                                            color: isSelected
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14.w),

                                      // Code, Name, and Live Exchange Rate
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  item.code,
                                                  style: (textTheme.bodyLarge ??
                                                          const TextStyle())
                                                      .copyWith(
                                                    fontWeight:
                                                        FontWeights.bold,
                                                    color:
                                                        colorScheme.onSurface,
                                                    fontSize: 14.5.sp,
                                                  ),
                                                ),
                                                if (isSelected) ...[
                                                  SizedBox(width: 8.w),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 6.w,
                                                      vertical: 1.5.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.primary
                                                          .withValues(
                                                              alpha: 0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.r),
                                                    ),
                                                    child: Text(
                                                      'ACTIVE',
                                                      style: customTypography
                                                          .labelMediumMono
                                                          .copyWith(
                                                        fontSize: 8.5.sp,
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeights.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              item.name,
                                              style: customTypography.bodyMedium
                                                  .copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 12.sp,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (!isSelected &&
                                                rate != null &&
                                                rate > 0) ...[
                                              SizedBox(height: 2.h),
                                              Text(
                                                '1 $currentCode ≈ ${rate >= 1 ? rate.toStringAsFixed(2) : rate.toStringAsPrecision(3)} ${item.code}',
                                                style: (textTheme.bodySmall ??
                                                        const TextStyle())
                                                    .copyWith(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.85),
                                                  fontSize: 10.5.sp,
                                                  fontWeight:
                                                      FontWeights.medium,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Selection / Progress Indicator
                                      ValueListenableBuilder<bool>(
                                        valueListenable: _isConvertingNotifier,
                                        builder: (context, isConverting, _) {
                                          return ValueListenableBuilder<
                                              String?>(
                                            valueListenable:
                                                _convertingCurrencyCodeNotifier,
                                            builder:
                                                (context, convertingCode, _) {
                                              if (isConverting &&
                                                  convertingCode == item.code) {
                                                return SizedBox(
                                                  width: 20.w,
                                                  height: 20.w,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      colorScheme.primary,
                                                    ),
                                                  ),
                                                );
                                              }

                                              if (isSelected) {
                                                return Container(
                                                  width: 26.w,
                                                  height: 26.w,
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.check_rounded,
                                                    color:
                                                        colorScheme.onPrimary,
                                                    size: 16.sp,
                                                  ),
                                                );
                                              }

                                              return Icon(
                                                Icons.chevron_right_rounded,
                                                color: colorScheme
                                                    .onSurfaceVariant
                                                    .withValues(alpha: 0.4),
                                                size: 20.sp,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Full overlay blocker when converting database currency
          ValueListenableBuilder<bool>(
            valueListenable: _isConvertingNotifier,
            builder: (context, isConverting, _) {
              if (!isConverting) return const SizedBox.shrink();
              return Container(
                color: colorScheme.surface.withValues(alpha: 0.7),
                child: Center(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'Converting amounts...',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeights.semiBold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
