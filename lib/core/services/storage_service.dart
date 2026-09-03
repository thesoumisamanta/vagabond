import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vagabond/features/auth/data/models/user_model.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';

class StorageService {
  final FlutterSecureStorage secureStorage;

  StorageService({required this.secureStorage});

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userProfileKey = 'user_profile';

  Future<void> saveAccessToken(String token) async {
    await secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> saveUserProfile(User user) async {
    final userModel = UserModel.fromEntity(user);
    final jsonStr = jsonEncode(userModel.toJson());
    await secureStorage.write(key: _userProfileKey, value: jsonStr);
  }

  Future<UserModel?> getUserProfile() async {
    final jsonStr = await secureStorage.read(key: _userProfileKey);
    if (jsonStr == null) return null;
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserModel.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    await secureStorage.delete(key: _userProfileKey);
  }
}
