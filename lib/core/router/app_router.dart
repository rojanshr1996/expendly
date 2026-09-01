import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingCarouselRoute.page),
        AutoRoute(page: CurrencySetupRoute.page),
        AutoRoute(page: OnboardingSecuritySetupRoute.page),
        AutoRoute(page: FinalSetupRoute.page),
        AutoRoute(page: SecurityVerificationRoute.page),
        AutoRoute(page: DashboardRoute.page),
        AutoRoute(page: ModernAddTransactionRoute.page),
        AutoRoute(page: QuickAddRoute.page),
        AutoRoute(page: CreateNewBudgetRoute.page),
        AutoRoute(page: SettingsRoute.page),
        AutoRoute(page: PersonalProfileRoute.page),
        AutoRoute(page: TransactionDetailsRoute.page),
        AutoRoute(page: AboutRoute.page),
        AutoRoute(page: TermsConditionsRoute.page),
        AutoRoute(page: HelpSupportRoute.page),
        AutoRoute(page: NewEventRoute.page),
        AutoRoute(page: EventDetailRoute.page),
        AutoRoute(page: AddExpenseRoute.page),
        AutoRoute(page: ExportSettleRoute.page),
        AutoRoute(page: ExpenseDetailsRoute.page),
        AutoRoute(page: DailyEntryRoute.page),
      ];
}
