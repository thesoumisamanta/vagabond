import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/services/storage_service.dart';
import 'package:vagabond/features/auth/domain/entities/login_result.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/auth/domain/repositories/auth_repository.dart';
import 'package:vagabond/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({required this.remoteDataSource, required this.storageService});

  @override
  Future<LoginResult> login(String emailOrUsername, String password) async {
    try {
      final response = await remoteDataSource.login(emailOrUsername: emailOrUsername, password: password);

      final success = response['success'] as bool? ?? false;
      if (success) {
        final data = response['data'] as Map<String, dynamic>?;
        final accessToken = data?['accessToken'] as String? ?? '';
        final refreshToken = data?['refreshToken'] as String? ?? '';

        await storageService.saveAccessToken(accessToken);
        await storageService.saveRefreshToken(refreshToken);

        return LoginResult(
          success: true,
          accessToken: accessToken,
          refreshToken: refreshToken,
          message: response['message'] as String?,
        );
      } else {
        final requiresVerification = response['requiresVerification'] as bool? ?? false;
        if (requiresVerification) {
          return LoginResult(
            success: false,
            requiresVerification: true,
            email: response['email'] as String?,
            message: response['message'] as String?,
          );
        }
        return LoginResult(success: false, message: response['message'] as String? ?? 'Invalid credentials');
      }
    } on RequiresVerificationException catch (e) {
      return LoginResult(success: false, requiresVerification: true, email: e.email, message: e.message);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
    required String accountType,
  }) async {
    try {
      final response = await remoteDataSource.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
        accountType: accountType,
      );
      return response['message'] as String? ?? 'Registration successful';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await remoteDataSource.verifyOtp(email: email, otp: otp);
      return response['message'] as String? ?? 'OTP verified successfully';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      await storageService.saveUserProfile(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Ignore remote logout failure to ensure local session is always cleared
    } finally {
      await storageService.clearAll();
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      await remoteDataSource.deleteAccount(password: password);
      await storageService.clearAll();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      final response = await remoteDataSource.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      return response['message'] as String? ?? 'Password updated successfully';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> updatePrivacySettings({required bool isPrivate}) async {
    try {
      final response = await remoteDataSource.updatePrivacySettings(isPrivate: isPrivate);
      await getProfile();
      return response['message'] as String? ?? 'Account settings updated successfully';
    } catch (e) {
      rethrow;
    }
  }
}
