class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.stateId,
    required this.password,
    required this.passwordConfirmation,
  });

  final String email;
  final String fullName;
  final String phoneNumber;
  final int stateId;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => {
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'state_id': stateId,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}
