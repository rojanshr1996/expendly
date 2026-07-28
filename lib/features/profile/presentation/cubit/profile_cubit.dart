import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

@lazySingleton
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final profile = await _repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> saveProfile({
    required String name,
    String? email,
    String? phone,
    String? bio,
    String? imagePath,
  }) async {
    emit(const ProfileLoading());
    try {
      final currentProfile = state is ProfileLoaded ? (state as ProfileLoaded).profile : null;
      final profileToSave = UserProfile(
        id: currentProfile?.id,
        name: name,
        email: email,
        phone: phone,
        bio: bio,
        imagePath: imagePath,
        createdAt: currentProfile?.createdAt,
      );

      final savedProfile = await _repository.saveProfile(profileToSave);
      emit(ProfileLoaded(savedProfile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
