import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
    required String accountType,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  });

  Future<UserModel> getProfile();

  Future<Map<String, dynamic>> logout();

  Future<Map<String, dynamic>> deleteAccount({required String password});

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Map<String, dynamic>> updatePrivacySettings({required bool isPrivate});
  Future<Map<String, dynamic>> forgotPassword({required String email});
  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  });
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<UserModel> updateProfile({
    File? profilePicture,
    File? coverPhoto,
    String? fullName,
    String? bio,
    String? location,
    String? website,
    String? businessEmail,
    bool? isPrivate,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
    required String accountType,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
        'accountType': accountType.toLowerCase(),
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {'emailOrUsername': emailOrUsername, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.get(ApiEndpoints.me);
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  @override
  Future<Map<String, dynamic>> logout() async {
    final response = await apiClient.post(ApiEndpoints.logout);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> deleteAccount({required String password}) async {
    final response = await apiClient.delete(
      ApiEndpoints.deleteAccount,
      data: {'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.changePassword,
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updatePrivacySettings({
    required bool isPrivate,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.updatePrivacySettings,
      data: {'isPrivate': isPrivate},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.verifyResetOtp,
      data: {'email': email, 'otp': otp},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.resetPassword,
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<UserModel> updateProfile({
    File? profilePicture,
    File? coverPhoto,
    String? fullName,
    String? bio,
    String? location,
    String? website,
    String? businessEmail,
    bool? isPrivate,
  }) async {
    final formData = FormData();

    if (profilePicture != null) {
      final filename = profilePicture.path.split('/').last;
      formData.files.add(
        MapEntry(
          'profilePicture',
          await MultipartFile.fromFile(profilePicture.path, filename: filename),
        ),
      );
    }
    if (coverPhoto != null) {
      final filename = coverPhoto.path.split('/').last;
      formData.files.add(
        MapEntry(
          'coverPhoto',
          await MultipartFile.fromFile(coverPhoto.path, filename: filename),
        ),
      );
    }
    if (fullName != null) {
      formData.fields.add(MapEntry('fullName', fullName.trim()));
    }
    if (bio != null) {
      formData.fields.add(MapEntry('bio', bio.trim()));
    }
    if (location != null) {
      formData.fields.add(MapEntry('location', location.trim()));
    }
    if (website != null) {
      formData.fields.add(MapEntry('website', website.trim()));
    }
    if (businessEmail != null) {
      formData.fields.add(MapEntry('businessEmail', businessEmail.trim()));
    }
    if (isPrivate != null) {
      formData.fields.add(MapEntry('isPrivate', isPrivate.toString()));
    }

    final response = await apiClient.put(
      ApiEndpoints.updateProfile,
      data: formData,
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }
}
