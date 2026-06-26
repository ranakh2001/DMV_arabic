/// Domain entity for an authenticated user. Contains no data-layer types.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.isVerified = false,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final bool isVerified;
  final String? avatarUrl;

  /// Primary contact: email preferred, falls back to phone.
  String get contact => email ?? phone ?? '';

  @override
  String toString() => 'AuthUser(id: $id, name: $name)';
}
