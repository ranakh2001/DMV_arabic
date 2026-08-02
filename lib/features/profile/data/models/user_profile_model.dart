import '../../../states/data/models/us_state_model.dart';
import '../../domain/entities/user_profile.dart';
import 'user_progress_model.dart';
import 'user_subscription_model.dart';

/// Data model for the `/users/profile` response object.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    this.stateId,
    this.freeQuestionsUsed = 0,
    this.subscriptionType,
    this.progress,
    this.subscription,
    this.selectedState,
  });

  final String id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String? profilePhotoUrl;
  final int? stateId;
  final int freeQuestionsUsed;
  final String? subscriptionType;
  final UserProgressModel? progress;
  final UserSubscriptionModel? subscription;
  final UsStateModel? selectedState;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'].toString(),
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String?,
        phoneNumber: json['phone_number'] as String? ?? '',
        profilePhotoUrl: json['profile_photo_url'] as String?,
        stateId: _parseStateId(json),
        freeQuestionsUsed: json['free_questions_used'] as int? ?? 0,
        subscriptionType: json['subscription_type'] as String?,
        progress: json['progress'] is Map<String, dynamic>
            ? UserProgressModel.fromJson(
                json['progress'] as Map<String, dynamic>,
              )
            : null,
        subscription: json['subscription'] is Map<String, dynamic>
            ? UserSubscriptionModel.fromJson(
                json['subscription'] as Map<String, dynamic>,
              )
            : null,
        selectedState: json['selected_state'] is Map<String, dynamic>
            ? UsStateModel.fromJson(
                json['selected_state'] as Map<String, dynamic>,
              )
            : null,
      );

  /// The API's real field is `selected_state_id` (flat int); `state`/
  /// `state_id` are kept as fallbacks in case a different endpoint variant
  /// ever nests it.
  static int? _parseStateId(Map<String, dynamic> json) {
    if (json['selected_state_id'] != null) {
      return int.tryParse(json['selected_state_id'].toString());
    }
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
    freeQuestionsUsed: freeQuestionsUsed,
    subscriptionType: subscriptionType,
    progress: progress?.toEntity(),
    subscription: subscription?.toEntity(),
    selectedState: selectedState?.toEntity(),
  );
}
