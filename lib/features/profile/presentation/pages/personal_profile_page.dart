import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_avatar_picker.dart';

@RoutePage()
class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _selectedImagePath;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    final state = getIt<ProfileCubit>().state;
    if (state is ProfileLoaded && state.profile != null) {
      _populateProfile(state.profile!);
    } else {
      getIt<ProfileCubit>().loadProfile();
    }
  }

  void _populateProfile(UserProfile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email ?? '';
    _selectedImagePath = profile.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges(UserProfile? profile) {
    if (profile == null) {
      return _nameController.text.trim().isNotEmpty ||
          _emailController.text.trim().isNotEmpty ||
          _selectedImagePath != null;
    }
    final currentName = _nameController.text.trim();
    final currentEmail = _emailController.text.trim();
    final savedName = profile.name.trim();
    final savedEmail = (profile.email ?? '').trim();

    return currentName != savedName ||
        currentEmail != savedEmail ||
        _selectedImagePath != profile.imagePath;
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToSelectPhoto(e.toString())),
            backgroundColor: context.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? null
        : _emailController.text.trim();

    try {
      await getIt<ProfileCubit>().saveProfile(
        name: name,
        email: email,
        imagePath: _selectedImagePath,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(context.l10n.profileSavedSuccess),
              ],
            ),
            backgroundColor: context.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToSaveProfile(e.toString())),
            backgroundColor: context.colorScheme.error,
          ),
        );
      }
    }
  }

  void _discardChanges(UserProfile? profile) {
    if (profile != null) {
      setState(() {
        _populateProfile(profile);
      });
    } else {
      setState(() {
        _nameController.clear();
        _emailController.clear();
        _selectedImagePath = null;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.changesDiscarded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    final labelStyle = customTypography.labelMediumMono.copyWith(
      color: colorScheme.primary,
      fontSize: 12.sp,
      letterSpacing: 1.2,
      fontWeight: FontWeight.bold,
    );

    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: getIt<ProfileCubit>(),
      listener: (context, state) {
        if (state is ProfileLoaded && state.profile != null && !_isSaving) {
          _populateProfile(state.profile!);
        }
      },
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;
        final rawId = profile?.id != null
            ? profile!.id.toString().padLeft(4, '0')
            : '8829';
        final accountId = l10n.accountId(rawId);
        final showDiscard = _hasUnsavedChanges(profile);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          extendBodyBehindAppBar: true,
          appBar: LiquidGlassAppBar(
            titleText: l10n.personalProfile,
            onLeadingPressed: () => context.router.maybePop(),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16.h,
              bottom: 20.h,
            ),
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        Breakpoints.isTablet(context) ? 680.0 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar Section
                      SizedBox(height: 8.h),
                      ProfileAvatarPicker(
                        imagePath: _selectedImagePath,
                        onTapPick: _pickImageFromGallery,
                        onTapRemove: _selectedImagePath != null
                            ? () => setState(() => _selectedImagePath = null)
                            : null,
                      ),
                      SizedBox(height: 12.h),

                      // Account ID text
                      Text(
                        accountId,
                        style: customTypography.labelMediumMono.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Form Fields using common AppTextField component
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name Field
                          AppTextField(
                            controller: _nameController,
                            labelText: l10n.fullNameLabel,
                            labelStyle: labelStyle,
                            hintText: l10n.yourNameHint,
                            onChanged: (_) => setState(() {}),
                            prefixIcon: Icon(
                              Icons.person_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 20.sp,
                            ),
                            fillColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(16.r),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.pleaseEnterYourName;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Email Address Field
                          AppTextField(
                            controller: _emailController,
                            labelText: l10n.emailAddressLabel,
                            labelStyle: labelStyle,
                            hintText: l10n.emailHint,
                            onChanged: (_) => setState(() {}),
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: colorScheme.onSurfaceVariant,
                              size: 20.sp,
                            ),
                            fillColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          SizedBox(height: 32.h),

                          // Action Buttons
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              onPressed: _isSaving ? null : _saveProfile,
                              child: _isSaving
                                  ? SizedBox(
                                      width: 24.w,
                                      height: 24.w,
                                      child: CircularProgressIndicator(
                                        color: colorScheme.onPrimary,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      l10n.saveChanges,
                                      style: (textTheme.titleMedium ??
                                              const TextStyle())
                                          .copyWith(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                            ),
                          ),
                          if (showDiscard) ...[
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.onSurfaceVariant,
                                  side: BorderSide(
                                      color: colorScheme.outlineVariant),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                onPressed: () => _discardChanges(profile),
                                child: Text(
                                  l10n.discardChanges,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
