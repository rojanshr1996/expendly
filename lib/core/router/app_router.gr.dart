// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:expendly/features/budgets/presentation/pages/create_new_budget_page.dart'
    as _i2;
import 'package:expendly/features/dashboard/presentation/pages/dashboard_page.dart'
    as _i4;
import 'package:expendly/features/onboarding/presentation/pages/account_setup_page.dart'
    as _i1;
import 'package:expendly/features/onboarding/presentation/pages/currency_setup_page.dart'
    as _i3;
import 'package:expendly/features/onboarding/presentation/pages/final_setup_page.dart'
    as _i5;
import 'package:expendly/features/onboarding/presentation/pages/onboarding_carousel_page.dart'
    as _i7;
import 'package:expendly/features/onboarding/presentation/pages/onboarding_security_setup_page.dart'
    as _i8;
import 'package:expendly/features/profile/presentation/pages/personal_profile_page.dart'
    as _i9;
import 'package:expendly/features/security/presentation/pages/security_verification_page.dart'
    as _i10;
import 'package:expendly/features/settings/presentation/pages/settings_page.dart'
    as _i11;
import 'package:expendly/features/splash/presentation/pages/splash_page.dart'
    as _i12;
import 'package:expendly/features/transactions/presentation/pages/modern_add_transaction_page.dart'
    as _i6;
import 'package:flutter/material.dart' as _i14;

abstract class $AppRouter extends _i13.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i13.PageFactory> pagesMap = {
    AccountSetupRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AccountSetupPage(),
      );
    },
    CreateNewBudgetRoute.name: (routeData) {
      final args = routeData.argsAs<CreateNewBudgetRouteArgs>(
          orElse: () => const CreateNewBudgetRouteArgs());
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.CreateNewBudgetPage(
          key: args.key,
          onSaved: args.onSaved,
        ),
      );
    },
    CurrencySetupRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.CurrencySetupPage(),
      );
    },
    DashboardRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.DashboardPage(),
      );
    },
    FinalSetupRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.FinalSetupPage(),
      );
    },
    ModernAddTransactionRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.ModernAddTransactionPage(),
      );
    },
    OnboardingCarouselRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.OnboardingCarouselPage(),
      );
    },
    OnboardingSecuritySetupRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.OnboardingSecuritySetupPage(),
      );
    },
    PersonalProfileRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.PersonalProfilePage(),
      );
    },
    SecurityVerificationRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.SecurityVerificationPage(),
      );
    },
    SettingsRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.SettingsPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.SplashPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AccountSetupPage]
class AccountSetupRoute extends _i13.PageRouteInfo<void> {
  const AccountSetupRoute({List<_i13.PageRouteInfo>? children})
      : super(
          AccountSetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountSetupRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i2.CreateNewBudgetPage]
class CreateNewBudgetRoute
    extends _i13.PageRouteInfo<CreateNewBudgetRouteArgs> {
  CreateNewBudgetRoute({
    _i14.Key? key,
    void Function()? onSaved,
    List<_i13.PageRouteInfo>? children,
  }) : super(
          CreateNewBudgetRoute.name,
          args: CreateNewBudgetRouteArgs(
            key: key,
            onSaved: onSaved,
          ),
          initialChildren: children,
        );

  static const String name = 'CreateNewBudgetRoute';

  static const _i13.PageInfo<CreateNewBudgetRouteArgs> page =
      _i13.PageInfo<CreateNewBudgetRouteArgs>(name);
}

class CreateNewBudgetRouteArgs {
  const CreateNewBudgetRouteArgs({
    this.key,
    this.onSaved,
  });

  final _i14.Key? key;

  final void Function()? onSaved;

  @override
  String toString() {
    return 'CreateNewBudgetRouteArgs{key: $key, onSaved: $onSaved}';
  }
}

/// generated route for
/// [_i3.CurrencySetupPage]
class CurrencySetupRoute extends _i13.PageRouteInfo<void> {
  const CurrencySetupRoute({List<_i13.PageRouteInfo>? children})
      : super(
          CurrencySetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'CurrencySetupRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i4.DashboardPage]
class DashboardRoute extends _i13.PageRouteInfo<void> {
  const DashboardRoute({List<_i13.PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i5.FinalSetupPage]
class FinalSetupRoute extends _i13.PageRouteInfo<void> {
  const FinalSetupRoute({List<_i13.PageRouteInfo>? children})
      : super(
          FinalSetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'FinalSetupRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i6.ModernAddTransactionPage]
class ModernAddTransactionRoute extends _i13.PageRouteInfo<void> {
  const ModernAddTransactionRoute({List<_i13.PageRouteInfo>? children})
      : super(
          ModernAddTransactionRoute.name,
          initialChildren: children,
        );

  static const String name = 'ModernAddTransactionRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i7.OnboardingCarouselPage]
class OnboardingCarouselRoute extends _i13.PageRouteInfo<void> {
  const OnboardingCarouselRoute({List<_i13.PageRouteInfo>? children})
      : super(
          OnboardingCarouselRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingCarouselRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i8.OnboardingSecuritySetupPage]
class OnboardingSecuritySetupRoute extends _i13.PageRouteInfo<void> {
  const OnboardingSecuritySetupRoute({List<_i13.PageRouteInfo>? children})
      : super(
          OnboardingSecuritySetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingSecuritySetupRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i9.PersonalProfilePage]
class PersonalProfileRoute extends _i13.PageRouteInfo<void> {
  const PersonalProfileRoute({List<_i13.PageRouteInfo>? children})
      : super(
          PersonalProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'PersonalProfileRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i10.SecurityVerificationPage]
class SecurityVerificationRoute extends _i13.PageRouteInfo<void> {
  const SecurityVerificationRoute({List<_i13.PageRouteInfo>? children})
      : super(
          SecurityVerificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'SecurityVerificationRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i11.SettingsPage]
class SettingsRoute extends _i13.PageRouteInfo<void> {
  const SettingsRoute({List<_i13.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i12.SplashPage]
class SplashRoute extends _i13.PageRouteInfo<void> {
  const SplashRoute({List<_i13.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}
