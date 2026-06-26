class SocialLoginRequest {
  const SocialLoginRequest({required this.provider, required this.token});

  final String provider;
  final String token;

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'token': token,
      };
}
