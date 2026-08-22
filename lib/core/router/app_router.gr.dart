// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:expendly/features/budgets/presentation/pages/create_new_budget_page.dart'
    as _i3;
import 'package:expendly/features/dashboard/presentation/pages/dashboard_page.dart'
    as _i5;
import 'package:expendly/features/groups/domain/entities/event_participant.dart'
    as _i24;
import 'package:expendly/features/groups/domain/entities/group_expense.dart'
    as _i25;
import 'package:expendly/features/groups/domain/entities/sharing_event.dart'
    as _i26;
import 'package:expendly/features/groups/presentation/pages/add_expense_page.dart'
    as _i2;
import 'package:expendly/features/groups/presentation/pages/event_detail_page.dart'
    as _i6;
import 'package:expendly/features/groups/presentation/pages/expense_details_page.dart'
    as _i7;
import 'package:expendly/features/groups/presentation/pages/export_settle_page.dart'
    as _i8;
import 'package:expendly/features/groups/presentation/pages/groups_list_page.dart'
    as _i10;
import 'package:expendly/features/groups/presentation/pages/new_event_page.dart'
    as _i13;
import 'package:expendly/features/onboarding/presentation/pages/currency_setup_page.dart'
    as _i4;
import 'package:expendly/features/onboarding/presentation/pages/final_setup_page.dart'
    as _i9;
import 'package:expendly/features/onboarding/presentation/pages/onboarding_carousel_page.dart'
    as _i14;
import 'package:expendly/features/onboarding/presentation/pages/onboarding_security_setup_page.dart'
    as _i15;
import 'package:expendly/features/profile/presentation/pages/personal_profile_page.dart'
    as _i16;
import 'package:expendly/features/security/presentation/pages/security_verification_page.dart'
    as _i17;
import 'package:expendly/features/settings/presentation/pages/about_page.dart'
    as _i1;
import 'package:expendly/features/settings/presentation/pages/help_support_page.dart'
    as _i11;
import 'package:expendly/features/settings/presentation/pages/settings_page.dart'
    as _i18;
import 'package:expendly/features/settings/presentation/pages/terms_conditions_page.dart'
    as _i20;
import 'package:expendly/features/splash/presentation/pages/splash_page.dart'
    as _i19;
import 'package:expendly/features/transactions/domain/entities/transaction_item.dart'
    as _i27;
import 'package:expendly/features/transactions/presentation/pages/modern_add_transaction_page.dart'
    as _i12;
import 'package:expendly/features/transactions/presentation/pages/transaction_details_page.dart'
    as _i21;
import 'package:flutter/material.dart' as _i23;

