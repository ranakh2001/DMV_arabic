class ResendVerificationCodeRequest {
  const ResendVerificationCodeRequest({required this.phoneNumber});

  final String phoneNumber;

  Map<String, dynamic> toJson() => {'phone_number': phoneNumber};
}
