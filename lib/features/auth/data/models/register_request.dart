class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.contact,
    required this.password,
  });

  final String name;
  final String contact;
  final String password;

  Map<String, dynamic> toJson() {
    final isPhone = !contact.contains('@');
    return {
      'name': name,
      if (isPhone) 'phone': contact else 'email': contact,
      'password': password,
    };
  }
}
