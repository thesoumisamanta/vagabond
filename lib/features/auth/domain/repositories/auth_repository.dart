import 'package:vagabond/features/auth/domain/entities/login_result.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<LoginResult> login(String emailOrUsername, String password);
  Future<String> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
    required String accountType,
  });
  Future<String> verifyOtp({required String email, required String otp});
  Future<User> getProfile();
  Future<void> logout();
  Future<void> deleteAccount({required String password});
  Future<String> changePassword({required String oldPassword, required String newPassword});
  Future<String> updatePrivacySettings({required bool isPrivate});
}
