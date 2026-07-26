import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/account_config_card.dart';
import '../widgets/onboarding_header.dart';

@RoutePage()
class AccountSetupPage extends StatefulWidget {
  const AccountSetupPage({super.key});

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final TextEditingController _cashBalanceController =
      TextEditingController(text: '0.00');
  final TextEditingController _bankBalanceController =
      TextEditingController(text: '0.00');

  void _onContinue() {
    // In final setup, we seed these initial balances into Drift DB accounts
    context.router.push(const OnboardingSecuritySetupRoute());
  }

  void _onSkip() {
    context.router.push(const OnboardingSecuritySetupRoute());
  }

  @override
  void dispose() {
    _cashBalanceController.dispose();
    _bankBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    final prefs = getIt<PreferenceService>();
    final currencySymbol = prefs.currencySymbol;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Header
                OnboardingHeader(
                  progress: 0.75,
                  stepLabel: l10n.setupStep3,
                  titleLabel: l10n.stepAccounts,
                  onSkip: _onSkip,
                ),
                verticalMarginLarge,

                // Title & Subtitle
                Text(
                  l10n.configureAccountsTitle,
                  style: customTypography.headlineLargeMobile,
                ),
                verticalMarginXSmall,
                Text(
                  l10n.configureAccountsDesc,
                  style: textTheme.bodyMedium,
                ),
                verticalMarginLarge,

                // Account Inputs List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AccountConfigCard(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: colorScheme.primary,
                          title: l10n.cashWalletName,
                          accountTypeLabel: 'Cash / Physical Wallet',
                          currencySymbol: currencySymbol,
                          amountController: _cashBalanceController,
                        ),
                        verticalMarginMedium,
                        AccountConfigCard(
                          icon: Icons.account_balance_rounded,
                          iconColor: colorScheme.secondary,
                          title: l10n.bankAccountName,
                          accountTypeLabel: 'Bank Account / Savings',
                          currencySymbol: currencySymbol,
                          amountController: _bankBalanceController,
                        ),
                      ],
                    ),
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
