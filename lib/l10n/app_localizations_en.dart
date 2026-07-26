// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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

  @override
  String get modernFiscalCore => 'MODERN FISCAL CORE';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get jul22Date => 'Jul 22, 2026';
}
