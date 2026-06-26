import '../../domain/entities/auth_user.dart';

/// Data model for the user object returned by the API.
class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.isVerified = false,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final bool isVerified;
  final String? avatarUrl;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        avatarUrl: json['avatar_url'] as String?,
      );

  AuthUser toEntity() => AuthUser(
        id: id,
        name: name,
        email: email,
        phone: phone,
        isVerified: isVerified,
        avatarUrl: avatarUrl,
      );
}
