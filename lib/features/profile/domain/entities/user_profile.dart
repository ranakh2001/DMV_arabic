/// Domain entity for the current user's profile. Contains no data-layer types.
class UserProfile {
  const UserProfile({
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

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePhotoUrl,
    int? stateId,
  }) =>
      UserProfile(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        stateId: stateId ?? this.stateId,
      );
}
