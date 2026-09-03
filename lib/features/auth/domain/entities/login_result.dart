class LoginResult {
  final bool success;
  final bool requiresVerification;
  final String? email;
  final String? message;
  final String? accessToken;
  final String? refreshToken;

  const LoginResult({
    required this.success,
    this.requiresVerification = false,
    this.email,
    this.message,
    this.accessToken,
    this.refreshToken,
  });
}
