import 'package:expendly/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

import 'core/config/app_config.dart';
import 'core/config/firebase_options_factory.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_update_guard.dart';

/// Shared offline-first initialization entrypoint for all environment flavors.
Future<void> bootstrapApp(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(config);

  // Disable runtime font fetching — fonts are bundled in assets/google_fonts/
  GoogleFonts.config.allowRuntimeFetching = false;

  // Configure Dependency Injection via GetIt & Injectable
  await configureDependencies(config.flavor.name);

  // Initialize Firebase with flavor-specific options
  try {
    await Firebase.initializeApp(
      options: FirebaseOptionsFactory.currentOptions,
    );

    // Initialize Notification and Remote Config Services
    await getIt<NotificationService>().initialize();
    await getIt<RemoteConfigService>().initialize();
  } catch (e) {
    if (kDebugMode) {
      print('Firebase Initialization Error: $e');
    }
  }

  runApp(const ExpendlyApp());
}

void main() async {
  await bootstrapApp(
    const AppConfig(
      flavor: AppFlavor.dev,
      appName: 'Expendly Dev',
      enableLogging: true,
      showFlavorBanner: true,
    ),
  );
}

class ExpendlyApp extends StatefulWidget {
  const ExpendlyApp({super.key});

  @override
  State<ExpendlyApp> createState() => _ExpendlyAppState();
}

class _ExpendlyAppState extends State<ExpendlyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: _appRouter.config(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
          ],
          builder: (context, child) {
            Widget content = child ?? const SizedBox.shrink();
            if (config.showFlavorBanner && !config.isProd) {
              final colorScheme = Theme.of(context).colorScheme;
              content = Banner(
                message: config.flavor.name.toUpperCase(),
                location: BannerLocation.topEnd,
                color: config.isDev ? colorScheme.tertiary : colorScheme.secondary,
                child: content,
              );
            }
            return AppUpdateGuard(child: content);
          },
        );
      },
    );
  }
}

