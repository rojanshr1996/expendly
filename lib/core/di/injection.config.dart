// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;

import '../../features/analytics/data/datasources/analytics_local_datasource.dart'
    as _i378;
import '../../features/analytics/data/repositories/analytics_repository_impl.dart'
    as _i425;
import '../../features/analytics/domain/repositories/analytics_repository.dart'
    as _i1044;
import '../../features/analytics/presentation/cubit/analytics_cubit.dart'
    as _i821;
import '../../features/budgets/data/datasources/budget_local_datasource.dart'
    as _i334;
import '../../features/budgets/data/repositories/budget_repository_impl.dart'
    as _i654;
import '../../features/budgets/domain/repositories/budget_repository.dart'
    as _i1021;
import '../../features/budgets/presentation/cubit/budget_cubit.dart' as _i32;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i806;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i509;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i665;
import '../../features/dashboard/domain/usecases/get_financial_summary.dart'
    as _i119;
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart'
    as _i24;
import '../../features/profile/data/datasources/profile_local_datasource.dart'
    as _i1046;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/presentation/cubit/profile_cubit.dart' as _i36;
import '../../features/transactions/data/datasources/transaction_local_datasource.dart'
    as _i394;
import '../../features/transactions/data/repositories/transaction_repository_impl.dart'
    as _i443;
import '../../features/transactions/domain/repositories/transaction_repository.dart'
    as _i421;
import '../../features/transactions/presentation/cubit/transaction_cubit.dart'
    as _i1035;
import '../database/app_database.dart' as _i982;
import '../services/backup_service.dart' as _i832;
import '../services/biometric_auth_service.dart' as _i919;
import '../services/data_export_import_service.dart' as _i115;
import '../services/encryption_service.dart' as _i180;
import '../services/notification_service.dart' as _i941;
import '../services/preference_service.dart' as _i605;
import '../services/remote_config_service.dart' as _i858;
import '../services/secure_storage_service.dart' as _i535;
import '../services/storage/backup_storage_provider.dart' as _i349;
import '../utils/app_logger.dart' as _i924;
import 'register_module.dart' as _i291;

const String _prod = 'prod';
const String _dev = 'dev';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i982.AppDatabase>(() => _i982.AppDatabase());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i152.LocalAuthentication>(
        () => registerModule.localAuthentication);
    gh.lazySingleton<_i924.AppLogger>(() => _i924.AppLogger());
    gh.lazySingleton<_i858.RemoteConfigService>(
        () => _i858.RemoteConfigService());
    gh.lazySingleton<_i941.NotificationService>(
        () => _i941.NotificationService());
    gh.lazySingleton<_i378.AnalyticsLocalDataSource>(
        () => _i378.AnalyticsLocalDataSourceImpl(gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i394.TransactionLocalDataSource>(
        () => _i394.TransactionLocalDataSourceImpl(gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i1046.ProfileLocalDataSource>(
        () => _i1046.ProfileLocalDataSourceImpl(gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i1044.AnalyticsRepository>(() =>
        _i425.AnalyticsRepositoryImpl(gh<_i378.AnalyticsLocalDataSource>()));
    gh.lazySingleton<_i919.BiometricAuthService>(
        () => _i919.BiometricAuthService(gh<_i152.LocalAuthentication>()));
    gh.lazySingleton<_i334.BudgetLocalDataSource>(
        () => _i334.BudgetLocalDataSourceImpl(gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i349.BackupStorageProvider>(
      () => _i349.AndroidMediaStoreBackupStorageProvider(),
      registerFor: {
        _prod,
        _dev,
      },
    );
    gh.lazySingleton<_i535.SecureStorageService>(
        () => _i535.SecureStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i1021.BudgetRepository>(
        () => _i654.BudgetRepositoryImpl(gh<_i334.BudgetLocalDataSource>()));
    gh.lazySingleton<_i821.AnalyticsCubit>(
        () => _i821.AnalyticsCubit(gh<_i1044.AnalyticsRepository>()));
    gh.lazySingleton<_i32.BudgetCubit>(
        () => _i32.BudgetCubit(gh<_i1021.BudgetRepository>()));
    gh.lazySingleton<_i421.TransactionRepository>(() =>
        _i443.TransactionRepositoryImpl(
            gh<_i394.TransactionLocalDataSource>()));
    gh.lazySingleton<_i180.EncryptionService>(
        () => _i180.EncryptionService(gh<_i535.SecureStorageService>()));
    gh.lazySingleton<_i605.PreferenceService>(
        () => _i605.PreferenceService(gh<_i535.SecureStorageService>()));
    gh.lazySingleton<_i894.ProfileRepository>(
        () => _i334.ProfileRepositoryImpl(gh<_i1046.ProfileLocalDataSource>()));
    gh.factory<_i1035.TransactionCubit>(
        () => _i1035.TransactionCubit(gh<_i421.TransactionRepository>()));
    gh.lazySingleton<_i36.ProfileCubit>(
        () => _i36.ProfileCubit(gh<_i894.ProfileRepository>()));
    gh.lazySingleton<_i806.DashboardLocalDataSource>(
        () => _i806.DashboardLocalDataSourceImpl(
              gh<_i982.AppDatabase>(),
              gh<_i605.PreferenceService>(),
            ));
    gh.lazySingleton<_i115.DataExportImportService>(
        () => _i115.DataExportImportService(
              gh<_i982.AppDatabase>(),
              gh<_i605.PreferenceService>(),
              gh<_i349.BackupStorageProvider>(),
            ));
    gh.lazySingleton<_i665.DashboardRepository>(() =>
        _i509.DashboardRepositoryImpl(gh<_i806.DashboardLocalDataSource>()));
    gh.lazySingleton<_i832.BackupService>(() => _i832.BackupService(
          gh<_i982.AppDatabase>(),
          gh<_i115.DataExportImportService>(),
          gh<_i605.PreferenceService>(),
          gh<_i941.NotificationService>(),
        ));
    gh.lazySingleton<_i119.GetFinancialSummary>(
        () => _i119.GetFinancialSummary(gh<_i665.DashboardRepository>()));
    gh.factory<_i24.DashboardCubit>(
        () => _i24.DashboardCubit(gh<_i119.GetFinancialSummary>()));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
