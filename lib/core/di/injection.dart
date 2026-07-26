import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../database/app_database.dart';
import '../services/encryption_service.dart';
import '../services/notification_service.dart';
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
  // Register AppConfig instance into GetIt if available
  if (getIt.isRegistered<AppConfig>()) {
    getIt.unregister<AppConfig>();
  }
  getIt.registerSingleton<AppConfig>(AppConfig.instance);

  // Register AppDatabase singleton
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  }

  // Register SecureStorageService singleton
  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService());
  }

  // Register EncryptionService singleton
  if (!getIt.isRegistered<EncryptionService>()) {
    getIt.registerLazySingleton<EncryptionService>(
      () => EncryptionService(getIt<SecureStorageService>()),
    );
  }

  // Register PreferenceService singleton and initialize SharedPreferences & SecureStorage
  if (!getIt.isRegistered<PreferenceService>()) {
    final prefsService = PreferenceService(getIt<SecureStorageService>());
    await prefsService.init();
    getIt.registerSingleton<PreferenceService>(prefsService);
  } else {
    await getIt<PreferenceService>().init();
  }

  // Initialize generated injectable dependencies
  try {
    getIt.init(environment: environment);
  } catch (e) {
    // Fallback manual registration for core services if generated init is unavailable
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
  }
}
