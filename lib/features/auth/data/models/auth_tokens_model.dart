/// Data model for the token pair returned by the API.
class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;

  /// Seconds until access token expires (server-provided).
  final int expiresIn;

  /// Parses tokens from the flat `data` object returned by login/verify
  /// (e.g. `{ user: {...}, access_token, refresh_token, token_type, expires_in }`).
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      AuthTokensModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn: json['expires_in'] as int? ?? 900,
      );

  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));
}
