/// All API endpoint paths. Base URL must be HTTPS — asserted at startup.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://usaarabdrivers.com/api';

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // Auth endpoints
  static const String register = '/auth/register';
  static const String verify = '/auth/verify';
  static const String resendVerificationCode = '/auth/resend-verification-code';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User endpoints (Bearer token required)
  static const String profile = '/users/profile';
  static const String changePassword = '/users/change-password';

  // Reference data (no auth required)
  static const String states = '/states';
}
