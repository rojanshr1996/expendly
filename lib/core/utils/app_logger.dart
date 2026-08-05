import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Flavor-aware custom [LogFilter] for Expendly.
class FlavorLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (!kDebugMode && AppConfig.instance.isProd) {
      // In production builds, only log warnings, errors, and fatal exceptions if enabled
      if (!AppConfig.instance.enableLogging) return false;
      return event.level.index >= Level.warning.index;
    }

    if (!AppConfig.instance.enableLogging) {
      return false;
    }

    switch (AppConfig.instance.flavor) {
      case AppFlavor.dev:
        // DEV logs everything from trace/debug up
        return event.level.index >= Level.trace.index;
      case AppFlavor.qa:
        // QA logs info, warning, error, and fatal
        return event.level.index >= Level.info.index;
      case AppFlavor.prod:
        // PROD logs warning, error, and fatal
        // return event.level.index >= Level.warning.index;
        return event.level.index >= Level.trace.index;
    }
  }
}

/// Centralized flavor-aware logger utility for the Expendly application.
@lazySingleton
class AppLogger {
  late final Logger _logger;

  AppLogger() {
    _initLogger();
  }

  static AppLogger? _instance;

  static AppLogger get instance {
    _instance ??= AppLogger();
    return _instance!;
  }

  void _initLogger() {
    // final isDev = AppConfig.instance.isDev;

    _logger = Logger(
      filter: FlavorLogFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 100,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
    );
  }

  /// Log a debug message (Verbose/Development details).
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance._logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an informational message (System events, navigation, state changes).
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance._logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message (Non-critical failures, fallbacks).
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance._logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message (Caught exceptions, API/DB failures).
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance._logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal / severe error.
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance._logger.f(message, error: error, stackTrace: stackTrace);
  }
}
