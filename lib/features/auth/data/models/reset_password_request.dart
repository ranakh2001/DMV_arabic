class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.phoneNumber,
    required this.code,
    required this.password,
    required this.passwordConfirmation,
  });

  final String phoneNumber;
  final String code;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}
