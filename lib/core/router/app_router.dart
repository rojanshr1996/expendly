import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingCarouselRoute.page),
        AutoRoute(page: CurrencySetupRoute.page),
        AutoRoute(page: AccountSetupRoute.page),
        AutoRoute(page: OnboardingSecuritySetupRoute.page),
        AutoRoute(page: FinalSetupRoute.page),
        AutoRoute(page: SecurityVerificationRoute.page),
        AutoRoute(page: DashboardRoute.page),
        AutoRoute(page: ModernAddTransactionRoute.page),
        AutoRoute(page: CreateNewBudgetRoute.page),
        AutoRoute(page: SettingsRoute.page),
        AutoRoute(page: PersonalProfileRoute.page),
      ];
}
