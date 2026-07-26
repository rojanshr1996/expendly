import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../services/notification_service.dart';
import '../services/remote_config_service.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies([String? environment]) async {
  // Register AppConfig instance into GetIt if available
  if (getIt.isRegistered<AppConfig>()) {
    getIt.unregister<AppConfig>();
  }
  getIt.registerSingleton<AppConfig>(AppConfig.instance);

  // Register Core Services
  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  }
  if (!getIt.isRegistered<RemoteConfigService>()) {
    getIt.registerLazySingleton<RemoteConfigService>(() => RemoteConfigService());
  }

  // Initialize generated injectable dependencies
  try {
    getIt.init(environment: environment ?? AppConfig.instance.flavor.name);
  } catch (_) {
    // Safety fallback for pre-build_runner builds
  }
}
