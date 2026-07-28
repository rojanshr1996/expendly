import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/data_export_import_service.dart';
import '../../../../core/services/preference_service.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/pages/personal_profile_page.dart';
import '../../../profile/presentation/widgets/user_avatar.dart';
import '../widgets/settings_footer.dart';
import '../widgets/settings_premium_card.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_tile.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isBiometricEnabled;

  @override
  void initState() {
    super.initState();
    _isBiometricEnabled = getIt<PreferenceService>().isBiometricsEnabled;
    getIt<ProfileCubit>().loadProfile();
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
                  SizedBox(width: 10.w),
                  Text(
                    context.l10n.exportEncryptedData,
                    style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                context.l10n.exportPromptDesc,
                style: context.customTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 16.h),
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
              SizedBox(height: 20.h),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
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
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                context.l10n.exportSuccess,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16.sp),
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
            SizedBox(height: 12.h),
            Text(
              'File saved at:',
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            SizedBox(height: 4.h),
            SelectableText(
              filePath,
              style: context.customTypography.labelMediumMono.copyWith(
                color: colorScheme.primary,
                fontSize: 11.sp,
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
                  SizedBox(width: 10.w),
                  Text(
                    context.l10n.importEncryptedData,
                    style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: payloadController,
                maxLines: 3,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 12.sp),
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
              SizedBox(height: 12.h),
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
              SizedBox(height: 20.h),
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
                        setState(() {});
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

    return Scaffold(
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
            fontWeight: FontWeight.bold,
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
            // Premium Upgrade Card
            SettingsPremiumCard(
              onUpgradePressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.goProTitle),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),

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
                    SettingsTile(
                      icon: Icons.credit_card_rounded,
                      iconColor: colorScheme.tertiary,
                      title: context.l10n.subscriptionPlan,
                      subtitle: context.l10n.subscriptionPlanDesc,
                      onTap: () {},
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
                  icon: Icons.fingerprint_rounded,
                  iconColor: colorScheme.secondary,
                  title: context.l10n.biometricAuth,
                  trailing: Switch.adaptive(
                    value: _isBiometricEnabled,
                    activeColor: colorScheme.primary,
                    onChanged: (val) async {
                      setState(() {
                        _isBiometricEnabled = val;
                      });
                      await getIt<PreferenceService>().setBiometricsEnabled(val);
                    },
                  ),
                ),
                SettingsTile(
                  icon: Icons.pin_outlined,
                  iconColor: colorScheme.secondary,
                  title: context.l10n.changeSecurityPin,
                  onTap: () {},
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
                      color: colorScheme.primary.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      context.l10n.darkMode,
                      style: customTypography.labelMediumMono.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
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

            // Footer
            const SettingsFooter(),
          ],
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
