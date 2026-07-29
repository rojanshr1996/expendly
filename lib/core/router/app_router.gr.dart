// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i17;
import 'package:expendly/features/budgets/presentation/pages/create_new_budget_page.dart'
    as _i3;
import 'package:expendly/features/dashboard/presentation/pages/dashboard_page.dart'
    as _i5;
import 'package:expendly/features/onboarding/presentation/pages/account_setup_page.dart'
    as _i2;
import 'package:expendly/features/onboarding/presentation/pages/currency_setup_page.dart'
    as _i4;
import 'package:expendly/features/onboarding/presentation/pages/final_setup_page.dart'
    as _i6;
import 'package:expendly/features/onboarding/presentation/pages/onboarding_carousel_page.dart'
    as _i9;
import 'package:expendly/features/onboarding/presentation/pages/onboarding_security_setup_page.dart'
    as _i10;
import 'package:expendly/features/profile/presentation/pages/personal_profile_page.dart'
    as _i11;
import 'package:expendly/features/security/presentation/pages/security_verification_page.dart'
    as _i12;
import 'package:expendly/features/settings/presentation/pages/about_page.dart'
    as _i1;
import 'package:expendly/features/settings/presentation/pages/help_support_page.dart'
    as _i7;
import 'package:expendly/features/settings/presentation/pages/settings_page.dart'
    as _i13;
import 'package:expendly/features/settings/presentation/pages/terms_conditions_page.dart'
    as _i15;
import 'package:expendly/features/splash/presentation/pages/splash_page.dart'
    as _i14;
import 'package:expendly/features/transactions/domain/entities/transaction_item.dart'
    as _i19;
import 'package:expendly/features/transactions/presentation/pages/modern_add_transaction_page.dart'
    as _i8;
import 'package:expendly/features/transactions/presentation/pages/transaction_details_page.dart'
    as _i16;
import 'package:flutter/material.dart' as _i18;

abstract class $AppRouter extends _i17.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i17.PageFactory> pagesMap = {
    AboutRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AboutPage(),
      );
    },
    AccountSetupRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AccountSetupPage(),
      );
    },
    CreateNewBudgetRoute.name: (routeData) {
      final args = routeData.argsAs<CreateNewBudgetRouteArgs>(
          orElse: () => const CreateNewBudgetRouteArgs());
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.CreateNewBudgetPage(
          key: args.key,
          onSaved: args.onSaved,
        ),
      );
    },
    CurrencySetupRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.CurrencySetupPage(),
      );
    },
    DashboardRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.DashboardPage(),
      );
    },
    FinalSetupRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.FinalSetupPage(),
      );
    },
    HelpSupportRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.HelpSupportPage(),
      );
    },
    ModernAddTransactionRoute.name: (routeData) {
      final args = routeData.argsAs<ModernAddTransactionRouteArgs>(
          orElse: () => const ModernAddTransactionRouteArgs());
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.ModernAddTransactionPage(
          key: args.key,
          initialTransaction: args.initialTransaction,
        ),
      );
    },
    OnboardingCarouselRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.OnboardingCarouselPage(),
      );
    },
    OnboardingSecuritySetupRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.OnboardingSecuritySetupPage(),
      );
    },
    PersonalProfileRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.PersonalProfilePage(),
      );
    },
    SecurityVerificationRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.SecurityVerificationPage(),
      );
    },
    SettingsRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.SettingsPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.SplashPage(),
      );
    },
    TermsConditionsRoute.name: (routeData) {
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.TermsConditionsPage(),
      );
    },
    TransactionDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<TransactionDetailsRouteArgs>();
      return _i17.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i16.TransactionDetailsPage(
          key: args.key,
          transaction: args.transaction,
          isPrivacyModeNotifier: args.isPrivacyModeNotifier,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.AboutPage]
class AboutRoute extends _i17.PageRouteInfo<void> {
  const AboutRoute({List<_i17.PageRouteInfo>? children})
      : super(
          AboutRoute.name,
          initialChildren: children,
        );

  static const String name = 'AboutRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AccountSetupPage]
class AccountSetupRoute extends _i17.PageRouteInfo<void> {
  const AccountSetupRoute({List<_i17.PageRouteInfo>? children})
      : super(
          AccountSetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountSetupRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CreateNewBudgetPage]
class CreateNewBudgetRoute
    extends _i17.PageRouteInfo<CreateNewBudgetRouteArgs> {
  CreateNewBudgetRoute({
    _i18.Key? key,
    void Function()? onSaved,
    List<_i17.PageRouteInfo>? children,
  }) : super(
          CreateNewBudgetRoute.name,
          args: CreateNewBudgetRouteArgs(
            key: key,
            onSaved: onSaved,
          ),
          initialChildren: children,
        );

  static const String name = 'CreateNewBudgetRoute';

  static const _i17.PageInfo<CreateNewBudgetRouteArgs> page =
      _i17.PageInfo<CreateNewBudgetRouteArgs>(name);
}

class CreateNewBudgetRouteArgs {
  const CreateNewBudgetRouteArgs({
    this.key,
    this.onSaved,
  });

  final _i18.Key? key;

  final void Function()? onSaved;

