// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:expendly/features/dashboard/presentation/pages/dashboard_page.dart'
    as _i3;
import 'package:expendly/features/onboarding/presentation/pages/account_setup_page.dart'
    as _i1;
import 'package:expendly/features/onboarding/presentation/pages/currency_setup_page.dart'
    as _i2;
import 'package:expendly/features/onboarding/presentation/pages/final_setup_page.dart'
    as _i4;
import 'package:expendly/features/onboarding/presentation/pages/onboarding_carousel_page.dart'
    as _i5;
import 'package:expendly/features/onboarding/presentation/pages/onboarding_security_setup_page.dart'
    as _i6;
import 'package:expendly/features/security/presentation/pages/security_verification_page.dart'
    as _i7;
import 'package:expendly/features/splash/presentation/pages/splash_page.dart'
    as _i8;

abstract class $AppRouter extends _i9.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    AccountSetupRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AccountSetupPage(),
      );
    },
    CurrencySetupRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.CurrencySetupPage(),
      );
    },
    DashboardRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.DashboardPage(),
      );
    },
    FinalSetupRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.FinalSetupPage(),
      );
    },
    OnboardingCarouselRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.OnboardingCarouselPage(),
      );
    },
    OnboardingSecuritySetupRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.OnboardingSecuritySetupPage(),
      );
    },
    SecurityVerificationRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.SecurityVerificationPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.SplashPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AccountSetupPage]
class AccountSetupRoute extends _i9.PageRouteInfo<void> {
  const AccountSetupRoute({List<_i9.PageRouteInfo>? children})
      : super(
          AccountSetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountSetupRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i2.CurrencySetupPage]
class CurrencySetupRoute extends _i9.PageRouteInfo<void> {
  const CurrencySetupRoute({List<_i9.PageRouteInfo>? children})
      : super(
          CurrencySetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'CurrencySetupRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i3.DashboardPage]
class DashboardRoute extends _i9.PageRouteInfo<void> {
  const DashboardRoute({List<_i9.PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i4.FinalSetupPage]
class FinalSetupRoute extends _i9.PageRouteInfo<void> {
  const FinalSetupRoute({List<_i9.PageRouteInfo>? children})
      : super(
          FinalSetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'FinalSetupRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i5.OnboardingCarouselPage]
class OnboardingCarouselRoute extends _i9.PageRouteInfo<void> {
  const OnboardingCarouselRoute({List<_i9.PageRouteInfo>? children})
      : super(
          OnboardingCarouselRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingCarouselRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i6.OnboardingSecuritySetupPage]
class OnboardingSecuritySetupRoute extends _i9.PageRouteInfo<void> {
  const OnboardingSecuritySetupRoute({List<_i9.PageRouteInfo>? children})
      : super(
          OnboardingSecuritySetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingSecuritySetupRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i7.SecurityVerificationPage]
class SecurityVerificationRoute extends _i9.PageRouteInfo<void> {
  const SecurityVerificationRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SecurityVerificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'SecurityVerificationRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i8.SplashPage]
class SplashRoute extends _i9.PageRouteInfo<void> {
  const SplashRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}
