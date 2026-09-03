class ApiEndpoints {
  ApiEndpoints._();

  static String baseUrl = '';
  static const String register = 'auth/register';
  static const String verifyOtp = 'auth/verify-email-otp';
  static const String login = 'auth/login';
  static const String me = 'auth/me';
  static const String logout = 'auth/logout';
  static const String deleteAccount = 'users/account';
  static const String changePassword = 'users/change-password';
  static const String privacyPolicy = 'legal/privacy';
  static const String termsAndConditions = 'legal/terms';
  static const String posts = 'posts';
  static const String comments = 'comments';
  static const String stories = 'stories';
  static const String followingStories = 'stories/following';
  static const String updatePrivacySettings = 'users/settings/privacy';
  static const String chats = 'chats';
  static const String notifications = 'notifications';
}
