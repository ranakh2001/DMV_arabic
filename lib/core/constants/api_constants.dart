/// All API endpoint paths. Base URL must be HTTPS — asserted at startup.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://usaarabdrivers.com/api';

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  /// Longer timeouts for multipart file uploads (e.g. profile photo), which
  /// take noticeably more time than plain JSON requests on slow networks.
  static const int uploadSendTimeoutMs = 60000;
  static const int uploadReceiveTimeoutMs = 30000;

  // Auth endpoints
  static const String register = '/auth/register';
  static const String verify = '/auth/verify';
  static const String resendVerificationCode = '/auth/resend-verification-code';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';

  // User endpoints (Bearer token required)
  static const String profile = '/users/profile';
  static const String profilePhoto = '/users/profile-photo';
  static const String selectedState = '/users/selected-state';
  static const String changePassword = '/users/change-password';
  static const String fcmToken = '/users/fcm-token';
  static const String deleteAccount = '/users/account';

  // Reference data (no auth required)
  static const String states = '/states';

  // Question bank (Bearer token required)
  static const String questions = '/questions';
  static String checkAnswer(int questionId) =>
      '/questions/$questionId/check-answer';

  // Subscription packages (Bearer token required)
  static const String subscriptionPackages = '/subscription-packages';

  // Subscription checkout / Stripe payment flow (Bearer token required)
  static const String subscriptionInitiate = '/subscriptions/initiate';
  static const String subscriptionStatus = '/subscriptions/status';
  static const String subscriptionHistory = '/subscriptions/history';

  // Apple In-App Purchase checkout flow, iOS only (Bearer token required)
  static const String subscriptionAppleAccountToken =
      '/subscriptions/apple-account-token';
  static const String subscriptionAppleIap = '/subscriptions/apple-iap';
  static const String subscriptionVerify = '/subscriptions/verify';

  // Simulation exams (Bearer token required)
  static const String simulationExams = '/simulation-exams';
  static String startSimulationExam(int examId) =>
      '/simulation-exams/$examId/start';
  static String examAttemptAnswers(int attemptId) =>
      '/exam-attempts/$attemptId/answers';
  static String submitExamAttempt(int attemptId) =>
      '/exam-attempts/$attemptId/submit';
  static String examAttemptResults(int attemptId) =>
      '/exam-attempts/$attemptId/results';
  static const String examAttemptHistory = '/exam-attempts/history';

  // Analytics (Bearer token required)
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsProgress = '/analytics/progress';
  static const String analyticsByCategory = '/analytics/by-category';

  // Legal / informational content (no auth required)
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';
  static const String aboutUs = '/about';

  // Support (Bearer token required)
  static const String contactUs = '/support/contact';

  // Notifications (Bearer token required)
  static const String notifications = '/notifications';

  /// Base URL that relative `image_url` values (e.g. `questions/xxx.webp`)
  /// returned by the questions API are resolved against.
  static const String storageBaseUrl = 'https://usaarabdrivers.com/storage/';

  /// Resolves an `image_url` from the API into an absolute URL. The API has
  /// been observed returning both relative paths and already-absolute URLs
  /// for this field, so an absolute one is passed through as-is instead of
  /// being prepended with [storageBaseUrl] (which would double it up).
  static String resolveStorageUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://')
      ? url
      : '$storageBaseUrl$url';
}
