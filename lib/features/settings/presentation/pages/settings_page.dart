import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/models/backup_result.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/data_export_import_service.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/widgets/status_components.dart';
import '../../../../core/ads/ad_helper.dart';
import '../../../../core/ads/widgets/banner_ad_widget.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/pages/personal_profile_page.dart';
import '../../../profile/presentation/widgets/user_avatar.dart';
import '../../../security/presentation/widgets/change_pin_modal.dart';
import '../widgets/currency_selection_modal.dart';
import '../widgets/settings_footer.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_tile.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> _isBiometricEnabledNotifier;
  final ValueNotifier<bool> _isLoggingOutNotifier = ValueNotifier<bool>(false);

  late final AnimationController _logoutAnimationController;
  late final Animation<double> _logoutAnimation;

  @override
  void initState() {
    super.initState();
    final pref = getIt<PreferenceService>();
    final isBiometric = pref.isBiometricsEnabled;
    _isBiometricEnabledNotifier = ValueNotifier<bool>(isBiometric);

    _logoutAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _logoutAnimation = CurvedAnimation(
      parent: _logoutAnimationController,
      curve: Curves.easeInOutCubic,
    );

    getIt<ProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    _isBiometricEnabledNotifier.dispose();
    _isLoggingOutNotifier.dispose();
    _logoutAnimationController.dispose();
    super.dispose();
  }

  Future<void> _toggleBiometrics(bool val) async {
    final pref = getIt<PreferenceService>();
    if (!pref.isSecurityPinSet) {
      StatusComponents.showToast(
        context,
        message: context.l10n.pinRequiredForBiometrics,
        isError: true,
      );
      await ChangePinModal.show(context);
      if (mounted) setState(() {});
      return;
    }

    if (val) {
      final reason = context.l10n.biometricReason;
      final notAvailableMsg = context.l10n.biometricNotAvailable;
      final failedMsg = context.l10n.biometricAuthFailed;

      final bioService = getIt<BiometricAuthService>();
      final isAvailable = await bioService.isBiometricAvailable();
      if (!isAvailable) {
        if (mounted) {
          StatusComponents.showToast(
            context,
            message: notAvailableMsg,
            isError: true,
          );
        }
        return;
      }

      final authenticated = await bioService.authenticate(
        localizedReason: reason,
      );

      if (!authenticated) {
        if (mounted) {
          StatusComponents.showToast(
            context,
            message: failedMsg,
            isError: true,
          );
        }
        return;
      }
    }

    _isBiometricEnabledNotifier.value = val;
    await pref.setBiometricsEnabled(val);
    if (mounted) setState(() {});
  }

  /// Triggers a manual CSV backup and shows the result as a toast.
  Future<void> _backupNow() async {
    try {
      final result = await getIt<BackupService>().performBackup();
      if (!mounted) return;
      if (result.isSuccess) {
        StatusComponents.showToast(
          context,
          message: context.l10n.backupSuccess,
          isSuccess: true,
        );
        setState(() {}); // refresh last-backup timestamp in tile subtitle
      } else {
        StatusComponents.showToast(
          context,
          message: result.errorMessage ?? context.l10n.backupFailed,
          isError: true,
        );
      }
    } catch (e) {
      AppLogger.e('SettingsPage: manual backup failed', e);
      if (!mounted) return;
      StatusComponents.showToast(context,
          message: context.l10n.backupFailed, isError: true);
    }
  }

  void _showRestoreSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => _CsvRestoreSheet(
        parentContext: context,
        onImportDone: (result) {
          if (!mounted) return;
          setState(() {}); // refresh last-backup tile
          _showImportSummaryDialog(context, result);
        },
      ),
    );
  }

  void _showImportSummaryDialog(BuildContext context, CsvImportResult result) {
    final colorScheme = context.colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerLow,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: colorScheme.primary, size: 24.sp),
            horizontalMarginSmall,
            Expanded(
              child: Text(
                context.l10n.importSummaryTitle,
                style: context.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeights.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.importSummaryBody(
                result.transactionsImported,
                result.categoriesImported,
                result.budgetsImported,
              ),
              style: context.customTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (result.skippedCount > 0) ...[
              verticalMarginXXSmall,
              Text(
                '${result.skippedCount} row(s) skipped.',
                style: context.customTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (result.errors.isNotEmpty) ...[
              verticalMarginXXSmall,
              Text(
                result.errors.take(3).join('\n'),
                style: context.customTypography.bodyMedium.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.done,
                style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  String _formatLastBackupDate(String isoString) {
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: colorScheme.error, size: 24.sp),
            horizontalMarginSmall,
            Expanded(
              child: Text(
                context.l10n.logoutConfirmTitle,
                style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeights.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.logoutConfirmMessage,
          style: context.customTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              _isLoggingOutNotifier.value = true;
              await _logoutAnimationController.forward(from: 0.0);
              await getIt<PreferenceService>().logout();
              if (context.mounted) {
                context.router.replaceAll([const SecurityVerificationRoute()]);
              }
            },
            child: Text(
              context.l10n.logout,
              style: TextStyle(
                color: colorScheme.onError,
                fontWeight: FontWeights.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    final pref = getIt<PreferenceService>();

    return AnimatedBuilder(
      animation: _logoutAnimation,
      builder: (context, child) {
        final progress = _logoutAnimation.value;
        final scale = 1.0 - (progress * 0.06);
        final opacity = (1.0 - (progress * 0.8)).clamp(0.0, 1.0);

        return Stack(
          children: [
            Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
            if (progress > 0)
              Positioned.fill(
                child: Container(
                  color: colorScheme.surface.withValues(alpha: progress * 0.75),
                  child: Center(
                    child: Transform.scale(
                      scale: 0.8 + (progress * 0.3),
                      child: Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.error.withValues(alpha: 0.15),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.5),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.error
                                  .withValues(alpha: 0.3 * progress),
                              blurRadius: 30.r,
                              spreadRadius: 4.r,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 48.sp,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surfaceContainerLow,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
            onPressed: () => context.router.maybePop(),
          ),
          title: Text(
            context.l10n.settings,
            style: (textTheme.titleLarge ?? const TextStyle()).copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeights.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              SettingsSectionHeader(title: context.l10n.accountSection),
              BlocBuilder<ProfileCubit, ProfileState>(
                bloc: getIt<ProfileCubit>(),
                builder: (context, state) {
                  final profile = state is ProfileLoaded ? state.profile : null;
                  final hasProfile = profile != null;

                  return _buildGroupedCard(
                    context,
                    children: [
                      SettingsTile(
                        icon: Icons.person_outline_rounded,
                        iconColor: colorScheme.primary,
                        title: context.l10n.personalProfile,
                        subtitle: hasProfile
                            ? (profile.email != null &&
                                    profile.email!.isNotEmpty
                                ? '${profile.name} • ${profile.email}'
                                : profile.name)
                            : context.l10n.personalProfileDesc,
                        trailing: hasProfile
                            ? UserAvatar(
                                imagePath: profile.imagePath,
                                radius: 16.r,
                                borderWidth: 1.0,
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const PersonalProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              // Security Section
              SettingsSectionHeader(title: context.l10n.securitySection),
              _buildGroupedCard(
                context,
                children: [
                  SettingsTile(
                    icon: Icons.pin_outlined,
                    iconColor: colorScheme.secondary,
                    title: pref.isSecurityPinSet
                        ? context.l10n.changeSecurityPin
                        : context.l10n.setupSecurityPin,
                    subtitle: pref.isSecurityPinSet
                        ? context.l10n.pinConfigured
                        : context.l10n.setupSecurityPinDesc,
                    onTap: () async {
                      await ChangePinModal.show(context);
                      if (mounted) setState(() {});
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isBiometricEnabledNotifier,
                    builder: (context, isBiometricEnabled, _) {
                      final hasPin = pref.isSecurityPinSet;

                      return SettingsTile(
                        icon: Icons.fingerprint_rounded,
                        iconColor: colorScheme.secondary,
                        title: context.l10n.biometricAuth,
                        subtitle: !hasPin
                            ? context.l10n.pinRequiredForBiometrics
                            : null,
                        onTap: () => _toggleBiometrics(!isBiometricEnabled),
                        trailing: Switch.adaptive(
                          value: isBiometricEnabled && hasPin,
                          activeTrackColor: colorScheme.primary,
                          onChanged: (val) => _toggleBiometrics(val),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Banner Ad below Security Section
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: BannerAdWidget(adUnitId: AdHelper.bannerAdUnitId),
              ),

              // Appearance Section
              SettingsSectionHeader(title: context.l10n.appearanceSection),
              _buildGroupedCard(
                context,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: pref.themeModeNotifier,
                    builder: (context, themeMode, _) {
                      final isDark = themeMode != 'light';

                      return SettingsTile(
                        icon: isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        iconColor: colorScheme.onSurfaceVariant,
                        title: context.l10n.themeLabel,
                        subtitle: isDark
                            ? context.l10n.darkMode
                            : context.l10n.lightMode,
                        onTap: () {
                          pref.setThemeMode(isDark ? 'light' : 'dark');
                        },
                        trailing: Switch.adaptive(
                          value: isDark,
                          activeTrackColor: colorScheme.primary,
                          onChanged: (val) {
                            pref.setThemeMode(val ? 'dark' : 'light');
                          },
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: pref.currencyCodeNotifier,
                    builder: (context, code, _) {
                      return ValueListenableBuilder<String>(
                        valueListenable: pref.currencySymbolNotifier,
                        builder: (context, symbol, _) {
                          return SettingsTile(
                            icon: Icons.payments_outlined,
                            iconColor: colorScheme.onSurfaceVariant,
                            title: context.l10n.primaryCurrency,
                            trailing: Text(
                              '$code ($symbol)',
                              style: customTypography.labelMediumMono.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                            onTap: () => CurrencySelectionModal.show(context),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

              // Data Management Section
              SettingsSectionHeader(title: context.l10n.dataManagementSection),
              _buildGroupedCard(
                context,
                children: [
                  // ── Auto CSV Backup status tile ──
                  SettingsTile(
                    icon: Icons.backup_rounded,
                    iconColor: colorScheme.primary,
                    title: context.l10n.csvBackupTitle,
                    subtitle: () {
                      final last = pref.lastSnapshotAt;
                      if (last == null) return context.l10n.neverBackedUp;
                      return context.l10n
                          .lastBackupTime(_formatLastBackupDate(last));
                    }(),
                    trailing: TextButton(
                      onPressed: _backupNow,
                      child: Text(
                        context.l10n.backupNow,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeights.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  // ── Export transactions CSV (Sheets / Excel) ──
                  SettingsTile(
                    icon: Icons.share_rounded,
                    iconColor: colorScheme.secondary,
                    title: context.l10n.exportDataCsv,
                    subtitle: context.l10n.exportCsvDesc,
                    onTap: () async {
                      try {
                        final filePath = await getIt<DataExportImportService>()
                            .exportDataToCsv(openAfterExport: false);
                        if (!context.mounted) return;
                        final xFile = XFile(filePath);
                        await SharePlus.instance.share(ShareParams(
                            files: [xFile], text: 'My Transactions Data'));
                      } catch (e) {
                        AppLogger.e('SettingsPage: CSV export/share failed', e);
                        if (!context.mounted) return;
                        StatusComponents.showToast(
                          context,
                          message: context.l10n.csvExportFailedGeneric,
                          isError: true,
                        );
                      }
                    },
                  ),
                  // ── Restore from backup CSV ──
                  SettingsTile(
                    icon: Icons.restore_rounded,
                    iconColor: colorScheme.tertiary,
                    title: context.l10n.restoreCsvTitle,
                    subtitle: context.l10n.restoreCsvDesc,
                    onTap: () => _showRestoreSheet(context),
                  ),
                ],
              ),

              // Support & Legal Section
              SettingsSectionHeader(title: context.l10n.supportAndLegalSection),
              _buildGroupedCard(
                context,
                children: [
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: colorScheme.primary,
                    title: context.l10n.aboutExpendly,
                    subtitle: context.l10n.aboutExpendlySubtitle,
                    onTap: () => context.router.push(const AboutRoute()),
                  ),
                  SettingsTile(
                    icon: Icons.gavel_rounded,
                    iconColor: colorScheme.tertiary,
                    title: context.l10n.termsAndConditions,
                    subtitle: context.l10n.termsDesc,
                    onTap: () => UrlUtils.launchExternalUrl(
                      'https://expendly.web.app/terms',
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: colorScheme.primary,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () => UrlUtils.launchExternalUrl(
                      'https://expendly.web.app/privacy',
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: colorScheme.secondary,
                    title: context.l10n.helpAndSupport,
                    subtitle: context.l10n.helpSupportDesc,
                    onTap: () => context.router.push(const HelpSupportRoute()),
                  ),
                ],
              ),

              // Footer
              const SettingsFooter(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: pref.canLogout
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  side: BorderSide(
                    color: pref.canLogout
                        ? colorScheme.error.withValues(alpha: 0.5)
                        : colorScheme.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(Icons.logout_rounded, size: 20.sp),
                label: Text(
                  context.l10n.logout,
                  style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                    fontWeight: FontWeights.bold,
                    color: pref.canLogout
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                onPressed: () {
                  if (pref.canLogout) {
                    _showLogoutDialog(context);
                  } else {
                    StatusComponents.showToast(
                      context,
                      message: context.l10n.noSecurityPinForLogout,
                      isError: true,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedCard(BuildContext context,
      {required List<Widget> children}) {
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for restoring data from [kBackupFileName].
///
/// If the app has a Security PIN set, the user must enter it before the
/// import runs. The PIN is used for **authorization only** — it is never
/// written into or read from the backup file.
class _CsvRestoreSheet extends StatefulWidget {
  const _CsvRestoreSheet({
    required this.parentContext,
    required this.onImportDone,
  });

  final BuildContext parentContext;
  final void Function(CsvImportResult result) onImportDone;

  @override
  State<_CsvRestoreSheet> createState() => _CsvRestoreSheetState();
}

class _CsvRestoreSheetState extends State<_CsvRestoreSheet> {
  final TextEditingController _pinController = TextEditingController();
  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isBusyNotifier = ValueNotifier<bool>(false);

  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedRawContent;
  int? _selectedFileSize;
  DateTime? _selectedFileDate;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _findBackup();
  }

  Future<void> _findBackup() async {
    try {
      final file = await getIt<DataExportImportService>().findBackupFile();
      if (file != null) {
        try {
          final raf = await file.open(mode: FileMode.read);
          await raf.close();
          // Accessible local POSIX file
          _selectedFilePath = file.path;
          _selectedFileName = p.basename(file.path);
          _selectedFileSize = file.lengthSync();
          _selectedFileDate = file.statSync().modified;
        } catch (e) {
          // Reinstalled app or restricted path — POSIX read denied.
          // Leave _selectedFilePath null so user selects via FilePicker.
          AppLogger.w(
              '_CsvRestoreSheet: Auto-found file exists but POSIX read is denied: $e');
        }
      }
    } catch (e) {
      AppLogger.d('_CsvRestoreSheet: _findBackup error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _errorNotifier.dispose();
    _isBusyNotifier.dispose();
    super.dispose();
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _pickBackupFile() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.single;
      final filePath = file.path;

      if (filePath != null && p.extension(filePath).toLowerCase() != '.csv') {
        _errorNotifier.value = 'Please select a .csv backup file.';
        return;
      }

      String? rawContent;
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        try {
          rawContent = utf8.decode(file.bytes!);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _selectedFilePath = filePath;
          _selectedFileName = file.name;
          _selectedFileSize = file.size;
          _selectedFileDate = DateTime.now();
          _selectedRawContent = rawContent;
          _errorNotifier.value = null;
        });
      }
    } catch (e) {
      AppLogger.e('_CsvRestoreSheet: file picker error', e);
      if (mounted) _errorNotifier.value = context.l10n.csvImportFailed;
    }
  }

  Future<void> _restore() async {
    final pref = getIt<PreferenceService>();

    if (_selectedFilePath == null &&
        (_selectedRawContent == null || _selectedRawContent!.isEmpty)) {
      _errorNotifier.value = 'Please select a backup file first.';
      return;
    }

    // PIN check — authorization only
    if (pref.isSecurityPinSet) {
      final enteredPin = _pinController.text.trim();
      if (enteredPin.isEmpty) {
        _errorNotifier.value = context.l10n.pinRequiredForRestore;
        return;
      }
      if (enteredPin != pref.securityPin) {
        _errorNotifier.value = context.l10n.pinIncorrect;
        return;
      }
    }

    _errorNotifier.value = null;
    _isBusyNotifier.value = true;

    final result = await getIt<DataExportImportService>().importBackupCsv(
      _selectedFilePath ?? '',
      rawContent: _selectedRawContent,
    );

    if (!mounted) return;
    _isBusyNotifier.value = false;

    if (!result.isSuccess) {
      _errorNotifier.value = result.errors.isNotEmpty
          ? result.errors.first
          : context.l10n.csvImportFailed;
      return;
    }

    await getIt<PreferenceService>()
        .setLastSnapshotAt(DateTime.now().toIso8601String());

    if (!mounted) return;
    Navigator.pop(context);
    widget.onImportDone(result);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final pref = getIt<PreferenceService>();
    final hasSelectedFile = _selectedFilePath != null ||
        (_selectedRawContent != null && _selectedRawContent!.isNotEmpty);

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.restore_rounded,
                    color: colorScheme.primary, size: 24.sp),
                horizontalMarginSmall,
                Text(
                  context.l10n.restoreCsvTitle,
                  style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeights.bold,
                  ),
                ),
              ],
            ),
            verticalMarginMedium,

            // ── Backup file card ──────────────────────────────────────────
            if (_isLoading)
              const Center(child: CircularProgressIndicator.adaptive())
            else if (hasSelectedFile) ...[
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: colorScheme.primary, size: 28.sp),
                    horizontalMarginSmall,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName ?? kBackupFileName,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeights.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${_formatDate(_selectedFileDate)}'
                            '${_formatSize(_selectedFileSize).isNotEmpty ? " · ${_formatSize(_selectedFileSize)}" : ""}'
                            ' · Selected ✓',
                            style: context.customTypography.labelMediumMono
                                .copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _pickBackupFile,
                      child: Text(
                        'Change',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeights.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: colorScheme.primary, size: 20.sp),
                    horizontalMarginSmall,
                    Expanded(
                      child: Text(
                        'Tap "Browse & Restore Backup" below to select your expendly_backup file from Downloads → Expendly.',
                        style: context.customTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── PIN field (shown once file is selected & app has a PIN) ───
            if (hasSelectedFile && pref.isSecurityPinSet) ...[
              verticalMarginMedium,
              Text(
                context.l10n.pinRequiredForRestore,
                style: context.customTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              verticalMarginSmall,
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: context.customTypography.bodyMedium
                    .copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: context.l10n.enterPin,
                  counterText: '',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
            ],

            // ── Error banner ─────────────────────────────────────────────
            _ImportErrorBanner(messageNotifier: _errorNotifier),
            verticalMarginMedium,

            // ── Single Primary Action Button ─────────────────────────────
            ValueListenableBuilder<bool>(
              valueListenable: _isBusyNotifier,
              builder: (context, isBusy, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd),
                      disabledBackgroundColor:
                          colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    onPressed: isBusy
                        ? null
                        : (hasSelectedFile ? _restore : _pickBackupFile),
                    icon: isBusy
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            hasSelectedFile
                                ? Icons.restore_rounded
                                : Icons.folder_open_rounded,
                            size: 20.sp,
                          ),
                    label: Text(
                      hasSelectedFile
                          ? context.l10n.restore
                          : 'Browse & Restore Backup',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeights.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (!hasSelectedFile) ...[
              verticalMarginSmall,
              Text(
                'Navigate to Downloads → Expendly in the file browser to find your expendly backup file.',
                style: context.customTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error strip shown inside bottom sheets.
///
/// The sheet is drawn above the Scaffold, so SnackBars appear behind it.
/// Failures that keep the sheet open use this banner instead.
class _ImportErrorBanner extends StatelessWidget {
  const _ImportErrorBanner({required this.messageNotifier});

  final ValueNotifier<String?> messageNotifier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return ValueListenableBuilder<String?>(
      valueListenable: messageNotifier,
      builder: (context, message, _) {
        if (message == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderDefault,
              border:
                  Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: colorScheme.error, size: 18.sp),
                horizontalMarginXSmall,
                Expanded(
                  child: Text(
                    message,
                    style: context.customTypography.bodyMedium
                        .copyWith(color: colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
