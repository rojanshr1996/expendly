import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_selection_tile.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/status_components.dart';
import '../../../budgets/presentation/cubit/budget_cubit.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../onboarding/presentation/pages/currency_setup_page.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';

/// Modal bottom sheet for changing primary application currency.
class CurrencySelectionModal extends StatefulWidget {
  const CurrencySelectionModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CurrencySelectionModal(),
    );
  }

  @override
  State<CurrencySelectionModal> createState() => _CurrencySelectionModalState();
}

class _CurrencySelectionModalState extends State<CurrencySelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  Future<void> _selectCurrency(CurrencyItem item) async {
    final prefs = getIt<PreferenceService>();
    await prefs.setCurrency(code: item.code, symbol: item.symbol);

    // Reload active cubit states so app screens refresh their currency symbols
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
    } catch (_) {}

    if (mounted) {
      StatusComponents.showToast(
        context,
        message: 'Primary currency set to ${item.code} (${item.symbol})',
        isSuccess: true,
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final prefs = getIt<PreferenceService>();
    final currentCode = prefs.currencyCode;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              verticalMarginMedium,

              // Header Title
              Text(
                context.l10n.selectPrimaryCurrency,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeights.bold,
                ),
              ),
              verticalMarginSmall,

              // Search Field
              AppTextField(
                controller: _searchController,
                onChanged: (val) => _searchQueryNotifier.value = val,
                hintText: context.l10n.searchCurrencyHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              verticalMarginSmall,

              // Currency Options List
              Expanded(
                child: ValueListenableBuilder<String>(
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

                    return ListView.separated(
                      controller: scrollController,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => verticalMarginXSmall,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isSelected = item.code == currentCode;

                        return AppSelectionTile(
                          badgeText: item.symbol,
                          title: item.code,
                          subtitle: item.name,
                          isSelected: isSelected,
                          onTap: () => _selectCurrency(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