abstract class $AppRouter extends _i22.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i22.PageFactory> pagesMap = {
    AboutRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AboutPage(),
      );
    },
    AddExpenseRoute.name: (routeData) {
      final args = routeData.argsAs<AddExpenseRouteArgs>();
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.AddExpensePage(
          key: args.key,
          eventId: args.eventId,
          participants: args.participants,
        ),
      );
    },
    CreateNewBudgetRoute.name: (routeData) {
      final args = routeData.argsAs<CreateNewBudgetRouteArgs>(
          orElse: () => const CreateNewBudgetRouteArgs());
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.CreateNewBudgetPage(
          key: args.key,
          onSaved: args.onSaved,
        ),
      );
    },
    CurrencySetupRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.CurrencySetupPage(),
      );
    },
    DashboardRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.DashboardPage(),
      );
    },
    EventDetailRoute.name: (routeData) {
      final args = routeData.argsAs<EventDetailRouteArgs>();
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i6.EventDetailPage(
          key: args.key,
          eventId: args.eventId,
        ),
      );
    },
    ExpenseDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<ExpenseDetailsRouteArgs>();
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.ExpenseDetailsPage(
          key: args.key,
          expense: args.expense,
          event: args.event,
          onDeleteExpense: args.onDeleteExpense,
        ),
      );
    },
    ExportSettleRoute.name: (routeData) {
      final args = routeData.argsAs<ExportSettleRouteArgs>();
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.ExportSettlePage(
          key: args.key,
          eventId: args.eventId,
        ),
      );
    },
    FinalSetupRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.FinalSetupPage(),
      );
    },
    GroupsListRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.GroupsListPage(),
      );
    },
    HelpSupportRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.HelpSupportPage(),
      );
    },
    ModernAddTransactionRoute.name: (routeData) {
      final args = routeData.argsAs<ModernAddTransactionRouteArgs>(
          orElse: () => const ModernAddTransactionRouteArgs());
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.ModernAddTransactionPage(
          key: args.key,
          initialTransaction: args.initialTransaction,
        ),
      );
    },
    NewEventRoute.name: (routeData) {
      final args = routeData.argsAs<NewEventRouteArgs>(
          orElse: () => const NewEventRouteArgs());
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i13.NewEventPage(
          key: args.key,
          event: args.event,
        ),
      );
    },
    OnboardingCarouselRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.OnboardingCarouselPage(),
      );
    },
    OnboardingSecuritySetupRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.OnboardingSecuritySetupPage(),
      );
    },
    PersonalProfileRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i16.PersonalProfilePage(),
      );
    },
    SecurityVerificationRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i17.SecurityVerificationPage(),
      );
    },
    SettingsRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i18.SettingsPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i19.SplashPage(),
      );
    },
    TermsConditionsRoute.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i20.TermsConditionsPage(),
      );
    },
    TransactionDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<TransactionDetailsRouteArgs>();
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i21.TransactionDetailsPage(
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
class AboutRoute extends _i22.PageRouteInfo<void> {
  const AboutRoute({List<_i22.PageRouteInfo>? children})
      : super(
          AboutRoute.name,
          initialChildren: children,
        );

  static const String name = 'AboutRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AddExpensePage]
class AddExpenseRoute extends _i22.PageRouteInfo<AddExpenseRouteArgs> {
  AddExpenseRoute({
    _i23.Key? key,
    required int eventId,
    required List<_i24.EventParticipant> participants,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          AddExpenseRoute.name,
          args: AddExpenseRouteArgs(
            key: key,
            eventId: eventId,
            participants: participants,
          ),
          initialChildren: children,
        );

  static const String name = 'AddExpenseRoute';

  static const _i22.PageInfo<AddExpenseRouteArgs> page =
      _i22.PageInfo<AddExpenseRouteArgs>(name);
}

class AddExpenseRouteArgs {
  const AddExpenseRouteArgs({
    this.key,
    required this.eventId,
    required this.participants,
  });

  final _i23.Key? key;

  final int eventId;

  final List<_i24.EventParticipant> participants;

  @override
  String toString() {
    return 'AddExpenseRouteArgs{key: $key, eventId: $eventId, participants: $participants}';
  }
}

/// generated route for
/// [_i3.CreateNewBudgetPage]
class CreateNewBudgetRoute
    extends _i22.PageRouteInfo<CreateNewBudgetRouteArgs> {
  CreateNewBudgetRoute({
    _i23.Key? key,
    void Function()? onSaved,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          CreateNewBudgetRoute.name,
          args: CreateNewBudgetRouteArgs(
            key: key,
            onSaved: onSaved,
          ),
          initialChildren: children,
        );

  static const String name = 'CreateNewBudgetRoute';

  static const _i22.PageInfo<CreateNewBudgetRouteArgs> page =
      _i22.PageInfo<CreateNewBudgetRouteArgs>(name);
}

class CreateNewBudgetRouteArgs {
  const CreateNewBudgetRouteArgs({
    this.key,
    this.onSaved,
  });

  final _i23.Key? key;

  final void Function()? onSaved;

  @override
  String toString() {
    return 'CreateNewBudgetRouteArgs{key: $key, onSaved: $onSaved}';
  }
}

/// generated route for
/// [_i4.CurrencySetupPage]
class CurrencySetupRoute extends _i22.PageRouteInfo<void> {
  const CurrencySetupRoute({List<_i22.PageRouteInfo>? children})
      : super(
          CurrencySetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'CurrencySetupRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i5.DashboardPage]
class DashboardRoute extends _i22.PageRouteInfo<void> {
  const DashboardRoute({List<_i22.PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i6.EventDetailPage]
class EventDetailRoute extends _i22.PageRouteInfo<EventDetailRouteArgs> {
  EventDetailRoute({
    _i23.Key? key,
    required int eventId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          EventDetailRoute.name,
          args: EventDetailRouteArgs(
            key: key,
            eventId: eventId,
          ),
          initialChildren: children,
        );

  static const String name = 'EventDetailRoute';

  static const _i22.PageInfo<EventDetailRouteArgs> page =
      _i22.PageInfo<EventDetailRouteArgs>(name);
}

class EventDetailRouteArgs {
  const EventDetailRouteArgs({
    this.key,
    required this.eventId,
  });

  final _i23.Key? key;

  final int eventId;

  @override
  String toString() {
    return 'EventDetailRouteArgs{key: $key, eventId: $eventId}';
  }
}

/// generated route for
/// [_i7.ExpenseDetailsPage]
class ExpenseDetailsRoute extends _i22.PageRouteInfo<ExpenseDetailsRouteArgs> {
  ExpenseDetailsRoute({
    _i23.Key? key,
    required _i25.GroupExpense expense,
    required _i26.SharingEvent event,
    void Function(int)? onDeleteExpense,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          ExpenseDetailsRoute.name,
          args: ExpenseDetailsRouteArgs(
            key: key,
            expense: expense,
            event: event,
            onDeleteExpense: onDeleteExpense,
          ),
          initialChildren: children,
        );

  static const String name = 'ExpenseDetailsRoute';

  static const _i22.PageInfo<ExpenseDetailsRouteArgs> page =
      _i22.PageInfo<ExpenseDetailsRouteArgs>(name);
}

class ExpenseDetailsRouteArgs {
  const ExpenseDetailsRouteArgs({
    this.key,
    required this.expense,
    required this.event,
    this.onDeleteExpense,
  });

  final _i23.Key? key;

  final _i25.GroupExpense expense;

  final _i26.SharingEvent event;

  final void Function(int)? onDeleteExpense;

  @override
  String toString() {
    return 'ExpenseDetailsRouteArgs{key: $key, expense: $expense, event: $event, onDeleteExpense: $onDeleteExpense}';
  }
}

/// generated route for
/// [_i8.ExportSettlePage]
class ExportSettleRoute extends _i22.PageRouteInfo<ExportSettleRouteArgs> {
  ExportSettleRoute({
    _i23.Key? key,
    required int eventId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          ExportSettleRoute.name,
          args: ExportSettleRouteArgs(
            key: key,
            eventId: eventId,
          ),
          initialChildren: children,
        );

  static const String name = 'ExportSettleRoute';

  static const _i22.PageInfo<ExportSettleRouteArgs> page =
      _i22.PageInfo<ExportSettleRouteArgs>(name);
}

class ExportSettleRouteArgs {
  const ExportSettleRouteArgs({
    this.key,
    required this.eventId,
  });

  final _i23.Key? key;

  final int eventId;

  @override
  String toString() {
    return 'ExportSettleRouteArgs{key: $key, eventId: $eventId}';
  }
}

/// generated route for
/// [_i9.FinalSetupPage]
class FinalSetupRoute extends _i22.PageRouteInfo<void> {
  const FinalSetupRoute({List<_i22.PageRouteInfo>? children})
      : super(
          FinalSetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'FinalSetupRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i10.GroupsListPage]
class GroupsListRoute extends _i22.PageRouteInfo<void> {
  const GroupsListRoute({List<_i22.PageRouteInfo>? children})
      : super(
          GroupsListRoute.name,
          initialChildren: children,
        );

  static const String name = 'GroupsListRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i11.HelpSupportPage]
class HelpSupportRoute extends _i22.PageRouteInfo<void> {
  const HelpSupportRoute({List<_i22.PageRouteInfo>? children})
      : super(
          HelpSupportRoute.name,
          initialChildren: children,
        );

  static const String name = 'HelpSupportRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i12.ModernAddTransactionPage]
class ModernAddTransactionRoute
    extends _i22.PageRouteInfo<ModernAddTransactionRouteArgs> {
  ModernAddTransactionRoute({
    _i23.Key? key,
    _i27.TransactionItem? initialTransaction,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          ModernAddTransactionRoute.name,
          args: ModernAddTransactionRouteArgs(
            key: key,
            initialTransaction: initialTransaction,
          ),
          initialChildren: children,
        );

  static const String name = 'ModernAddTransactionRoute';

  static const _i22.PageInfo<ModernAddTransactionRouteArgs> page =
      _i22.PageInfo<ModernAddTransactionRouteArgs>(name);
}

class ModernAddTransactionRouteArgs {
  const ModernAddTransactionRouteArgs({
    this.key,
    this.initialTransaction,
  });

  final _i23.Key? key;

  final _i27.TransactionItem? initialTransaction;

  @override
  String toString() {
    return 'ModernAddTransactionRouteArgs{key: $key, initialTransaction: $initialTransaction}';
  }
}

/// generated route for
/// [_i13.NewEventPage]
class NewEventRoute extends _i22.PageRouteInfo<NewEventRouteArgs> {
  NewEventRoute({
    _i23.Key? key,
    _i26.SharingEvent? event,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          NewEventRoute.name,
          args: NewEventRouteArgs(
            key: key,
            event: event,
          ),
          initialChildren: children,
        );

  static const String name = 'NewEventRoute';

  static const _i22.PageInfo<NewEventRouteArgs> page =
      _i22.PageInfo<NewEventRouteArgs>(name);
}

class NewEventRouteArgs {
  const NewEventRouteArgs({
    this.key,
    this.event,
  });

  final _i23.Key? key;

  final _i26.SharingEvent? event;

  @override
  String toString() {
    return 'NewEventRouteArgs{key: $key, event: $event}';
  }
}

/// generated route for
/// [_i14.OnboardingCarouselPage]
class OnboardingCarouselRoute extends _i22.PageRouteInfo<void> {
  const OnboardingCarouselRoute({List<_i22.PageRouteInfo>? children})
      : super(
          OnboardingCarouselRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingCarouselRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i15.OnboardingSecuritySetupPage]
class OnboardingSecuritySetupRoute extends _i22.PageRouteInfo<void> {
  const OnboardingSecuritySetupRoute({List<_i22.PageRouteInfo>? children})
      : super(
          OnboardingSecuritySetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingSecuritySetupRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i16.PersonalProfilePage]
class PersonalProfileRoute extends _i22.PageRouteInfo<void> {
  const PersonalProfileRoute({List<_i22.PageRouteInfo>? children})
      : super(
          PersonalProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'PersonalProfileRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i17.SecurityVerificationPage]
class SecurityVerificationRoute extends _i22.PageRouteInfo<void> {
  const SecurityVerificationRoute({List<_i22.PageRouteInfo>? children})
      : super(
          SecurityVerificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'SecurityVerificationRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i18.SettingsPage]
class SettingsRoute extends _i22.PageRouteInfo<void> {
  const SettingsRoute({List<_i22.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i19.SplashPage]
class SplashRoute extends _i22.PageRouteInfo<void> {
  const SplashRoute({List<_i22.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i20.TermsConditionsPage]
class TermsConditionsRoute extends _i22.PageRouteInfo<void> {
  const TermsConditionsRoute({List<_i22.PageRouteInfo>? children})
      : super(
          TermsConditionsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TermsConditionsRoute';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i21.TransactionDetailsPage]
class TransactionDetailsRoute
    extends _i22.PageRouteInfo<TransactionDetailsRouteArgs> {
  TransactionDetailsRoute({
    _i23.Key? key,
    required _i27.TransactionItem transaction,
    _i23.ValueNotifier<bool>? isPrivacyModeNotifier,
    List<_i22.PageRouteInfo>? children,
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

  static const _i22.PageInfo<TransactionDetailsRouteArgs> page =
      _i22.PageInfo<TransactionDetailsRouteArgs>(name);
}

class TransactionDetailsRouteArgs {
  const TransactionDetailsRouteArgs({
    this.key,
    required this.transaction,
    this.isPrivacyModeNotifier,
  });

  final _i23.Key? key;

  final _i27.TransactionItem transaction;

  final _i23.ValueNotifier<bool>? isPrivacyModeNotifier;

  @override
  String toString() {
    return 'TransactionDetailsRouteArgs{key: $key, transaction: $transaction, isPrivacyModeNotifier: $isPrivacyModeNotifier}';
  }
}
