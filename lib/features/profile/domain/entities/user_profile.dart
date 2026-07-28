import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? bio;
  final String? imagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.bio,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        bio,
        imagePath,
        createdAt,
        updatedAt,
      ];
}
