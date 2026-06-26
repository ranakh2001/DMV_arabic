class LoginRequest {
  const LoginRequest({required this.contact, required this.password});

  final String contact;
  final String password;

  Map<String, dynamic> toJson() => {
        'contact': contact,
        'password': password,
      };
}