  @override
  String toString() {
    return 'CreateNewBudgetRouteArgs{key: $key, onSaved: $onSaved}';
  }
}

/// generated route for
/// [_i4.CurrencySetupPage]
class CurrencySetupRoute extends _i17.PageRouteInfo<void> {
  const CurrencySetupRoute({List<_i17.PageRouteInfo>? children})
      : super(
          CurrencySetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'CurrencySetupRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i5.DashboardPage]
class DashboardRoute extends _i17.PageRouteInfo<void> {
  const DashboardRoute({List<_i17.PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i6.FinalSetupPage]
class FinalSetupRoute extends _i17.PageRouteInfo<void> {
  const FinalSetupRoute({List<_i17.PageRouteInfo>? children})
      : super(
          FinalSetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'FinalSetupRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i7.HelpSupportPage]
class HelpSupportRoute extends _i17.PageRouteInfo<void> {
  const HelpSupportRoute({List<_i17.PageRouteInfo>? children})
      : super(
          HelpSupportRoute.name,
          initialChildren: children,
        );

  static const String name = 'HelpSupportRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i8.ModernAddTransactionPage]
class ModernAddTransactionRoute
    extends _i17.PageRouteInfo<ModernAddTransactionRouteArgs> {
  ModernAddTransactionRoute({
    _i18.Key? key,
    _i19.TransactionItem? initialTransaction,
    List<_i17.PageRouteInfo>? children,
  }) : super(
          ModernAddTransactionRoute.name,
          args: ModernAddTransactionRouteArgs(
            key: key,
            initialTransaction: initialTransaction,
          ),
          initialChildren: children,
        );

  static const String name = 'ModernAddTransactionRoute';

  static const _i17.PageInfo<ModernAddTransactionRouteArgs> page =
      _i17.PageInfo<ModernAddTransactionRouteArgs>(name);
}

class ModernAddTransactionRouteArgs {
  const ModernAddTransactionRouteArgs({
    this.key,
    this.initialTransaction,
  });

  final _i18.Key? key;

  final _i19.TransactionItem? initialTransaction;

  @override
  String toString() {
    return 'ModernAddTransactionRouteArgs{key: $key, initialTransaction: $initialTransaction}';
  }
}

/// generated route for
/// [_i9.OnboardingCarouselPage]
class OnboardingCarouselRoute extends _i17.PageRouteInfo<void> {
  const OnboardingCarouselRoute({List<_i17.PageRouteInfo>? children})
      : super(
          OnboardingCarouselRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingCarouselRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i10.OnboardingSecuritySetupPage]
class OnboardingSecuritySetupRoute extends _i17.PageRouteInfo<void> {
  const OnboardingSecuritySetupRoute({List<_i17.PageRouteInfo>? children})
      : super(
          OnboardingSecuritySetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingSecuritySetupRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i11.PersonalProfilePage]
class PersonalProfileRoute extends _i17.PageRouteInfo<void> {
  const PersonalProfileRoute({List<_i17.PageRouteInfo>? children})
      : super(
          PersonalProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'PersonalProfileRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i12.SecurityVerificationPage]
class SecurityVerificationRoute extends _i17.PageRouteInfo<void> {
  const SecurityVerificationRoute({List<_i17.PageRouteInfo>? children})
      : super(
          SecurityVerificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'SecurityVerificationRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i13.SettingsPage]
class SettingsRoute extends _i17.PageRouteInfo<void> {
  const SettingsRoute({List<_i17.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i14.SplashPage]
class SplashRoute extends _i17.PageRouteInfo<void> {
  const SplashRoute({List<_i17.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i15.TermsConditionsPage]
class TermsConditionsRoute extends _i17.PageRouteInfo<void> {
  const TermsConditionsRoute({List<_i17.PageRouteInfo>? children})
      : super(
          TermsConditionsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TermsConditionsRoute';

  static const _i17.PageInfo<void> page = _i17.PageInfo<void>(name);
}

/// generated route for
/// [_i16.TransactionDetailsPage]
class TransactionDetailsRoute
    extends _i17.PageRouteInfo<TransactionDetailsRouteArgs> {
  TransactionDetailsRoute({
    _i18.Key? key,
    required _i19.TransactionItem transaction,
    _i18.ValueNotifier<bool>? isPrivacyModeNotifier,
    List<_i17.PageRouteInfo>? children,
  }) : super(
          TransactionDetailsRoute.name,
          args: TransactionDetailsRouteArgs(
            key: key,
            transaction: transaction,
            isPrivacyModeNotifier: isPrivacyModeNotifier,
          ),
          initialChildren: children,
        );

  static const String name = 'TransactionDetailsRoute';

  static const _i17.PageInfo<TransactionDetailsRouteArgs> page =
      _i17.PageInfo<TransactionDetailsRouteArgs>(name);
}

class TransactionDetailsRouteArgs {
  const TransactionDetailsRouteArgs({
    this.key,
    required this.transaction,
    this.isPrivacyModeNotifier,
  });

  final _i18.Key? key;

  final _i19.TransactionItem transaction;

  final _i18.ValueNotifier<bool>? isPrivacyModeNotifier;

  @override
  String toString() {
    return 'TransactionDetailsRouteArgs{key: $key, transaction: $transaction, isPrivacyModeNotifier: $isPrivacyModeNotifier}';
  }
}
