/// All API endpoint paths. Base URL must be HTTPS — asserted at startup.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.dmv-arabic.com';

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String verify = '/api/auth/verify';
  static const String login = '/api/auth/login';
  static const String social = '/api/auth/social';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String refreshToken = '/api/auth/refresh-token';
}
