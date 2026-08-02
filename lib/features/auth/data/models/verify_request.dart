class VerifyRequest {
  const VerifyRequest({required this.phoneNumber, required this.code});

  final String phoneNumber;
  final String code;

  Map<String, dynamic> toJson() => {'phone_number': phoneNumber, 'code': code};
}
