import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Context extensions for localization, theme, colorScheme, textTheme, and design extensions.
extension BuildContextExtension on BuildContext {
  // Localization getter
  AppLocalizations get l10n {
    return AppLocalizations.of(this) ?? _FallbackLocalizations.instance;
  }

  // Theme getters
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Custom design extensions getters
  AppCustomColors get customColors =>
      Theme.of(this).extension<AppCustomColors>() ?? AppCustomColors.dark;

  AppCustomTypography get customTypography =>
      Theme.of(this).extension<AppCustomTypography>() ??
      AppCustomTypography.dark;
}

class _FallbackLocalizations implements AppLocalizations {
  static final _FallbackLocalizations instance = _FallbackLocalizations();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
