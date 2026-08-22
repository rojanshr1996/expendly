import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Expendly'**
  String get appName;

  /// Header title for total balance overview
  ///
  /// In en, this message translates to:
  /// **'TOTAL BALANCE'**
  String get totalBalance;

  /// Label shown when net balance is negative
  ///
  /// In en, this message translates to:
  /// **'Overspent'**
  String get overspent;

  /// Label shown when net balance is positive
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get netPositive;

  /// Label for this month period on dashboard cards
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// Header title for net worth
  ///
  /// In en, this message translates to:
  /// **'NET WORTH'**
  String get netWorth;

  /// Header title for cash flow
  ///
  /// In en, this message translates to:
  /// **'CASH FLOW'**
  String get cashFlow;

  /// Header title for monthly budget
  ///
  /// In en, this message translates to:
  /// **'MONTHLY BUDGET'**
  String get monthlyBudget;

  /// Header title for cash flow insights chart
  ///
  /// In en, this message translates to:
  /// **'CASH FLOW INSIGHTS'**
  String get cashFlowInsights;

  /// Header title for net savings
  ///
  /// In en, this message translates to:
  /// **'NET SAVINGS'**
  String get netSavings;

  /// Label for financial income
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expenses tab label
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Label for expense
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Generic all option label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Button text to add a new transaction
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// Title for adding an expense
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Button text to view analytics
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Section title for recent transaction history
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Action text to view all items
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Category for food expenses
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get foodAndDining;

  /// Category for entertainment expenses
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// Transaction title for groceries
  ///
  /// In en, this message translates to:
  /// **'Grocery Shopping'**
  String get groceryShopping;

  /// Transaction title for income payout
  ///
  /// In en, this message translates to:
  /// **'Freelance Payout'**
  String get freelancePayout;

  /// Transaction title for subscription
  ///
  /// In en, this message translates to:
  /// **'Netflix Subscription'**
  String get netflixSubscription;

  /// Relative date label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Relative date label for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Application tagline displayed on splash screen
  ///
  /// In en, this message translates to:
  /// **'MODERN FISCAL CORE'**
  String get modernFiscalCore;

  /// Subtitle on splash screen
  ///
  /// In en, this message translates to:
  /// **'Finances, balanced'**
  String get financeRedefined;

  /// Security label on splash screen
  ///
  /// In en, this message translates to:
  /// **'Protected & Offline'**
  String get protectedByAes256;

  /// Footer label on splash screen
  ///
  /// In en, this message translates to:
  /// **'OFFLINE DATA'**
  String get offlineEncryption;

  /// App version label on splash screen
  ///
  /// In en, this message translates to:
  /// **'VER 1.1.2'**
  String get appVersion;

  /// Header title for currency setup page
  ///
  /// In en, this message translates to:
  /// **'Select Primary Currency'**
  String get selectPrimaryCurrency;

  /// Subheading description for currency setup page
  ///
  /// In en, this message translates to:
  /// **'Choose the default currency for your ledger. This can be changed later in settings.'**
  String get selectCurrencyDescription;

  /// Search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Search currency...'**
  String get searchCurrencyHint;

  /// Section title for list of currencies
  ///
  /// In en, this message translates to:
  /// **'COMMON CURRENCIES'**
  String get commonCurrencies;

  /// Generic continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Onboarding progress step 1
  ///
  /// In en, this message translates to:
  /// **'Setup 01/04'**
  String get setupStep1;

  /// Onboarding progress step 2
  ///
  /// In en, this message translates to:
  /// **'Setup 02/04'**
  String get setupStep2;

  /// Onboarding progress step 3
  ///
  /// In en, this message translates to:
  /// **'Setup 03/04'**
  String get setupStep3;

  /// Onboarding progress step 4
  ///
  /// In en, this message translates to:
  /// **'Setup 04/04'**
  String get setupStep4;

  /// Welcome carousel step title
  ///
  /// In en, this message translates to:
  /// **'Step: Welcome'**
  String get stepWelcome;

  /// Onboarding step title for currency
  ///
  /// In en, this message translates to:
  /// **'Step: Currency'**
  String get stepCurrency;

  /// Onboarding step title for accounts
  ///
  /// In en, this message translates to:
  /// **'Step: Accounts'**
  String get stepAccounts;

  /// Onboarding step title for security
  ///
  /// In en, this message translates to:
  /// **'Step: Security'**
  String get stepSecurity;

  /// Carousel slide 1 title
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Private'**
  String get welcomeTitle1;

  /// Carousel slide 1 description
  ///
  /// In en, this message translates to:
  /// **'Your financial data stays exclusively on your device.'**
  String get welcomeDesc1;

  /// Carousel slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Unified Accounts Control'**
  String get welcomeTitle2;

  /// Carousel slide 2 description
  ///
  /// In en, this message translates to:
  /// **'Manage Cash, Bank Accounts, Credit Cards, and Savings in one sleek, modern dashboard.'**
  String get welcomeDesc2;

  /// Carousel slide 3 title
  ///
  /// In en, this message translates to:
  /// **'Calculated Fiscal Calm'**
  String get welcomeTitle3;

  /// Carousel slide 3 description
  ///
  /// In en, this message translates to:
  /// **'Track spending velocity, enforce dynamic monthly budgets, and reach your savings goals with total peace of mind.'**
  String get welcomeDesc3;

  /// Title for account setup page
  ///
  /// In en, this message translates to:
  /// **'Configure Initial Accounts'**
  String get configureAccountsTitle;

  /// Description for account setup page
  ///
  /// In en, this message translates to:
  /// **'Set up your starting balances for Cash and Bank. You can add more accounts later in settings.'**
  String get configureAccountsDesc;

  /// Default cash wallet name
  ///
  /// In en, this message translates to:
  /// **'Cash Wallet'**
  String get cashWalletName;

  /// Default bank account name
  ///
  /// In en, this message translates to:
  /// **'Main Bank Account'**
  String get bankAccountName;

  /// Label for account starting balance input
  ///
  /// In en, this message translates to:
  /// **'Starting Balance'**
  String get startingBalance;

  /// Title for PIN setup page
  ///
  /// In en, this message translates to:
  /// **'Set Security PIN (Optional)'**
  String get setupPinTitle;

  /// Description for PIN setup page
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit security PIN to restrict access to your financial ledger.'**
  String get setupPinDesc;

  /// Header prompt for PIN entry
  ///
  /// In en, this message translates to:
  /// **'Enter 4-Digit PIN'**
  String get setPinHeader;

  /// Header prompt for PIN confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirm 4-Digit PIN'**
  String get confirmPinHeader;

  /// Title for setting up 2 recovery questions in onboarding
  ///
  /// In en, this message translates to:
  /// **'Set 2 Security Questions'**
  String get setupRecoveryTitle;

  /// Description for setting up 2 recovery questions
  ///
  /// In en, this message translates to:
  /// **'Set secret answers for 2 security questions to recover your PIN if forgotten.'**
  String get setupRecoveryDesc;

  /// Label for question 1
  ///
  /// In en, this message translates to:
  /// **'Question 1 of 2'**
  String get question1Label;

  /// Label for question 2
  ///
  /// In en, this message translates to:
  /// **'Question 2 of 2'**
  String get question2Label;

  /// Default intuitive security question 1
  ///
  /// In en, this message translates to:
  /// **'What is your secret security passphrase?'**
  String get recoveryQuestion1;

  /// Default intuitive security question 2
  ///
  /// In en, this message translates to:
  /// **'In what city were you born?'**
  String get recoveryQuestion2;

  /// Default intuitive security question 3
  ///
  /// In en, this message translates to:
  /// **'What was the name of your first pet?'**
  String get recoveryQuestion3;

  /// Default intuitive security question 4
  ///
  /// In en, this message translates to:
  /// **'What is your favorite personal code word?'**
  String get recoveryQuestion4;

  /// Placeholder hint for typing recovery answer
  ///
  /// In en, this message translates to:
  /// **'Enter secret answer...'**
  String get enterAnswerHint;

  /// Button text to save PIN and recovery answers
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveSecuritySetup;

  /// Toast message when security setup is complete
  ///
  /// In en, this message translates to:
  /// **'Security PIN & Recovery Answers configured!'**
  String get securitySetupComplete;

  /// Error text when PIN entry doesn't match
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Please try again.'**
  String get pinMismatchError;

  /// Error toast when user tries to save security questions without answering both
  ///
  /// In en, this message translates to:
  /// **'Please answer both security questions to protect your PIN.'**
  String get securityQuestionsRequired;

  /// Title on final setup completion page
  ///
  /// In en, this message translates to:
  /// **'You\'\'re all set!'**
  String get youAreAllSet;

  /// Subheading text on final setup completion page
  ///
  /// In en, this message translates to:
  /// **'Your private financial ledger is calibrated and ready to help you achieve absolute fiscal clarity.'**
  String get allSetDescription;

  /// Label for default wallet bento card
  ///
  /// In en, this message translates to:
  /// **'Default Wallet'**
  String get defaultWallet;

  /// Default wallet name
  ///
  /// In en, this message translates to:
  /// **'Personal Ledger'**
  String get personalLedger;

  /// Label for currency bento card
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Section header for preference toggles
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// Title for biometric toggle
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get biometricUnlock;

  /// Subtitle for biometric toggle
  ///
  /// In en, this message translates to:
  /// **'Secure your ledger with FaceID/TouchID'**
  String get biometricsDescription;

  /// Title for push notification toggle
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Subtitle for push notification toggle
  ///
  /// In en, this message translates to:
  /// **'Daily summaries & budget alerts'**
  String get notificationsDescription;

  /// Action button text to finish onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Disclaimer text below Get Started button
  ///
  /// In en, this message translates to:
  /// **'By clicking \"Get Started\", you agree to local data storage policy.'**
  String get agreePolicyText;

  /// Header title on security lock screen
  ///
  /// In en, this message translates to:
  /// **'Unlock to continue'**
  String get unlockToContinue;

  /// Subtitle on security lock screen
  ///
  /// In en, this message translates to:
  /// **'Expendly Secure Access'**
  String get secureAccessTitle;

  /// Button text to trigger biometrics on lock screen
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// Button text to trigger PIN reset
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// Title for PIN reset modal
  ///
  /// In en, this message translates to:
  /// **'Reset Security PIN'**
  String get resetPinTitle;

  /// Subtitle for PIN reset modal
  ///
  /// In en, this message translates to:
  /// **'Verify your identity using your secret security answer or biometrics to set a new PIN.'**
  String get resetPinDesc;

  /// Option to reset PIN using biometrics
  ///
  /// In en, this message translates to:
  /// **'Reset via Biometrics'**
  String get resetViaBiometrics;

  /// Option to reset PIN using security question
  ///
  /// In en, this message translates to:
  /// **'Reset via Secret Answer'**
  String get resetViaSecurityAnswer;

  /// Instruction label when resetting PIN via security question
  ///
  /// In en, this message translates to:
  /// **'Select security question to verify:'**
  String get selectQuestionToVerify;

  /// Label for security question
  ///
  /// In en, this message translates to:
  /// **'Security Recovery Question'**
  String get securityQuestionLabel;

  /// Default security question string
  ///
  /// In en, this message translates to:
  /// **'What is your secret security key or word?'**
  String get defaultSecurityQuestion;

  /// Input hint for secret answer
  ///
  /// In en, this message translates to:
  /// **'Enter your secret answer...'**
  String get yourAnswerHint;

  /// Button text to verify answer and proceed to new PIN
  ///
  /// In en, this message translates to:
  /// **'Verify & Reset PIN'**
  String get verifyAnswer;

  /// Error text for invalid secret answer
  ///
  /// In en, this message translates to:
  /// **'Incorrect secret answer. Please try again.'**
  String get invalidAnswerError;

  /// Success message when PIN is reset
  ///
  /// In en, this message translates to:
  /// **'Security PIN reset successfully!'**
  String get pinResetSuccess;

  /// Prompt for entering new PIN during reset
  ///
  /// In en, this message translates to:
  /// **'Enter New 4-Digit PIN'**
  String get newPinHeader;

  /// Error toast message on invalid PIN
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get incorrectPinMessage;

  /// Generic confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// Generic cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Error text displayed when an operation fails
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// Sample transaction date
  ///
  /// In en, this message translates to:
  /// **'Jul 22, 2026'**
  String get jul22Date;

  /// Bottom nav item for overview
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Bottom nav item for activity
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// Bottom nav item for budgets
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// Bottom nav item for reports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Title for logging a transaction
  ///
  /// In en, this message translates to:
  /// **'Log Transaction'**
  String get logTransaction;

  /// Label for amount display
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amountLabel;

  /// Label for category field
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Label for payment method field
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodLabel;

  /// Card payment method
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentCard;

  /// Cash payment method
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// Account payment method
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get paymentAccount;

  /// Button to save transaction
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// Placeholder hint for searching transactions
  ///
  /// In en, this message translates to:
  /// **'Search by category or note...'**
  String get searchCategoryHint;

  /// Title for empty transactions state
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// Empty state message when no categories match search
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// Description for empty transactions state
  ///
  /// In en, this message translates to:
  /// **'Log a new expense or income to get started.'**
  String get noTransactionsDesc;

  /// Title for empty budgets state
  ///
  /// In en, this message translates to:
  /// **'No Budgets Set'**
  String get noBudgetsSet;

  /// Description for empty budgets state
  ///
  /// In en, this message translates to:
  /// **'Set monthly limits for categories to manage your spending smartly.'**
  String get noBudgetsDesc;

  /// Action button for setting first budget
  ///
  /// In en, this message translates to:
  /// **'Set First Budget'**
  String get setFirstBudget;

  /// Title for setting monthly budget modal
  ///
  /// In en, this message translates to:
  /// **'Set Monthly Budget'**
  String get setMonthlyBudget;

  /// Label for target monthly amount input
  ///
  /// In en, this message translates to:
  /// **'TARGET MONTHLY AMOUNT'**
  String get targetMonthlyAmount;

  /// Label for overall monthly limit chip
  ///
  /// In en, this message translates to:
  /// **'Overall Monthly Limit'**
  String get overallMonthlyLimit;

  /// Button text to save budget
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get saveBudget;

  /// Error message when budget target amount is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid target amount'**
  String get enterTargetAmountError;

  /// Label for net savings in reports
  ///
  /// In en, this message translates to:
  /// **'NET SAVINGS THIS PERIOD'**
  String get netSavingsThisPeriod;

  /// Section header for expense breakdown by category
  ///
  /// In en, this message translates to:
  /// **'EXPENSE BREAKDOWN BY CATEGORY'**
  String get expenseBreakdownByCategory;

  /// Label for savings rate stat
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get savingsRate;

  /// Title for empty reports state
  ///
  /// In en, this message translates to:
  /// **'No Financial Reports Yet'**
  String get noFinancialReportsYet;

  /// Description for empty reports state
  ///
  /// In en, this message translates to:
  /// **'Start logging transactions to view detailed spending breakdowns and cash flow insights.'**
  String get noReportsDesc;

  /// Welcome header on empty dashboard view
  ///
  /// In en, this message translates to:
  /// **'Welcome to your financial journey.'**
  String get welcomeFinancialJourney;

  /// Empty state subtitle on dashboard view
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t added any transactions yet. Let\'\'s start tracking your wealth today.'**
  String get emptyDashboardDesc;

  /// CTA button to add first transaction
  ///
  /// In en, this message translates to:
  /// **'Add Your First Transaction'**
  String get addFirstTransaction;

  /// Tooltip to show balances
  ///
  /// In en, this message translates to:
  /// **'Show Balances'**
  String get showBalances;

  /// Tooltip to hide balances
  ///
  /// In en, this message translates to:
  /// **'Hide Balances (Privacy Mode)'**
  String get hideBalances;

  /// Tooltip for settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for remaining monthly budget
  ///
  /// In en, this message translates to:
  /// **'REMAINING BUDGET'**
  String get remainingBudget;

  /// Error text when category is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategoryError;

  /// Error text when transaction amount is zero or invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterAmountError;

  /// Label for account transfer
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// Label for transfer fee
  ///
  /// In en, this message translates to:
  /// **'Transfer Fee (Optional)'**
  String get transferFee;

  /// Label for source payment type in transfer
  ///
  /// In en, this message translates to:
  /// **'From Payment Type'**
  String get fromAccount;

  /// Label for destination payment type in transfer
  ///
  /// In en, this message translates to:
  /// **'To Payment Type'**
  String get toAccount;

  /// Premium badge text
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium;

  /// Title for pro upgrade card
  ///
  /// In en, this message translates to:
  /// **'Go Pro for Unlimited Flow'**
  String get goProTitle;

  /// Description for pro upgrade card
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced analytics, multi-currency support, and cloud-sync across all your devices.'**
  String get goProDesc;

  /// Button text for upgrading to premium
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now — \$9.99/mo'**
  String get upgradeNow;

  /// Section header for account settings
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSection;

  /// Label for personal profile tile
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get personalProfile;

  /// Subtitle for personal profile tile
  ///
  /// In en, this message translates to:
  /// **'Manage your identity and bio'**
  String get personalProfileDesc;

  /// Label for subscription plan tile
  ///
  /// In en, this message translates to:
  /// **'Subscription Plan'**
  String get subscriptionPlan;

  /// Subtitle for subscription plan tile
  ///
  /// In en, this message translates to:
  /// **'Free Tier • Manage Billing'**
  String get subscriptionPlanDesc;

  /// Section header for security settings
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get securitySection;

  /// Label for biometric authentication setting
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuth;

  /// Reason shown in local_auth prompt
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access Expendly'**
  String get biometricReason;

  /// Error message when biometrics is unavailable
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available or enrolled on this device.'**
  String get biometricNotAvailable;

  /// Error message when biometric authentication fails
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed.'**
  String get biometricAuthFailed;

  /// Label for change PIN setting
  ///
  /// In en, this message translates to:
  /// **'Change Security PIN'**
  String get changeSecurityPin;

  /// Section header for appearance settings
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearanceSection;

  /// Label for theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// Value display for dark mode theme
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Value display for light mode theme
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Label for primary currency setting
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get primaryCurrency;

  /// Section header for data management settings
  ///
  /// In en, this message translates to:
  /// **'DATA MANAGEMENT'**
  String get dataManagementSection;

  /// Label for cloud backup setting
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// Status for last cloud backup
  ///
  /// In en, this message translates to:
  /// **'Last: Today 08:42'**
  String get cloudBackupLast;

  /// Label for exporting data as CSV
  ///
  /// In en, this message translates to:
  /// **'Share Transactions (.CSV)'**
  String get exportDataCsv;

  /// Label for clearing local cache
  ///
  /// In en, this message translates to:
  /// **'Clear Local Cache'**
  String get clearLocalCache;

  /// Footer tagline on settings screen
  ///
  /// In en, this message translates to:
  /// **'Made with precision for your financial peace.'**
  String get settingsFooterTagline;

  /// Label for exporting backup
  ///
  /// In en, this message translates to:
  /// **'Export Backup Data'**
  String get exportEncryptedData;

  /// Label for importing backup
  ///
  /// In en, this message translates to:
  /// **'Import Backup Data'**
  String get importEncryptedData;

  /// Subtitle for export data setting
  ///
  /// In en, this message translates to:
  /// **'Create a backup file'**
  String get exportEncryptedDataDesc;

  /// Subtitle for import data setting
  ///
  /// In en, this message translates to:
  /// **'Restore backup using encryption key or PIN'**
  String get importEncryptedDataDesc;

  /// Success message after export
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully!'**
  String get exportSuccess;

  /// Success message after import
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully!'**
  String get importSuccess;

  /// Success message after import, including how many transactions were restored
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully! {count, plural, =0{No transactions restored} =1{1 transaction restored} other{{count} transactions restored}}'**
  String importSuccessWithCount(int count);

  /// Summary line in the export success dialog describing the generated backup
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Backup generated with no transactions.} =1{Backup generated with 1 transaction.} other{Backup generated with {count} transactions.}}'**
  String exportBackupSummary(int count);

  /// Label above the file path of a generated backup
  ///
  /// In en, this message translates to:
  /// **'File saved at:'**
  String get fileSavedAt;

  /// Divider label between two alternative actions
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orSeparator;

  /// Toast message shown when a backup export fails
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get exportFailedGeneric;

  /// Label for passphrase input prompt
  ///
  /// In en, this message translates to:
  /// **'Passphrase / PIN (Optional)'**
  String get passphrasePrompt;

  /// Hint text for passphrase input
  ///
  /// In en, this message translates to:
  /// **'Enter PIN/key or leave empty for default'**
  String get passphraseHint;

  /// Label for payload import dialog textfield
  ///
  /// In en, this message translates to:
  /// **'Paste Encrypted Data Payload'**
  String get pasteEncryptedPayload;

  /// Account ID label with ID placeholder
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT ID: {id}'**
  String accountId(String id);

  /// Label for full name input field
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullNameLabel;

  /// Placeholder hint for full name input
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourNameHint;

  /// Validation message for missing name
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// Label for email address input field
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddressLabel;

  /// Placeholder hint for email input
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get emailHint;

  /// Label for professional bio input field
  ///
  /// In en, this message translates to:
  /// **'PROFESSIONAL BIO'**
  String get professionalBioLabel;

  /// Placeholder hint for professional bio input
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your financial focus...'**
  String get bioHint;

  /// Button label for saving changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Button label for discarding changes
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get discardChanges;

  /// Toast message when profile is saved
  ///
  /// In en, this message translates to:
  /// **'Personal profile saved successfully!'**
  String get profileSavedSuccess;

  /// Toast message when changes are discarded
  ///
  /// In en, this message translates to:
  /// **'Changes discarded'**
  String get changesDiscarded;

  /// Error message when photo selection fails
  ///
  /// In en, this message translates to:
  /// **'Failed to select photo: {error}'**
  String failedToSelectPhoto(String error);

  /// Error message when profile saving fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile: {error}'**
  String failedToSaveProfile(String error);

  /// Title for profile editing sheet
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Title for initial profile setup sheet
  ///
  /// In en, this message translates to:
  /// **'Set Up Profile'**
  String get setUpProfile;

  /// Instruction below avatar picker
  ///
  /// In en, this message translates to:
  /// **'Tap avatar to choose photo from gallery'**
  String get tapAvatarChoosePhoto;

  /// Title for account transfer option
  ///
  /// In en, this message translates to:
  /// **'Account Transfer'**
  String get accountTransfer;

  /// Description for export modal
  ///
  /// In en, this message translates to:
  /// **'Enter an optional PIN/passphrase to protect your backup.'**
  String get exportPromptDesc;

  /// Button to trigger encrypted export
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportEncryptButton;

  /// Button to copy encrypted export payload
  ///
  /// In en, this message translates to:
  /// **'Copy Encrypted Text'**
  String get copyEncryptedText;

  /// Generic done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Toast message when payload copied
  ///
  /// In en, this message translates to:
  /// **'Encrypted payload copied to clipboard!'**
  String get encryptedPayloadCopied;

  /// Hint text for pasting encrypted payload
  ///
  /// In en, this message translates to:
  /// **'Paste ivBase64:cipherTextBase64 here...'**
  String get pastePayloadHint;

  /// Validation error for missing payload
  ///
  /// In en, this message translates to:
  /// **'Please paste an encrypted payload.'**
  String get pleasePastePayload;

  /// Button to trigger payload decryption
  ///
  /// In en, this message translates to:
  /// **'Decrypt & Restore Data'**
  String get decryptRestoreData;

  /// Subtitle for CSV export option
  ///
  /// In en, this message translates to:
  /// **'Share your transactions data as a CSV file'**
  String get exportCsvDesc;

  /// Toast message for CSV export destination
  ///
  /// In en, this message translates to:
  /// **'CSV exported to {filename}'**
  String csvExportedTo(String filename);

  /// Toast message for CSV export error
  ///
  /// In en, this message translates to:
  /// **'CSV Export failed: {error}'**
  String csvExportFailed(String error);

  /// Toast message shown when a CSV export fails
  ///
  /// In en, this message translates to:
  /// **'CSV export failed. Please try again.'**
  String get csvExportFailedGeneric;

  /// Toast message for export error
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// Toast message for import error
  ///
  /// In en, this message translates to:
  /// **'Import failed: Invalid payload or decryption key.'**
  String get importFailedKey;

  /// Button label to import the most recent backup file from storage
  ///
  /// In en, this message translates to:
  /// **'Use Latest Backup File'**
  String get useLatestBackup;

  /// Helper text describing the latest backup import option
  ///
  /// In en, this message translates to:
  /// **'Restore the most recent backup from Download/Expendly'**
  String get useLatestBackupHint;

  /// Message shown when no backup file exists to import
  ///
  /// In en, this message translates to:
  /// **'No backup file found in Download/Expendly folder.'**
  String get noBackupFileFound;

  /// Inline error in the import sheet when the public Expendly folder exists but its backup files belong to a previous install and cannot be read
  ///
  /// In en, this message translates to:
  /// **'Your backup folder was found, but this install can no longer read the files inside it. Backups saved from now on will be restorable.'**
  String get backupFolderUnreadable;

  /// Message shown when the latest backup cannot be decrypted with the provided key
  ///
  /// In en, this message translates to:
  /// **'Enter the passphrase or Security PIN used for this backup.'**
  String get backupPassphraseNeeded;

  /// Title for the confirmation dialog before importing the latest backup
  ///
  /// In en, this message translates to:
  /// **'Restore From Backup?'**
  String get restoreFromBackupTitle;

  /// Confirmation message before restoring latest backup
  ///
  /// In en, this message translates to:
  /// **'This will replace all current data with \"{fileName}\" ({count} transactions, created {date}). This action cannot be undone. Continue?'**
  String restoreFromBackupMessage(String fileName, int count, String date);

  /// Confirm button label to proceed with restore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Label indicating a backup was created automatically
  ///
  /// In en, this message translates to:
  /// **'Auto backup'**
  String get autoBackupLabel;

  /// Label indicating a backup was created manually
  ///
  /// In en, this message translates to:
  /// **'Manual backup'**
  String get manualBackupLabel;

  /// Placeholder hint for transaction note
  ///
  /// In en, this message translates to:
  /// **'Add note (optional)...'**
  String get addNoteHint;

  /// Fallback label for source category
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// Fallback label for destination category
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// Button to create new budget
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// DatePicker header text on activity page
  ///
  /// In en, this message translates to:
  /// **'SELECT MONTH & YEAR'**
  String get selectMonthAndYear;

  /// Tooltip for calendar view mode
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get calendarView;

  /// Tooltip for list view mode
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// Tooltip to reset date range filter
  ///
  /// In en, this message translates to:
  /// **'Clear Date Filter'**
  String get clearDateFilter;

  /// Default label when date range is empty
  ///
  /// In en, this message translates to:
  /// **'Filter by Date Range (All Time)'**
  String get filterByDateRangeAllTime;

  /// Empty state message for selected single date
  ///
  /// In en, this message translates to:
  /// **'No transactions on {date}'**
  String noTransactionsOnDate(String date);

  /// Empty state message for selected date range
  ///
  /// In en, this message translates to:
  /// **'No transactions found in selected date range'**
  String get noTransactionsInDateRange;

  /// Header text showing count of transactions on a date
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Transaction} other{{count} Transactions}}'**
  String transactionsCount(int count);

  /// Page title for transaction details screen
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// Label for transaction type field
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// Label for date and time field
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTimeLabel;

  /// Label for note field
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// Label for transaction ID field
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionIdLabel;

  /// Button label to delete a transaction
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// Title for delete transaction confirmation modal
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get deleteTransactionConfirmTitle;

  /// Description for delete transaction confirmation modal
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This action cannot be undone.'**
  String get deleteTransactionConfirmDesc;

  /// Toast message when transaction is deleted
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeletedSuccess;

  /// Label for card payment method
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardPaymentMethod;

  /// Label for cash payment method
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashPaymentMethod;

  /// Label for bank account payment method
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get accountPaymentMethod;

  /// Generic confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title for change security PIN modal
  ///
  /// In en, this message translates to:
  /// **'Change Security PIN'**
  String get changeSecurityPinTitle;

  /// Instruction prompt for entering current PIN
  ///
  /// In en, this message translates to:
  /// **'Enter Current PIN'**
  String get enterCurrentPin;

  /// Instruction prompt for entering new PIN
  ///
  /// In en, this message translates to:
  /// **'Enter New 4-Digit PIN'**
  String get enterNewPin;

  /// Instruction prompt for confirming new PIN
  ///
  /// In en, this message translates to:
  /// **'Confirm New 4-Digit PIN'**
  String get confirmNewPin;

  /// Toast message for wrong current PIN
  ///
  /// In en, this message translates to:
  /// **'Incorrect current PIN. Please try again.'**
  String get incorrectCurrentPin;

  /// Toast message when new PIN and confirmation PIN mismatch
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Please try again.'**
  String get pinsDoNotMatch;

  /// Toast message when PIN is updated successfully
  ///
  /// In en, this message translates to:
  /// **'Security PIN updated successfully'**
  String get pinChangedSuccess;

  /// Settings section header for support and legal options
  ///
  /// In en, this message translates to:
  /// **'SUPPORT & LEGAL'**
  String get supportAndLegalSection;

  /// Menu title for About page
  ///
  /// In en, this message translates to:
  /// **'About Expendly'**
  String get aboutExpendly;

  /// Subtitle for About page menu item
  ///
  /// In en, this message translates to:
  /// **'Version 1.1.2'**
  String get aboutExpendlySubtitle;

  /// Menu title for Terms & Conditions page
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Subtitle for Terms & Conditions menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy policy, data ownership, & terms of service'**
  String get termsDesc;

  /// Menu title for Help & Support page
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Subtitle for Help & Support menu item
  ///
  /// In en, this message translates to:
  /// **'FAQs, troubleshooting, & contact info'**
  String get helpSupportDesc;

  /// Section header for FAQs
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// FAQ 1 Question
  ///
  /// In en, this message translates to:
  /// **'Is my financial data uploaded to any cloud server?'**
  String get faq1Q;

  /// FAQ 1 Answer
  ///
  /// In en, this message translates to:
  /// **'No. Expendly is 100% offline-first. All data, transactions, and settings reside exclusively on your device.'**
  String get faq1A;

  /// FAQ 2 Question
  ///
  /// In en, this message translates to:
  /// **'How do I backup or transfer my data?'**
  String get faq2Q;

  /// FAQ 2 Answer
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Data Management. You can export an encrypted payload or CSV file, and restore it anytime using your passphrase.'**
  String get faq2A;

  /// FAQ 3 Question
  ///
  /// In en, this message translates to:
  /// **'What happens if I forget my security PIN?'**
  String get faq3Q;

  /// FAQ 3 Answer
  ///
  /// In en, this message translates to:
  /// **'You can reset your PIN using your security recovery questions setup during onboarding.'**
  String get faq3A;

  /// FAQ 4 Question
  ///
  /// In en, this message translates to:
  /// **'How do I change my primary currency?'**
  String get faq4Q;

  /// FAQ 4 Answer
  ///
  /// In en, this message translates to:
  /// **'Your primary currency display can be configured in Settings > Appearance > Primary Currency.'**
  String get faq4A;

  /// Terms Section 1 Title
  ///
  /// In en, this message translates to:
  /// **'1. Local Data Ownership'**
  String get termsTitle1;

  /// Terms Section 1 Body
  ///
  /// In en, this message translates to:
  /// **'Expendly does not collect, transmit, or monetize your personal financial records. All databases and preferences are stored locally on your device.'**
  String get termsBody1;

  /// Terms Section 2 Title
  ///
  /// In en, this message translates to:
  /// **'2. Security & Privacy'**
  String get termsTitle2;

  /// Terms Section 2 Body
  ///
  /// In en, this message translates to:
  /// **'Security PINs and preferences are stored securely on your device using Android & iOS secure storage.'**
  String get termsBody2;

  /// Terms Section 3 Title
  ///
  /// In en, this message translates to:
  /// **'3. User Backup Responsibility'**
  String get termsTitle3;

  /// Terms Section 3 Body
  ///
  /// In en, this message translates to:
  /// **'Because Expendly has zero server backends, you are responsible for maintaining backups of your ledger when switching devices.'**
  String get termsBody3;

  /// Terms Section 4 Title
  ///
  /// In en, this message translates to:
  /// **'4. Disclaimer & Liability'**
  String get termsTitle4;

  /// Terms Section 4 Body
  ///
  /// In en, this message translates to:
  /// **'The app is provided \'as is\' without warranty. The developers are not liable for lost data resulting from hardware failure, un-backed up device wipes, or forgotten PINs.'**
  String get termsBody4;

  /// Header title for help and support inquiry form
  ///
  /// In en, this message translates to:
  /// **'Have a Question or Feedback?'**
  String get askQuestionTitle;

  /// Subheading description for support inquiry form
  ///
  /// In en, this message translates to:
  /// **'Type your question or feedback below. Submitting will prepare your message and launch your default email client.'**
  String get askQuestionDesc;

  /// Placeholder hint for support question input
  ///
  /// In en, this message translates to:
  /// **'Type your question or feedback in detail...'**
  String get questionHint;

  /// Button label to submit question via email
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendQuestion;

  /// Toast error when question field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your question before submitting.'**
  String get emptyQuestionError;

  /// Label for logging out
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// Subtitle for logout tile in settings
  ///
  /// In en, this message translates to:
  /// **'Lock session with Security PIN'**
  String get logoutSubtitle;

  /// Title for logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Log Out of Expendly?'**
  String get logoutConfirmTitle;

  /// Message for logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? Your session will be locked and will require your Security PIN or Biometrics to unlock.'**
  String get logoutConfirmMessage;

  /// Error toast when user attempts logout without a PIN configured
  ///
  /// In en, this message translates to:
  /// **'Security PIN is not set up. Please create a PIN in settings first.'**
  String get noSecurityPinForLogout;

  /// Title for setting up security PIN
  ///
  /// In en, this message translates to:
  /// **'Set Security PIN'**
  String get setupSecurityPin;

  /// Subtitle for setting up security PIN
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN to secure your app'**
  String get setupSecurityPinDesc;

  /// Subtitle when security PIN is already set up
  ///
  /// In en, this message translates to:
  /// **'Security PIN is configured'**
  String get pinConfigured;

  /// Toast message when enabling biometrics without a PIN configured
  ///
  /// In en, this message translates to:
  /// **'Please set up a Security PIN first before enabling Biometric Auth.'**
  String get pinRequiredForBiometrics;

  /// Label for auto backup switch on account setup page
  ///
  /// In en, this message translates to:
  /// **'Allow Auto Backup'**
  String get allowAutoBackup;

  /// Subtitle for auto backup switch on account setup page
  ///
  /// In en, this message translates to:
  /// **'Automatically snapshot ledger. Requires Security PIN.'**
  String get autoBackupSetupDesc;

  /// Title for auto backup tile in settings
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackupTileTitle;

  /// Subtitle for auto backup tile in settings
  ///
  /// In en, this message translates to:
  /// **'Automatically snapshot ledger on changes'**
  String get autoBackupTileDesc;

  /// Toast message when enabling auto backup without a PIN configured
  ///
  /// In en, this message translates to:
  /// **'Security PIN is required when Auto Backup is enabled.'**
  String get pinRequiredForAutoBackup;

  /// Subtitle note on security setup screen when auto backup is active
  ///
  /// In en, this message translates to:
  /// **'Security PIN is required for auto backup.'**
  String get pinCompulsoryForBackup;

  /// Header label for system backup notifications
  ///
  /// In en, this message translates to:
  /// **'SYSTEM BACKUP'**
  String get systemBackupHeader;

  /// Title for the CSV auto-backup status tile in Data Management
  ///
  /// In en, this message translates to:
  /// **'Auto Backup (CSV)'**
  String get csvBackupTitle;

  /// Button label to trigger an immediate manual backup
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// Subtitle when no backup has been created yet
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get neverBackedUp;

  /// Subtitle showing the timestamp of the last successful backup
  ///
  /// In en, this message translates to:
  /// **'Last backup: {time}'**
  String lastBackupTime(String time);

  /// Toast shown after a successful manual backup
  ///
  /// In en, this message translates to:
  /// **'Backup saved to Downloads/Expendly'**
  String get backupSuccess;

  /// Toast shown when a backup attempt fails
  ///
  /// In en, this message translates to:
  /// **'Backup failed. Please try again.'**
  String get backupFailed;

  /// Title for the CSV restore tile and bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreCsvTitle;

  /// Subtitle for the CSV restore tile in Data Management
  ///
  /// In en, this message translates to:
  /// **'Import your expendly_backup file to recover your data'**
  String get restoreCsvDesc;

  /// Message shown in restore sheet when backup file does not exist
  ///
  /// In en, this message translates to:
  /// **'No backup file found. Create a backup first, or use \'Browse\' to select a CSV file from another location.'**
  String get backupFileNotFound;

  /// Label/instruction shown above the PIN field in the CSV restore sheet
  ///
  /// In en, this message translates to:
  /// **'Enter your Security PIN to authorize the restore.'**
  String get pinRequiredForRestore;

  /// Error shown in the restore sheet when the entered PIN does not match
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get pinIncorrect;

  /// Label for the PIN text field in the restore sheet
  ///
  /// In en, this message translates to:
  /// **'Security PIN'**
  String get enterPin;

  /// Error shown when CSV import fails
  ///
  /// In en, this message translates to:
  /// **'Restore failed. The file may be invalid or corrupted.'**
  String get csvImportFailed;

  /// Button label to open the system file picker for a CSV backup
  ///
  /// In en, this message translates to:
  /// **'Browse & Select Backup File'**
  String get browseBackupFile;

  /// Title of the dialog shown after a successful CSV import
  ///
  /// In en, this message translates to:
  /// **'Restore Complete'**
  String get importSummaryTitle;

  /// Body of the import summary dialog
  ///
  /// In en, this message translates to:
  /// **'Imported {transactions} transactions, {categories} categories, {budgets} budgets.'**
  String importSummaryBody(int transactions, int categories, int budgets);

  /// Header label for general notifications
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATION'**
  String get notificationHeader;

  /// Default title when notification title is missing
  ///
  /// In en, this message translates to:
  /// **'Notification Alert'**
  String get notificationAlert;

  /// Fallback text when notification body is empty
  ///
  /// In en, this message translates to:
  /// **'No detailed body text provided.'**
  String get noNotificationBody;

  /// Button label to copy notification text
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get copyText;

  /// Toast message when notification text is copied
  ///
  /// In en, this message translates to:
  /// **'Content copied to clipboard'**
  String get contentCopied;

  /// Confirmation button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Groups tab navigation label
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Title for shared events page
  ///
  /// In en, this message translates to:
  /// **'Shared Events'**
  String get sharedEvents;

  /// Button to create a new event
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get newEvent;

  /// Title for event creation page
  ///
  /// In en, this message translates to:
  /// **'Create a new event'**
  String get createNewEvent;

  /// Label for event name input
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get eventName;

  /// Label for category selector
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Label for participants section
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// Button to create event
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// Title for editing event
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// Trip category
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// Dinner category
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// Home category
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Party category
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get party;

  /// Message when participant is added
  ///
  /// In en, this message translates to:
  /// **'Participant Added'**
  String get participantAdded;

  /// Label for event owner
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// Button to add participant
  ///
  /// In en, this message translates to:
  /// **'Add Participant'**
  String get addParticipant;

  /// Button to remove participant
  ///
  /// In en, this message translates to:
  /// **'Remove Participant'**
  String get removeParticipant;

  /// Badge showing number of participants added
  ///
  /// In en, this message translates to:
  /// **'{count} Added'**
  String nAdded(int count);

  /// Label for total event spend
  ///
  /// In en, this message translates to:
  /// **'Total Spend'**
  String get totalSpend;

  /// Balances tab label
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get balances;

  /// Label showing who paid an expense
  ///
  /// In en, this message translates to:
  /// **'Paid by {name}'**
  String paidBy(String name);

  /// Label showing number of split shares
  ///
  /// In en, this message translates to:
  /// **'{count} shares'**
  String nShares(int count);

  /// Label for expense amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Label for expense description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Header for splitting expense
  ///
  /// In en, this message translates to:
  /// **'SPLIT AMONG'**
  String get splitAmong;

  /// Toggle for splitting equally
  ///
  /// In en, this message translates to:
  /// **'Equally'**
  String get equally;

  /// Button to save expense
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// Label for net balances position
  ///
  /// In en, this message translates to:
  /// **'Net Position'**
  String get netPosition;

  /// Label showing amount owed to user
  ///
  /// In en, this message translates to:
  /// **'You are owed {amount}'**
  String youAreOwed(String amount);

  /// Label showing amount user owes
  ///
  /// In en, this message translates to:
  /// **'You owe {amount}'**
  String youOwe(String amount);

  /// Label showing someone owes user
  ///
  /// In en, this message translates to:
  /// **'{name} owes you'**
  String owesYou(String name);

  /// Label showing user owes someone
  ///
  /// In en, this message translates to:
  /// **'You owe {name}'**
  String youOweText(String name);

  /// Button to mark settlement as paid
  ///
  /// In en, this message translates to:
  /// **'Settle Up'**
  String get settleUp;

  /// Button to send reminder
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get remind;

  /// Title for export page
  ///
  /// In en, this message translates to:
  /// **'Export & Settle'**
  String get exportAndSettle;

  /// Header for settlement summary
  ///
  /// In en, this message translates to:
  /// **'SETTLEMENT SUMMARY'**
  String get settlementSummary;

  /// Label for total expense in summary
  ///
  /// In en, this message translates to:
  /// **'TOTAL EXPENSE'**
  String get totalExpense;

  /// Label for user share in summary
  ///
  /// In en, this message translates to:
  /// **'YOUR SHARE'**
  String get yourShare;

  /// Header for debts list
  ///
  /// In en, this message translates to:
  /// **'DEBTS TO BE CLEARED'**
  String get debtsToCleared;

  /// Button to export CSV
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCsv;

  /// Button to send email
  ///
  /// In en, this message translates to:
  /// **'Send via Email'**
  String get sendViaEmail;

  /// Badge for pending settlements
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String nPending(int count);

  /// Active status badge
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// Settled status badge
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get settled;

  /// Recurring status badge
  ///
  /// In en, this message translates to:
  /// **'RECURRING'**
  String get recurring;

  /// Toast for event creation
  ///
  /// In en, this message translates to:
  /// **'Event created successfully'**
  String get eventCreatedSuccess;

  /// Toast for event update
  ///
  /// In en, this message translates to:
  /// **'Event updated successfully'**
  String get eventUpdatedSuccess;

  /// Toast for event deletion
  ///
  /// In en, this message translates to:
  /// **'Event deleted successfully'**
  String get eventDeletedSuccess;

  /// Toast for event settlement
  ///
  /// In en, this message translates to:
  /// **'Event marked as settled'**
  String get eventSettledSuccess;

  /// Toast for expense added
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenseAddedSuccess;

  /// Toast for expense deletion
  ///
  /// In en, this message translates to:
  /// **'Expense deleted successfully'**
  String get expenseDeletedSuccess;

  /// Toast for failed operation
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get operationFailed;

  /// Title for delete event confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete Event?'**
  String get deleteEventConfirmTitle;

  /// Message for delete event confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this event? This action cannot be undone.'**
  String get deleteEventConfirmMessage;

  /// Title for delete expense confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete Expense?'**
  String get deleteExpenseConfirmTitle;

  /// Message for delete expense confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseConfirmMessage;

  /// Label for members count
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// Title for empty events list
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// Title for empty expenses list
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// Button for empty events list
  ///
  /// In en, this message translates to:
  /// **'Create First Event'**
  String get createFirstEvent;

  /// Header or label for splitting bill
  ///
  /// In en, this message translates to:
  /// **'Split Bill'**
  String get splitBill;

  /// Header for balances view selector
  ///
  /// In en, this message translates to:
  /// **'View balances for'**
  String get viewBalancesFor;

  /// Title for group expense details screen
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get expenseDetails;

  /// Header for split breakdown section
  ///
  /// In en, this message translates to:
  /// **'SPLIT BREAKDOWN'**
  String get splitBreakdown;

  /// Button to delete an expense
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
