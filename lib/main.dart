import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Shared offline-first initialization entrypoint for all environment flavors.
Future<void> bootstrapApp(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(config);

  // Disable runtime font fetching — fonts are bundled in assets/google_fonts/
  GoogleFonts.config.allowRuntimeFetching = false;

  // Configure Dependency Injection via GetIt & Injectable
  await configureDependencies(config.flavor.name);

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
            final content = child ?? const SizedBox.shrink();
            if (config.showFlavorBanner && !config.isProd) {
              final colorScheme = Theme.of(context).colorScheme;
              return Banner(
                message: config.flavor.name.toUpperCase(),
                location: BannerLocation.topEnd,
                color: config.isDev ? colorScheme.tertiary : colorScheme.secondary,
                child: content,
              );
            }
            return content;
          },
        );
      },
    );
  }
}
