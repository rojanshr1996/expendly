import 'package:injectable/injectable.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _localDataSource;

  ProfileRepositoryImpl(this._localDataSource);

  @override
  Future<UserProfile?> getProfile() async {
    return await _localDataSource.getProfile();
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    return await _localDataSource.saveProfile(profile);
  }
}
