import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/preferences/quick_entry_preferences.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_selection_tile.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/onboarding_header.dart';

class CurrencyItem {
  final String code;
  final String symbol;
  final String name;

  const CurrencyItem({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const List<CurrencyItem> defaultCurrencies = [
  CurrencyItem(code: 'NPR', symbol: 'रू', name: 'Nepalese Rupee'),
  CurrencyItem(code: 'USD', symbol: '\$', name: 'United States Dollar'),
  CurrencyItem(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyItem(code: 'GBP', symbol: '£', name: 'British Pound Sterling'),
  CurrencyItem(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  CurrencyItem(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  CurrencyItem(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar'),
  CurrencyItem(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  CurrencyItem(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
  CurrencyItem(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  CurrencyItem(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  CurrencyItem(code: 'AED', symbol: 'د.إ', name: 'United Arab Emirates Dirham'),
  CurrencyItem(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
  CurrencyItem(code: 'QAR', symbol: '﷼', name: 'Qatari Riyal'),
  CurrencyItem(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit'),
  CurrencyItem(code: 'THB', symbol: '฿', name: 'Thai Baht'),
  CurrencyItem(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
  CurrencyItem(code: 'HKD', symbol: 'HK\$', name: 'Hong Kong Dollar'),
  CurrencyItem(code: 'NZD', symbol: 'NZ\$', name: 'New Zealand Dollar'),
  CurrencyItem(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
  CurrencyItem(code: 'MXN', symbol: 'Mex\$', name: 'Mexican Peso'),
  CurrencyItem(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
  CurrencyItem(code: 'SEK', symbol: 'kr', name: 'Swedish Krona'),
  CurrencyItem(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone'),
  CurrencyItem(code: 'DKK', symbol: 'kr', name: 'Danish Krone'),
  CurrencyItem(code: 'PLN', symbol: 'zł', name: 'Polish Zloty'),
  CurrencyItem(code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
  CurrencyItem(code: 'RUB', symbol: '₽', name: 'Russian Ruble'),
  CurrencyItem(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah'),
  CurrencyItem(code: 'PHP', symbol: '₱', name: 'Philippine Peso'),
  CurrencyItem(code: 'VND', symbol: '₫', name: 'Vietnamese Dong'),
  CurrencyItem(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee'),
  CurrencyItem(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka'),
  CurrencyItem(code: 'LKR', symbol: 'Rs', name: 'Sri Lankan Rupee'),
  CurrencyItem(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound'),
  CurrencyItem(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
  CurrencyItem(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling'),
  CurrencyItem(code: 'GHS', symbol: 'GH₵', name: 'Ghanaian Cedi'),
  CurrencyItem(code: 'ARS', symbol: '\$', name: 'Argentine Peso'),
  CurrencyItem(code: 'CLP', symbol: '\$', name: 'Chilean Peso'),
  CurrencyItem(code: 'COP', symbol: '\$', name: 'Colombian Peso'),
  CurrencyItem(code: 'PEN', symbol: 'S/', name: 'Peruvian Sol'),
  CurrencyItem(code: 'ILS', symbol: '₪', name: 'Israeli New Shekel'),
  CurrencyItem(code: 'KWD', symbol: 'KD', name: 'Kuwaiti Dinar'),
  CurrencyItem(code: 'BHD', symbol: 'BD', name: 'Bahraini Dinar'),
  CurrencyItem(code: 'OMR', symbol: 'RO', name: 'Omani Rial'),
  CurrencyItem(code: 'JOD', symbol: 'JD', name: 'Jordanian Dinar'),
];

@RoutePage()
class CurrencySetupPage extends StatefulWidget {
  const CurrencySetupPage({super.key});

  @override
  State<CurrencySetupPage> createState() => _CurrencySetupPageState();
}

class _CurrencySetupPageState extends State<CurrencySetupPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _selectedCodeNotifier =
      ValueNotifier<String>('NPR');

  void _onContinue() async {
    final selectedCode = _selectedCodeNotifier.value;
    final selected = defaultCurrencies.firstWhere(
      (c) => c.code == selectedCode,
      orElse: () => defaultCurrencies.first,
    );

    final prefs = getIt<PreferenceService>();
    await prefs.setCurrency(code: selected.code, symbol: selected.symbol);
    if (getIt.isRegistered<QuickEntryPreferences>()) {
      await getIt<QuickEntryPreferences>().handleCurrencyChanged(selected.code);
    }

    if (mounted) {
      context.router.push(const OnboardingSecuritySetupRoute());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    _selectedCodeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator Header
                OnboardingHeader(
                  progress: 0.50,
                  stepLabel: l10n.setupStep2,
                  titleLabel: l10n.stepCurrency,
                ),
                verticalMarginLarge,

                // Header Section
                Text(
                  l10n.selectPrimaryCurrency,
                  style: customTypography.headlineLargeMobile,
                ),
                verticalMarginXSmall,
                Text(
                  l10n.selectCurrencyDescription,
                  style: textTheme.bodyMedium,
                ),
                verticalMargin20,

                // Search Field
                AppTextField(
                  controller: _searchController,
                  onChanged: (val) => _searchQueryNotifier.value = val,
                  hintText: l10n.searchCurrencyHint,
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.onSurfaceVariant),
                ),
                verticalMargin20,

                // Currency List Label
                Text(
                  l10n.commonCurrencies,
                  style: (textTheme.labelMedium ?? const TextStyle()).copyWith(
                    fontWeight: FontWeights.semiBold,
                    letterSpacing: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                verticalMarginSmall,

                // Currency List
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

                      return ValueListenableBuilder<String>(
                        valueListenable: _selectedCodeNotifier,
                        builder: (context, selectedCode, _) {
                          return ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => verticalMarginXSmall,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final isSelected = item.code == selectedCode;

                              return AppSelectionTile(
                                badgeText: item.symbol,
                                title: item.code,
                                subtitle: item.name,
                                isSelected: isSelected,
                                onTap: () =>
                                    _selectedCodeNotifier.value = item.code,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // Bottom Continue Button
                verticalMarginMedium,
                AppButton(
                  text: l10n.continueButton,
                  onPressed: _onContinue,
                ),
              ],
            ).defaultCanvasPadding(),
          ),
        ),
      ),
    );
  }
}
