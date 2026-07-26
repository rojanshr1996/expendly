// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:auto_route/auto_route.dart' as _i1;
import '../../features/dashboard/presentation/pages/dashboard_page.dart' as _i2;
import '../../features/splash/presentation/pages/splash_page.dart' as _i3;

abstract class $AppRouter extends _i1.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    DashboardRoute.name: (routeData) {
      return _i1.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.DashboardPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return _i1.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.SplashPage(),
      );
    },
  };
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardRoute extends _i1.PageRouteInfo<void> {
  const DashboardRoute({List<_i1.PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const _i1.PageInfo<void> page = _i1.PageInfo<void>(name);
}

/// generated route for
/// [_i3.SplashPage]
class SplashRoute extends _i1.PageRouteInfo<void> {
  const SplashRoute({List<_i1.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const _i1.PageInfo<void> page = _i1.PageInfo<void>(name);
}
