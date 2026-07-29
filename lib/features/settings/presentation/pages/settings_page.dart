import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/data_export_import_service.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/status_components.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/pages/personal_profile_page.dart';
import '../../../profile/presentation/widgets/user_avatar.dart';
import '../../../security/presentation/widgets/change_pin_modal.dart';
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
    final isBiometric = getIt<PreferenceService>().isBiometricsEnabled;
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

  void _showExportDialog(BuildContext context) {
    final passphraseController = TextEditingController();
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security_rounded, color: colorScheme.primary, size: 24.sp),
                  horizontalMarginSmall,
                  Text(
                    context.l10n.exportEncryptedData,
                    style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ],
              ),
              verticalMarginSmall,
              Text(
                context.l10n.exportPromptDesc,
                style: context.customTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              verticalMarginMedium,
              TextField(
                controller: passphraseController,
                obscureText: true,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: context.l10n.passphrasePrompt,
                  hintText: context.l10n.passphraseHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
              verticalMarginMedium,
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    final passphrase = passphraseController.text.trim().isEmpty
                        ? null
                        : passphraseController.text.trim();
                    Navigator.pop(ctx);
                    try {
                      final result = await getIt<DataExportImportService>()
                          .exportEncryptedData(passphrase: passphrase);
                      if (context.mounted) {
                        _showExportResultDialog(context, result);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.exportFailed(e.toString())),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    context.l10n.exportEncryptButton,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeights.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExportResultDialog(BuildContext context, Map<String, dynamic> result) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final payload = result['payload'] as String;
    final filePath = result['filePath'] as String;
    final count = result['transactionCount'] as int;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerLow,
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 24.sp),
            horizontalMarginSmall,
            Expanded(
              child: Text(
                context.l10n.exportSuccess,
                style: textTheme.bodyLarge?.copyWith(
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
              'Backup generated with $count transactions encrypted via AES-256.',
              style: context.customTypography.bodyMedium,
            ),
            verticalMarginSmall,
            Text(
              'File saved at:',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeights.bold,
                color: colorScheme.onSurface,
              ),
            ),
            verticalMarginXXSmall,
            SelectableText(
              filePath,
              style: context.customTypography.labelMediumMono.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: payload));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.encryptedPayloadCopied),
                  backgroundColor: colorScheme.primary,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.copyEncryptedText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.done, style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final payloadController = TextEditingController();
    final passphraseController = TextEditingController();
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.file_upload_rounded, color: colorScheme.primary, size: 24.sp),
                  horizontalMarginSmall,
                  Text(
                    context.l10n.importEncryptedData,
                    style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ],
              ),
              verticalMarginSmall,
              TextField(
                controller: payloadController,
                maxLines: 3,
                style: context.customTypography.bodyMedium.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: context.l10n.pasteEncryptedPayload,
                  hintText: context.l10n.pastePayloadHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
              verticalMarginSmall,
              TextField(
                controller: passphraseController,
                obscureText: true,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: context.l10n.passphrasePrompt,
                  hintText: context.l10n.passphraseHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
              verticalMarginMedium,
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    final payload = payloadController.text.trim();
                    if (payload.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.pleasePastePayload),
                          backgroundColor: colorScheme.error,
                        ),
                      );
                      return;
                    }

                    final passphrase = passphraseController.text.trim().isEmpty
                        ? null
                        : passphraseController.text.trim();
                    Navigator.pop(ctx);

                    try {
                      final count = await getIt<DataExportImportService>()
                          .importEncryptedData(payload, passphrase: passphrase);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${context.l10n.importSuccess} ($count transactions restored)'),
                            backgroundColor: colorScheme.primary,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.importFailedKey),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    context.l10n.decryptRestoreData,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeights.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
    final currencyCode = pref.currencyCode;
    final currencySymbol = pref.currencySymbol;
    final currencyDisplay = '$currencyCode ($currencySymbol)';

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
                              color: colorScheme.error.withValues(alpha: 0.3 * progress),
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
                          ? (profile.email != null && profile.email!.isNotEmpty
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
                ValueListenableBuilder<bool>(
                  valueListenable: _isBiometricEnabledNotifier,
                  builder: (context, isBiometricEnabled, _) {
                    return SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      iconColor: colorScheme.secondary,
                      title: context.l10n.biometricAuth,
                      trailing: Switch.adaptive(
                        value: isBiometricEnabled,
                        activeColor: colorScheme.primary,
                        onChanged: (val) async {
                          if (val) {
                            if (!context.mounted) return;
                            final reason = context.l10n.biometricReason;
                            final notAvailableMsg = context.l10n.biometricNotAvailable;
                            final failedMsg = context.l10n.biometricAuthFailed;

                            final bioService = getIt<BiometricAuthService>();
                            final isAvailable = await bioService.isBiometricAvailable();
                            if (!isAvailable) {
                              if (context.mounted) {
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
                              if (context.mounted) {
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
                          await getIt<PreferenceService>().setBiometricsEnabled(val);
                        },
                      ),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.pin_outlined,
                  iconColor: colorScheme.secondary,
                  title: context.l10n.changeSecurityPin,
                  onTap: () => ChangePinModal.show(context),
                ),
              ],
            ),

            // Appearance Section
            SettingsSectionHeader(title: context.l10n.appearanceSection),
            _buildGroupedCard(
              context,
              children: [
                SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: colorScheme.onSurfaceVariant,
                  title: context.l10n.themeLabel,
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      context.l10n.darkMode,
                      style: customTypography.labelMediumMono.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeights.bold,
                      ),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.payments_outlined,
                  iconColor: colorScheme.onSurfaceVariant,
                  title: context.l10n.primaryCurrency,
                  trailing: Text(
                    currencyDisplay,
                    style: customTypography.labelMediumMono.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Data Management Section
            SettingsSectionHeader(title: context.l10n.dataManagementSection),
            _buildGroupedCard(
              context,
              children: [
                SettingsTile(
                  icon: Icons.table_chart_outlined,
                  iconColor: colorScheme.secondary,
                  title: context.l10n.exportDataCsv,
                  subtitle: context.l10n.exportCsvDesc,
                  onTap: () async {
                    try {
                      final filePath = await getIt<DataExportImportService>()
                          .exportDataToCsv(openAfterExport: true);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.csvExportedTo(p.basename(filePath))),
                            backgroundColor: colorScheme.secondary,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.csvExportFailed(e.toString())),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                ),
                SettingsTile(
                  icon: Icons.file_download_outlined,
                  iconColor: colorScheme.primary,
                  title: context.l10n.exportEncryptedData,
                  subtitle: context.l10n.exportEncryptedDataDesc,
                  onTap: () => _showExportDialog(context),
                ),
                SettingsTile(
                  icon: Icons.file_upload_outlined,
                  iconColor: colorScheme.tertiary,
                  title: context.l10n.importEncryptedData,
                  subtitle: context.l10n.importEncryptedDataDesc,
                  onTap: () => _showImportDialog(context),
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
                  onTap: () => context.router.push(const TermsConditionsRoute()),
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
                foregroundColor: pref.canLogout ? colorScheme.error : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                side: BorderSide(
                  color: pref.canLogout ? colorScheme.error.withValues(alpha: 0.5) : colorScheme.outlineVariant,
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
                  color: pref.canLogout ? colorScheme.error : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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

  Widget _buildGroupedCard(BuildContext context, {required List<Widget> children}) {
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
