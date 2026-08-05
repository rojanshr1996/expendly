import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();
  Future<UserProfile> saveProfile(UserProfile profile);
}
