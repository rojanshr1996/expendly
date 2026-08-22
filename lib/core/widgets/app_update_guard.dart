import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../di/injection.dart';
import '../extensions/context_extensions.dart';
import '../services/remote_config_service.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class AppUpdateGuard extends StatefulWidget {
  final Widget child;

  const AppUpdateGuard({
    super.key,
    required this.child,
  });

  @override
  State<AppUpdateGuard> createState() => _AppUpdateGuardState();
}

class _AppUpdateGuardState extends State<AppUpdateGuard> {
  final RemoteConfigService _remoteConfig = getIt<RemoteConfigService>();

  late final ValueNotifier<bool> _isMaintenanceNotifier;
  late final ValueNotifier<AppUpdateStatus> _updateStatusNotifier;
  final ValueNotifier<bool> _optionalUpdateDismissedNotifier =
      ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _isMaintenanceNotifier =
        ValueNotifier<bool>(_remoteConfig.isMaintenanceMode);
    _updateStatusNotifier =
        ValueNotifier<AppUpdateStatus>(AppUpdateStatus.none);
    _checkInitialState();

    _remoteConfig.onMaintenanceChanged.listen((isMaint) {
      _isMaintenanceNotifier.value = isMaint;
    });

    _remoteConfig.onUpdateStatusChanged.listen((status) {
      _updateStatusNotifier.value = status;
    });
  }

  @override
  void dispose() {
    _isMaintenanceNotifier.dispose();
    _updateStatusNotifier.dispose();
    _optionalUpdateDismissedNotifier.dispose();
    super.dispose();
  }

  Future<void> _checkInitialState() async {
    final status = await _remoteConfig.checkUpdateStatus(fetchRemote: true);
    if (mounted) {
      _isMaintenanceNotifier.value = _remoteConfig.isMaintenanceMode;
      _updateStatusNotifier.value = status;
    }
  }

  Future<void> _openStoreUrl() async {
    final urlString = Platform.isIOS
        ? _remoteConfig.updateUrlIos
        : _remoteConfig.updateUrlAndroid;

    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // ValueListenableBuilder for reactive overlays inside a constant Positioned.fill
        Positioned.fill(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isMaintenanceNotifier,
            builder: (context, isMaintenance, _) {
              if (isMaintenance) {
                return _buildMaintenanceScreen(context);
              }

              return ValueListenableBuilder<AppUpdateStatus>(
                valueListenable: _updateStatusNotifier,
                builder: (context, updateStatus, _) {
                  if (updateStatus == AppUpdateStatus.forceUpdate) {
                    return _buildForceUpdateScreen(context);
                  }

                  if (updateStatus == AppUpdateStatus.optionalUpdate) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: _optionalUpdateDismissedNotifier,
                      builder: (context, dismissed, _) {
                        if (!dismissed) {
                          return _buildOptionalUpdateDialog(context);
                        }
                        return const IgnorePointer(
                          child: SizedBox.shrink(),
                        );
                      },
                    );
                  }

                  return const IgnorePointer(
                    child: SizedBox.shrink(),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceScreen(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.tertiary, width: 2),
                ),
                child: Icon(
                  Icons.build_circle_rounded,
                  size: 48.r,
                  color: colorScheme.tertiary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                _remoteConfig.maintenanceTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                _remoteConfig.maintenanceMessage,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForceUpdateScreen(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  size: 48.r,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                _remoteConfig.forceUpdateTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                _remoteConfig.forceUpdateMessage,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openStoreUrl,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Update Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionalUpdateDialog(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      color: Colors.black.withValues(alpha: isLight ? 0.4 : 0.6),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Material(
        color: isLight ? colorScheme.surface : colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.borderLg,
        elevation: isLight ? 4 : 0,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isLight
                  ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                  : customColors.glassStroke,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.new_releases_rounded,
                size: 48.r,
                color: colorScheme.secondary,
              ),
              SizedBox(height: 16.h),
              Text(
                _remoteConfig.optionalUpdateTitle,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _remoteConfig.optionalUpdateMessage,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _optionalUpdateDismissedNotifier.value = true,
                      child: const Text('Later'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _optionalUpdateDismissedNotifier.value = true;
                        _openStoreUrl();
                      },
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
