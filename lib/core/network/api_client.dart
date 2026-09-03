import 'package:dio/dio.dart';
import 'package:vagabond/core/services/storage_service.dart';

class ApiClient {
  final Dio dio;
  final StorageService storageService;

  ApiClient({required this.dio, required this.storageService});

  Future<Options> _injectToken(Options? options) async {
    final opts = options ?? Options();
    opts.headers ??= {};
    final token = await storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      opts.headers!['Authorization'] = 'Bearer $token';
    }
    return opts;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final opts = await _injectToken(options);
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final opts = await _injectToken(options);
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final opts = await _injectToken(options);
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final opts = await _injectToken(options);
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Exception _handleDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['requiresVerification'] == true) {
      return RequiresVerificationException(
        message: data['message'] ?? 'Verification required',
        email: data['email'] ?? '',
      );
    }
    final message = data?['message'] ?? e.message ?? 'Network request failed';
    return Exception(message);
  }
}

class RequiresVerificationException implements Exception {
  final String message;
  final String email;

  RequiresVerificationException({required this.message, required this.email});

  @override
  String toString() => message;
}
