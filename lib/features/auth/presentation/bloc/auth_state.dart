import 'package:vagabond/features/auth/domain/entities/user.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegisterSuccess extends AuthState {
  final String message;

  const AuthRegisterSuccess({required this.message});
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});
}

class AuthVerifyOtpSuccess extends AuthState {
  final String message;

  const AuthVerifyOtpSuccess({required this.message});
}

class AuthLoginRequiresVerification extends AuthState {
  final String email;
  final String message;

  const AuthLoginRequiresVerification({required this.email, required this.message});
}

class AuthProfileSuccess extends AuthState {
  final User user;

  const AuthProfileSuccess({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});
}

class AuthDeleteAccountSuccess extends AuthState {
  final String message;

  const AuthDeleteAccountSuccess({required this.message});
}

class AuthChangePasswordSuccess extends AuthState {
  final String message;

  const AuthChangePasswordSuccess({required this.message});
}

class AuthUpdatePrivacySettingsSuccess extends AuthState {
  final String message;
  final bool isPrivate;

  const AuthUpdatePrivacySettingsSuccess({required this.message, required this.isPrivate});
}
