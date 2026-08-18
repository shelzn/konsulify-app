import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(const FlutterSecureStorage());
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint(
            '[API] ${options.method} ${options.baseUrl}${options.path}',
          );
          debugPrint('[API] data: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
            '[API] ${response.statusCode} ${response.requestOptions.path}',
          );
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint(
            '[API] ERROR ${error.response?.statusCode} ${error.requestOptions.path}',
          );
          debugPrint('[API] response: ${error.response?.data}');
        }
        if (error.response?.statusCode == 401) {
          await storage.clearToken();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return _request(() => _dio.get(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    return _request(() => _dio.post(path, data: data));
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async {
    return _request(() => _dio.patch(path, data: data));
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _request(() => _dio.delete(path));
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw AppException('Response server tidak valid.');
    } on DioException catch (error) {
      final response = error.response;
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        throw AppException(
          data['message']?.toString() ?? 'Terjadi kesalahan.',
          statusCode: response?.statusCode,
          errors: data['errors'],
        );
      }
      throw AppException(error.message ?? 'Tidak dapat terhubung ke server.');
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
