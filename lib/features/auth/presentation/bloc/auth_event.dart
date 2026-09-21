import 'dart:io';

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

class UpdateProfileRequested extends AuthEvent {
  final File? profilePicture;
  final File? coverPhoto;
  final String? fullName;
  final String? bio;
  final String? location;
  final String? website;
  final String? businessEmail;
  final bool? isPrivate;

  const UpdateProfileRequested({
    this.profilePicture,
    this.coverPhoto,
    this.fullName,
    this.bio,
    this.location,
    this.website,
    this.businessEmail,
    this.isPrivate,
  });
}
