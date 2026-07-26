import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_custom_colors.dart';
import '../theme/app_custom_typography.dart';

/// Context extensions for localization, theme, colorScheme, textTheme, and design extensions.
extension BuildContextExtension on BuildContext {
  // Localization getter
  AppLocalizations get l10n {
    return AppLocalizations.of(this) ?? _FallbackLocalizations.instance;
  }

  // Theme getters
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Custom design extensions getters
  AppCustomColors get customColors => Theme.of(this).extension<AppCustomColors>() ?? AppCustomColors.dark;

  AppCustomTypography get customTypography =>
      Theme.of(this).extension<AppCustomTypography>() ?? AppCustomTypography.dark;
}

class _FallbackLocalizations implements AppLocalizations {
  static final _FallbackLocalizations instance = _FallbackLocalizations();

  @override
  String get localeName => 'en';

  @override
  String get appName => 'Expendly';

  @override
  String get totalBalance => 'TOTAL BALANCE';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get analytics => 'Analytics';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get seeAll => 'See All';

  @override
  String get foodAndDining => 'Food & Dining';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get groceryShopping => 'Grocery Shopping';

  @override
  String get freelancePayout => 'Freelance Payout';

  @override
  String get netflixSubscription => 'Netflix Subscription';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
