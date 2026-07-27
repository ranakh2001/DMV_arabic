import '../../domain/entities/user_profile.dart';

/// Data model for the `/users/profile` response object.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    this.stateId,
  });

  final String id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String? profilePhotoUrl;
  final int? stateId;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
        id: json['id'].toString(),
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String?,
        phoneNumber: json['phone_number'] as String? ?? '',
        profilePhotoUrl: json['profile_photo_url'] as String?,
        stateId: _parseStateId(json),
      );

  static int? _parseStateId(Map<String, dynamic> json) {
    final state = json['state'];
    if (state is Map<String, dynamic> && state['id'] != null) {
      return int.tryParse(state['id'].toString());
    }
    if (json['state_id'] != null) {
      return int.tryParse(json['state_id'].toString());
    }
    return null;
  }

  UserProfile toEntity() => UserProfile(
        id: id,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        profilePhotoUrl: profilePhotoUrl,
        stateId: stateId,
      );
}
