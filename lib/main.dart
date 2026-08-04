import 'dart:async';

import 'package:expendly/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/config/app_config.dart';
import 'core/config/firebase_options_factory.dart';
import 'core/di/injection.dart';
import 'core/models/notification_payload.dart';
import 'core/router/app_router.dart';
import 'core/router/app_router.gr.dart';
import 'core/services/backup_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/preference_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/app_update_guard.dart';
import 'core/widgets/notification_detail_dialog.dart';

/// Shared offline-first initialization entrypoint for all environment flavors.
Future<void> bootstrapApp(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(config);

  AppLogger.i(
      '🚀 Bootstrapping Expendly App [Flavor: ${config.flavor.name.toUpperCase()}]');

  // Disable runtime font fetching — fonts are bundled in assets/google_fonts/
  GoogleFonts.config.allowRuntimeFetching = false;

  // Configure Dependency Injection via GetIt & Injectable
  await configureDependencies(config.flavor.name);
  AppLogger.d('Dependency injection configured via GetIt');

  // Initialize Firebase with flavor-specific options
  try {
    await Firebase.initializeApp(
      options: FirebaseOptionsFactory.currentOptions,
    );
    AppLogger.i('Firebase initialized successfully');

    // Initialize Notification and Remote Config Services
    await getIt<NotificationService>().initialize();
    await getIt<RemoteConfigService>().initialize();
  } catch (e, stackTrace) {
    AppLogger.e('Firebase Initialization Error', e, stackTrace);
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

class _ExpendlyAppState extends State<ExpendlyApp> with WidgetsBindingObserver {
  late final AppRouter _appRouter;
  StreamSubscription<NotificationActionPayload>? _notificationSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appRouter = AppRouter();
    _listenNotificationActions();
    _startBackup();
  }

  void _startBackup() {
    if (getIt.isRegistered<BackupService>()) {
      getIt<BackupService>().start();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (getIt.isRegistered<BackupService>()) {
        getIt<BackupService>().checkIfDue();
      }
    }
  }

  void _listenNotificationActions() {
    if (getIt.isRegistered<NotificationService>()) {
      _notificationSub = getIt<NotificationService>()
          .onNotificationAction
          .listen(_handleNotificationAction);
    }
  }

  void _handleNotificationAction(NotificationActionPayload payload) async {
    AppLogger.i(
        'Handling notification action payload: action=${payload.action}, actionType=${payload.actionType}, target=${payload.target}');

    // 1. If actionType is externalUrl or payload is a URL link -> launch external URL directly
    if (payload.isUrlAction) {
      final url = payload.urlToOpen ?? payload.action ?? payload.target;
      if (url != null && url.isNotEmpty) {
        if (getIt.isRegistered<NotificationService>()) {
          await getIt<NotificationService>().launchExternalUrl(url);
        } else {
          try {
            String formattedUrl = url.trim();
            if (!formattedUrl.startsWith('http://') &&
                !formattedUrl.startsWith('https://')) {
              formattedUrl = 'https://$formattedUrl';
            }
            final uri = Uri.parse(formattedUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            AppLogger.e(
                'Failed to launch URL from notification payload: $url', e);
          }
        }
        return;
      }
    }

    // 2. For ALL OTHER notifications (actionType != 'externalUrl'), display in-app popup dialog!
    final context = _appRouter.navigatorKey.currentContext;
    if (context != null) {
      NotificationDetailDialog.show(
        context,
        payload,
        onPrimaryAction: () {
          final action = payload.action?.toLowerCase();
          final target = payload.target?.toLowerCase();

          if (action == 'add_transaction' ||
              target == 'add_transaction' ||
              target == 'modern_add_transaction') {
            _appRouter.push(ModernAddTransactionRoute());
          } else if (action == 'create_budget' ||
              target == 'create_budget' ||
              target == 'create_new_budget') {
            _appRouter.push(CreateNewBudgetRoute());
          } else if (action == 'settings' || target == 'settings') {
            _appRouter.push(const SettingsRoute());
          } else if (action == 'profile' ||
              target == 'profile' ||
              target == 'personal_profile') {
            _appRouter.push(const PersonalProfileRoute());
          } else if (action == 'about' || target == 'about') {
            _appRouter.push(const AboutRoute());
          } else if (action == 'help' ||
              target == 'help' ||
              target == 'help_support') {
            _appRouter.push(const HelpSupportRoute());
          } else if (action == 'dashboard' || target == 'dashboard') {
            _appRouter.push(const DashboardRoute());
          }
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (getIt.isRegistered<BackupService>()) {
      getIt<BackupService>().stop();
    }
    _notificationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    final prefService = getIt<PreferenceService>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder<String>(
          valueListenable: prefService.themeModeNotifier,
          builder: (context, themeModeStr, child) {
            final themeMode = themeModeStr == 'light'
                ? ThemeMode.light
                : (themeModeStr == 'system'
                    ? ThemeMode.system
                    : ThemeMode.dark);

            return MaterialApp.router(
              title: config.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
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
                    color: config.isDev
                        ? colorScheme.tertiary
                        : colorScheme.secondary,
                    child: content,
                  );
                }
                return AppUpdateGuard(child: content);
              },
            );
          },
        );
      },
    );
  }
}
