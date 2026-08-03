import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfile?> getProfile();
  Future<UserProfile> saveProfile(UserProfile profile);
}

@LazySingleton(as: ProfileLocalDataSource)
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final AppDatabase _db;

  ProfileLocalDataSourceImpl(this._db);

  @override
  Future<UserProfile?> getProfile() async {
    final profiles = await _db.select(_db.userProfiles).get();
    if (profiles.isEmpty) return null;

    final p = profiles.first;
    return UserProfile(
      id: p.id,
      name: p.name,
      email: p.email,
      phone: p.phone,
      bio: p.bio,
      imagePath: p.imagePath,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    final now = DateTime.now();
    final existingList = await _db.select(_db.userProfiles).get();

    if (existingList.isNotEmpty) {
      final existing = existingList.first;
      await (_db.update(_db.userProfiles)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        UserProfilesCompanion(
          name: Value(profile.name),
          email: Value(profile.email),
          phone: Value(profile.phone),
          bio: Value(profile.bio),
          imagePath: Value(profile.imagePath),
          updatedAt: Value(now),
        ),
      );
      return profile.copyWith(
        id: existing.id,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    } else {
      final id = await _db.into(_db.userProfiles).insert(
            UserProfilesCompanion.insert(
              name: profile.name,
              email: Value(profile.email),
              phone: Value(profile.phone),
              bio: Value(profile.bio),
              imagePath: Value(profile.imagePath),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      return profile.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
      );
    }
  }
}
