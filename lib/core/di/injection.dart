import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/analytics/data/datasources/analytics_local_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/cubit/analytics_cubit.dart';
import '../../features/budgets/data/datasources/budget_local_datasource.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/budgets/presentation/cubit/budget_cubit.dart';
import '../../features/currency/data/datasources/exchange_rate_local_datasource.dart';
import '../../features/currency/data/datasources/exchange_rate_remote_datasource.dart';
import '../../features/currency/data/repositories/exchange_rate_repository_impl.dart';
import '../../features/currency/domain/repositories/exchange_rate_repository.dart';
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_financial_summary.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/groups/data/datasources/groups_local_datasource.dart';
import '../../features/groups/data/repositories/groups_repository_impl.dart';
import '../../features/groups/domain/repositories/groups_repository.dart';
import '../../features/groups/domain/usecases/calculate_settlements.dart';
import '../../features/groups/domain/usecases/calculate_splits.dart';
import '../../features/groups/presentation/cubit/event_detail_cubit.dart';
import '../../features/groups/presentation/cubit/groups_cubit.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/get_quick_entry_defaults_use_case.dart';
import '../../features/transactions/domain/usecases/get_recent_expenses_use_case.dart';
import '../../features/transactions/domain/usecases/update_quick_entry_defaults_use_case.dart';
import '../../features/transactions/presentation/cubit/quick_add_cubit.dart';
import '../../features/transactions/presentation/cubit/transaction_cubit.dart';
import '../config/app_config.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../preferences/quick_entry_preferences.dart';
import '../services/backup_service.dart';
import '../services/biometric_auth_service.dart';
import '../services/data_export_import_service.dart';
import '../services/notification_service.dart';
import '../services/pdf_report_service.dart';
import '../services/preference_service.dart';
import '../services/remote_config_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/app_logger.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies([String? environment]) async {
  getIt.allowReassignment = true;

  // Initialize generated injectable dependencies
  await getIt.init(environment: environment);

  // Core preferences & secure storage
  if (!getIt.isRegistered<SharedPreferences>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

  // Register AppConfig instance into GetIt if available
  if (!getIt.isRegistered<AppConfig>()) {
    getIt.registerLazySingleton<AppConfig>(() => AppConfig.instance);
  }

  // Core Database & Services Registration
  if (!getIt.isRegistered<LocalAuthentication>()) {
    getIt.registerLazySingleton<LocalAuthentication>(
        () => LocalAuthentication());
  }
  if (!getIt.isRegistered<BiometricAuthService>()) {
    getIt.registerLazySingleton<BiometricAuthService>(
        () => BiometricAuthService(getIt<LocalAuthentication>()));
  }
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  }
  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService());
  }
  if (!getIt.isRegistered<PreferenceService>()) {
    final prefService = PreferenceService(getIt<SecureStorageService>());
    await prefService.init();
    getIt.registerLazySingleton<PreferenceService>(() => prefService);
  }
  if (!getIt.isRegistered<QuickEntryPreferences>()) {
    getIt.registerLazySingleton<QuickEntryPreferences>(
        () => QuickEntryPreferences(getIt<SharedPreferences>()));
  }
  if (!getIt.isRegistered<DataExportImportService>()) {
    getIt.registerLazySingleton<DataExportImportService>(
        () => DataExportImportService(
              getIt<AppDatabase>(),
              getIt<PreferenceService>(),
            ));
  } else {
    await getIt<PreferenceService>().init();
  }

  if (!getIt.isRegistered<PdfReportService>()) {
    getIt.registerLazySingleton<PdfReportService>(() => PdfReportService());
  }

  if (!getIt.isRegistered<AppLogger>()) {
    getIt.registerLazySingleton<AppLogger>(() => AppLogger());
  }
  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerLazySingleton<NotificationService>(
        () => NotificationService());
  }
  if (!getIt.isRegistered<RemoteConfigService>()) {
    getIt.registerLazySingleton<RemoteConfigService>(
        () => RemoteConfigService());
  }

  if (!getIt.isRegistered<BackupService>()) {
    getIt.registerLazySingleton<BackupService>(() => BackupService(
          getIt<AppDatabase>(),
          getIt<DataExportImportService>(),
          getIt<PreferenceService>(),
          getIt<NotificationService>(),
        ));
  }

  // Network & Exchange Rates Services Registration
  if (!getIt.isRegistered<DioClient>()) {
    getIt.registerLazySingleton<DioClient>(() => DioClient());
  }
  if (!getIt.isRegistered<ExchangeRateRemoteDataSource>()) {
    getIt.registerLazySingleton<ExchangeRateRemoteDataSource>(
        () => ExchangeRateRemoteDataSourceImpl(getIt<DioClient>()));
  }
  if (!getIt.isRegistered<ExchangeRateLocalDataSource>()) {
    getIt.registerLazySingleton<ExchangeRateLocalDataSource>(
        () => ExchangeRateLocalDataSourceImpl());
  }
  if (!getIt.isRegistered<ExchangeRateRepository>()) {
    getIt.registerLazySingleton<ExchangeRateRepository>(
        () => ExchangeRateRepositoryImpl(
              getIt<ExchangeRateRemoteDataSource>(),
              getIt<ExchangeRateLocalDataSource>(),
              getIt<AppDatabase>(),
            ));
  }

  // Feature Datasources & Repositories Registration
  if (!getIt.isRegistered<ProfileLocalDataSource>()) {
    getIt.registerLazySingleton<ProfileLocalDataSource>(
        () => ProfileLocalDataSourceImpl(getIt<AppDatabase>()));
  }
  if (!getIt.isRegistered<ProfileRepository>()) {
    getIt.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(getIt<ProfileLocalDataSource>()));
  }
  if (!getIt.isRegistered<ProfileCubit>()) {
    getIt.registerLazySingleton<ProfileCubit>(
        () => ProfileCubit(getIt<ProfileRepository>()));
  }

  if (!getIt.isRegistered<TransactionLocalDataSource>()) {
    getIt.registerLazySingleton<TransactionLocalDataSource>(
        () => TransactionLocalDataSourceImpl(getIt<AppDatabase>()));
  }
  if (!getIt.isRegistered<TransactionRepository>()) {
    getIt.registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(getIt<TransactionLocalDataSource>()));
  }
  if (!getIt.isRegistered<TransactionCubit>()) {
    getIt.registerFactory<TransactionCubit>(
        () => TransactionCubit(getIt<TransactionRepository>()));
  }
  if (!getIt.isRegistered<GetRecentExpensesUseCase>()) {
    getIt.registerLazySingleton<GetRecentExpensesUseCase>(
        () => GetRecentExpensesUseCase(getIt<TransactionRepository>()));
  }
  if (!getIt.isRegistered<GetQuickEntryDefaultsUseCase>()) {
    getIt.registerLazySingleton<GetQuickEntryDefaultsUseCase>(
        () => GetQuickEntryDefaultsUseCase(
              quickEntryPreferences: getIt<QuickEntryPreferences>(),
              preferenceService: getIt<PreferenceService>(),
              transactionRepository: getIt<TransactionRepository>(),
              appDatabase: getIt<AppDatabase>(),
            ));
  }
  if (!getIt.isRegistered<UpdateQuickEntryDefaultsUseCase>()) {
    getIt.registerLazySingleton<UpdateQuickEntryDefaultsUseCase>(
        () => UpdateQuickEntryDefaultsUseCase(getIt<QuickEntryPreferences>()));
  }
  if (!getIt.isRegistered<QuickAddCubit>()) {
    getIt.registerFactory<QuickAddCubit>(() => QuickAddCubit(
          getIt<GetQuickEntryDefaultsUseCase>(),
          getIt<UpdateQuickEntryDefaultsUseCase>(),
          getIt<TransactionRepository>(),
          getIt<AppDatabase>(),
        ));
  }

  if (!getIt.isRegistered<BudgetLocalDataSource>()) {
    getIt.registerLazySingleton<BudgetLocalDataSource>(
        () => BudgetLocalDataSourceImpl(getIt<AppDatabase>()));
  }
  if (!getIt.isRegistered<BudgetRepository>()) {
    getIt.registerLazySingleton<BudgetRepository>(
        () => BudgetRepositoryImpl(getIt<BudgetLocalDataSource>()));
  }
  if (!getIt.isRegistered<BudgetCubit>()) {
    getIt.registerLazySingleton<BudgetCubit>(
        () => BudgetCubit(getIt<BudgetRepository>()));
  }

  if (!getIt.isRegistered<AnalyticsLocalDataSource>()) {
    getIt.registerLazySingleton<AnalyticsLocalDataSource>(
        () => AnalyticsLocalDataSourceImpl(getIt<AppDatabase>()));
  }
  if (!getIt.isRegistered<AnalyticsRepository>()) {
    getIt.registerLazySingleton<AnalyticsRepository>(
        () => AnalyticsRepositoryImpl(getIt<AnalyticsLocalDataSource>()));
  }
  if (!getIt.isRegistered<AnalyticsCubit>()) {
    getIt.registerLazySingleton<AnalyticsCubit>(
        () => AnalyticsCubit(getIt<AnalyticsRepository>()));
  }

  if (!getIt.isRegistered<DashboardLocalDataSource>()) {
    getIt.registerLazySingleton<DashboardLocalDataSource>(
        () => DashboardLocalDataSourceImpl(
              getIt<AppDatabase>(),
              getIt<PreferenceService>(),
            ));
  }
  if (!getIt.isRegistered<DashboardRepository>()) {
    getIt.registerLazySingleton<DashboardRepository>(
        () => DashboardRepositoryImpl(getIt<DashboardLocalDataSource>()));
  }
  if (!getIt.isRegistered<GetFinancialSummary>()) {
    getIt.registerLazySingleton<GetFinancialSummary>(
        () => GetFinancialSummary(getIt<DashboardRepository>()));
  }
  if (!getIt.isRegistered<DashboardCubit>()) {
    getIt.registerFactory<DashboardCubit>(
        () => DashboardCubit(getIt<GetFinancialSummary>()));
  }

  // Groups Feature — Datasource & Repository
  if (!getIt.isRegistered<GroupsLocalDataSource>()) {
    getIt.registerLazySingleton<GroupsLocalDataSource>(
        () => GroupsLocalDataSourceImpl(getIt<AppDatabase>()));
  }
  if (!getIt.isRegistered<GroupsRepository>()) {
    getIt.registerLazySingleton<GroupsRepository>(
        () => GroupsRepositoryImpl(getIt<GroupsLocalDataSource>()));
  }

  // Groups Feature — Use Cases
  if (!getIt.isRegistered<CalculateSplits>()) {
    getIt.registerLazySingleton<CalculateSplits>(() => CalculateSplits());
  }
  if (!getIt.isRegistered<CalculateSettlements>()) {
    getIt.registerLazySingleton<CalculateSettlements>(
        () => CalculateSettlements());
  }

  // Groups Feature — Cubits
  if (!getIt.isRegistered<GroupsCubit>()) {
    getIt.registerLazySingleton<GroupsCubit>(
        () => GroupsCubit(getIt<GroupsRepository>()));
  }
  if (!getIt.isRegistered<EventDetailCubit>()) {
    getIt.registerFactory<EventDetailCubit>(() => EventDetailCubit(
        getIt<GroupsRepository>(), getIt<CalculateSettlements>()));
  }
}
