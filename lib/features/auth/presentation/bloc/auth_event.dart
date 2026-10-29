abstract class AuthEvent {
  const AuthEvent();
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String username;
  final String password;
  final String fullName;
  final String accountType;

  const RegisterRequested({
    required this.email,
    required this.username,
    required this.password,
    required this.fullName,
    required this.accountType,
  });
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const VerifyOtpRequested({required this.email, required this.otp});
}

class LoginRequested extends AuthEvent {
  final String emailOrUsername;
  final String password;

  const LoginRequested({required this.emailOrUsername, required this.password});
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class DeleteAccountRequested extends AuthEvent {
  final String password;

  const DeleteAccountRequested({required this.password});
}

class ChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequested({required this.oldPassword, required this.newPassword});
}

class UpdatePrivacySettingsRequested extends AuthEvent {
  final bool isPrivate;

  const UpdatePrivacySettingsRequested({required this.isPrivate});
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});
}

class VerifyResetOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const VerifyResetOtpRequested({required this.email, required this.otp});
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordRequested({required this.email, required this.otp, required this.newPassword});
}
