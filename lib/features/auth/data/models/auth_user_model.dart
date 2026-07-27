import '../../domain/entities/auth_user.dart';

/// Data model for the user object returned by the API.
class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        id: json['id'].toString(),
        name: json['full_name'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone_number'] as String?,
        avatarUrl: json['profile_photo_url'] as String?,
      );

  AuthUser toEntity() => AuthUser(
        id: id,
        name: name,
        email: email,
        phone: phone,
        isVerified: true,
        avatarUrl: avatarUrl,
      );
}
