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
  String get financeRedefined => 'FINANCE REDEFINED';

  @override
  String get protectedByAes256 => 'Protected by AES-256';

  @override
  String get offlineEncryption => 'OFFLINE ENCRYPTION';

  @override
  String get appVersion => 'VER 1.0.0';

  @override
  String get selectPrimaryCurrency => 'Select Primary Currency';

  @override
  String get selectCurrencyDescription =>
      'Choose the default currency for your ledger. This can be changed later in settings.';

  @override
  String get searchCurrencyHint => 'Search currency...';

  @override
  String get commonCurrencies => 'COMMON CURRENCIES';

  @override
  String get continueButton => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get setupStep1 => 'Setup 01/04';

  @override
  String get setupStep2 => 'Setup 02/04';

  @override
  String get setupStep3 => 'Setup 03/04';

  @override
  String get setupStep4 => 'Setup 04/04';

  @override
  String get stepWelcome => 'Step: Welcome';

  @override
  String get stepCurrency => 'Step: Currency';

  @override
  String get stepAccounts => 'Step: Accounts';

  @override
  String get stepSecurity => 'Step: Security';

  @override
  String get welcomeTitle1 => '100% Offline & Private';

  @override
  String get welcomeDesc1 =>
      'Your financial data stays exclusively on your device, secured with hardware-backed AES-256 encryption.';

  @override
  String get welcomeTitle2 => 'Unified Accounts Control';

  @override
  String get welcomeDesc2 =>
      'Manage Cash, Bank Accounts, Credit Cards, and Savings in one sleek, modern dashboard.';

  @override
  String get welcomeTitle3 => 'Calculated Fiscal Calm';

  @override
  String get welcomeDesc3 =>
      'Track spending velocity, enforce dynamic monthly budgets, and reach your savings goals with total peace of mind.';

  @override
  String get configureAccountsTitle => 'Configure Initial Accounts';

  @override
  String get configureAccountsDesc =>
      'Set up your starting balances for Cash and Bank. You can add more accounts later in settings.';

  @override
  String get cashWalletName => 'Cash Wallet';

  @override
  String get bankAccountName => 'Main Bank Account';

  @override
  String get startingBalance => 'Starting Balance';

  @override
  String get setupPinTitle => 'Set Security PIN (Optional)';

  @override
  String get setupPinDesc =>
      'Create a 4-digit security PIN to restrict access to your financial ledger.';

  @override
  String get setPinHeader => 'Enter 4-Digit PIN';

  @override
  String get confirmPinHeader => 'Confirm 4-Digit PIN';

  @override
  String get setupRecoveryTitle => 'Set 2 Security Questions';

  @override
  String get setupRecoveryDesc =>
      'Set secret answers for 2 security questions to recover your PIN if forgotten.';

  @override
  String get question1Label => 'Question 1 of 2';

  @override
  String get question2Label => 'Question 2 of 2';

  @override
  String get recoveryQuestion1 => 'What is your secret security passphrase?';

  @override
  String get recoveryQuestion2 => 'In what city were you born?';

  @override
  String get recoveryQuestion3 => 'What was the name of your first pet?';

  @override
  String get recoveryQuestion4 => 'What is your favorite personal code word?';

  @override
  String get enterAnswerHint => 'Enter secret answer...';

  @override
  String get saveSecuritySetup => 'Save & Continue';

  @override
  String get securitySetupComplete =>
      'Security PIN & Recovery Answers configured!';

  @override
  String get pinMismatchError => 'PINs do not match. Please try again.';

  @override
  String get securityQuestionsRequired =>
      'Please answer both security questions to protect your PIN.';

  @override
  String get youAreAllSet => 'You\'re all set!';

  @override
  String get allSetDescription =>
      'Your private financial ledger is calibrated and ready to help you achieve absolute fiscal clarity.';

  @override
  String get defaultWallet => 'Default Wallet';

  @override
  String get personalLedger => 'Personal Ledger';

  @override
  String get currency => 'Currency';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get biometricUnlock => 'Biometric Unlock';

  @override
  String get biometricsDescription => 'Secure your ledger with FaceID/TouchID';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get notificationsDescription => 'Daily summaries & budget alerts';

  @override
  String get getStarted => 'Get Started';

  @override
  String get agreePolicyText =>
      'By clicking \"Get Started\", you agree to local data storage policy.';

  @override
  String get unlockToContinue => 'Unlock to continue';

  @override
  String get secureAccessTitle => 'Expendly Secure Access';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get resetPinTitle => 'Reset Security PIN';

  @override
  String get resetPinDesc =>
      'Verify your identity using your secret security answer or biometrics to set a new PIN.';

  @override
  String get resetViaBiometrics => 'Reset via Biometrics';

  @override
  String get resetViaSecurityAnswer => 'Reset via Secret Answer';

  @override
  String get selectQuestionToVerify => 'Select security question to answer:';

  @override
  String get securityQuestionLabel => 'Security Recovery Question';

  @override
  String get defaultSecurityQuestion =>
      'What is your secret security key or word?';

  @override
  String get yourAnswerHint => 'Enter your secret answer...';

  @override
  String get verifyAnswer => 'Verify & Reset PIN';

  @override
  String get invalidAnswerError => 'Incorrect secret answer. Please try again.';

  @override
  String get pinResetSuccess => 'Security PIN reset successfully!';

  @override
  String get newPinHeader => 'Enter New 4-Digit PIN';

  @override
  String get incorrectPinMessage => 'Incorrect PIN. Please try again.';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get cancelButton => 'Cancel';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get jul22Date => 'Jul 22, 2026';
}
