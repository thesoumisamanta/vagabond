import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/core/services/storage_service.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/auth/domain/repositories/auth_repository.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_event.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final StorageService storageService;
  User? currentUser;

  AuthBloc({required this.authRepository, required this.storageService}) : super(AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<AppStarted>(_onAppStarted);
    on<LogoutRequested>(_onLogoutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<UpdatePrivacySettingsRequested>(_onUpdatePrivacySettingsRequested);
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await authRepository.register(
        email: event.email,
        username: event.username,
        password: event.password,
        fullName: event.fullName,
        accountType: event.accountType,
      );
      emit(AuthRegisterSuccess(message: message));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await authRepository.verifyOtp(email: event.email, otp: event.otp);
      emit(AuthVerifyOtpSuccess(message: message));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.login(event.emailOrUsername, event.password);

      if (result.success) {
        // Fetch profile details
        final user = await authRepository.getProfile();
        currentUser = user;
        emit(AuthProfileSuccess(user: user));
      } else if (result.requiresVerification) {
        emit(
          AuthLoginRequiresVerification(email: result.email ?? '', message: result.message ?? 'Verification required'),
        );
      } else {
        emit(AuthFailure(error: result.message ?? 'Invalid credentials'));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final token = await storageService.getAccessToken();
    if (token == null) {
      currentUser = null;
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final user = await authRepository.getProfile();
      currentUser = user;
      emit(AuthAuthenticated(user: user));
    } catch (_) {
      currentUser = null;
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      currentUser = null;
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteAccountRequested(DeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.deleteAccount(password: event.password);
      currentUser = null;
      emit(const AuthDeleteAccountSuccess(message: 'Account deleted successfully'));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onChangePasswordRequested(ChangePasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await authRepository.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );
      emit(AuthChangePasswordSuccess(message: message));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdatePrivacySettingsRequested(UpdatePrivacySettingsRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await authRepository.updatePrivacySettings(isPrivate: event.isPrivate);
      if (currentUser != null) {
        currentUser = currentUser!.copyWith(isPrivate: event.isPrivate);
      }
      emit(AuthUpdatePrivacySettingsSuccess(message: message, isPrivate: event.isPrivate));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
