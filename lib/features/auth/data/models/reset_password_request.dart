class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.contact,
    required this.code,
    required this.newPassword,
  });

  final String contact;
  final String code;
  final String newPassword;

  Map<String, dynamic> toJson() => {
        'contact': contact,
        'code': code,
        'new_password': newPassword,
      };
}
