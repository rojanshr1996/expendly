// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/dashboard/data/datasources/dashboard_local_data_source.dart'
    as _i838;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i509;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i665;
import '../../features/dashboard/domain/usecases/get_financial_summary.dart'
    as _i119;
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart'
    as _i24;
import '../services/notification_service.dart' as _i941;
import '../services/remote_config_service.dart' as _i858;

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
    gh.lazySingleton<_i858.RemoteConfigService>(
        () => _i858.RemoteConfigService());
    gh.lazySingleton<_i941.NotificationService>(
        () => _i941.NotificationService());
    gh.lazySingleton<_i838.DashboardLocalDataSource>(
        () => _i838.DashboardLocalDataSourceImpl());
    gh.lazySingleton<_i665.DashboardRepository>(() =>
        _i509.DashboardRepositoryImpl(gh<_i838.DashboardLocalDataSource>()));
    gh.lazySingleton<_i119.GetFinancialSummary>(
        () => _i119.GetFinancialSummary(gh<_i665.DashboardRepository>()));
    gh.factory<_i24.DashboardCubit>(
        () => _i24.DashboardCubit(gh<_i119.GetFinancialSummary>()));
    return this;
  }
}
