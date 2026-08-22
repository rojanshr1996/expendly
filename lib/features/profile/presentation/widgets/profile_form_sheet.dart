import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import 'profile_avatar_picker.dart';

/// Bottom sheet modal to add or edit user's personal profile information.
class ProfileFormSheet extends StatefulWidget {
  final UserProfile? initialProfile;

  const ProfileFormSheet({
    super.key,
    this.initialProfile,
  });

  static Future<void> show(BuildContext context,
      {UserProfile? initialProfile}) {
    return AdaptiveSheet.show<void>(
      context: context,
      isScrollControlled: true,
      maxDialogWidth: 540.0,
      builder: (ctx) => ProfileFormSheet(initialProfile: initialProfile),
    );
  }

  @override
  State<ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends State<ProfileFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialProfile?.name ?? '');
    _emailController =
        TextEditingController(text: widget.initialProfile?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.initialProfile?.phone ?? '');
    _bioController =
        TextEditingController(text: widget.initialProfile?.bio ?? '');
    _selectedImagePath = widget.initialProfile?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
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

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim();
      final phone = _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim();
      final bio = _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim();

      await context.read<ProfileCubit>().saveProfile(
            name: name,
            email: email,
            phone: phone,
            bio: bio,
            imagePath: _selectedImagePath,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.profileSavedSuccess),
            backgroundColor: context.colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet = Breakpoints.isTablet(context);
    final customColors = context.customColors;
    final isEditing = widget.initialProfile != null;
    final maxHeight =
        isTablet ? 640.0 : MediaQuery.of(context).size.height * 0.88;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color:
              isLight ? colorScheme.surface : colorScheme.surfaceContainerHigh,
          borderRadius: isTablet
              ? BorderRadius.circular(24.0)
              : BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(
            color: isLight
                ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                : customColors.glassStroke.withValues(alpha: 0.45),
            width: 1.0,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 20.w,
              vertical: isTablet ? 20.0 : 16.h,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle (phone only)
                    if (!isTablet) ...[
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isLight
                                ? colorScheme.outline.withValues(alpha: 0.4)
                                : colorScheme.outlineVariant
                                    .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    // Header title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isEditing
                                  ? Icons.edit_note_rounded
                                  : Icons.person_add_alt_1_rounded,
                              color: colorScheme.primary,
                              size: 24.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              isEditing ? l10n.editProfile : l10n.setUpProfile,
                              style:
                                  (textTheme.titleMedium ?? const TextStyle())
                                      .copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Avatar picker widget
                    ProfileAvatarPicker(
                      imagePath: _selectedImagePath,
                      onTapPick: _pickImageFromGallery,
                      onTapRemove: _selectedImagePath != null
                          ? () => setState(() => _selectedImagePath = null)
                          : null,
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        l10n.tapAvatarChoosePhoto,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Full Name field
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: '${l10n.fullNameLabel} *',
                        hintText: l10n.yourNameHint,
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            color: colorScheme.primary),
                        filled: true,
                        fillColor: isLight
                            ? colorScheme.surfaceContainerLow
                            : colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.pleaseEnterYourName;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: l10n.emailAddressLabel,
                        hintText: l10n.emailHint,
                        prefixIcon: Icon(Icons.email_outlined,
                            color: colorScheme.secondary),
                        filled: true,
                        fillColor: isLight
                            ? colorScheme.surfaceContainerLow
                            : colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        hintText: 'e.g. +1 234 567 8900',
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: colorScheme.tertiary),
                        filled: true,
                        fillColor: isLight
                            ? colorScheme.surfaceContainerLow
                            : colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Bio / Notes field
                    TextFormField(
                      controller: _bioController,
                      maxLines: 2,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: l10n.professionalBioLabel,
                        hintText: l10n.bioHint,
                        prefixIcon: Icon(Icons.info_outline_rounded,
                            color: colorScheme.outline),
                        filled: true,
                        fillColor: isLight
                            ? colorScheme.surfaceContainerLow
                            : colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Save button
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
                        onPressed: _onSave,
                        child: Text(
                          l10n.saveChanges,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
