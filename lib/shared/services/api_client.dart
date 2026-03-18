import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 로컬 개발용 백엔드 URL (Android 에뮬레이터: http://10.0.2.2:8080)
// TODO: 백엔드 확정 후 실제 URL로 교체
const String _baseUrl = 'http://localhost:8080';
const Duration _connectTimeout = Duration(seconds: 10);
const Duration _receiveTimeout = Duration(seconds: 30);

enum ApiExceptionType { network, client, server, timeout, unknown }

class ApiException implements Exception {
  final ApiExceptionType type;
  final int? statusCode;
  final String message;

  const ApiException({
    required this.type,
    this.statusCode,
    this.message = '',
  });

  @override
  String toString() => 'ApiException(type: $type, statusCode: $statusCode, message: $message)';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _storage = const FlutterSecureStorage();
  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(_AuthInterceptor(dio, _storage));
    return dio;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> put(String path, {Object? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(type: ApiExceptionType.timeout, message: 'Request timed out');
      case DioExceptionType.connectionError:
        return const ApiException(type: ApiExceptionType.network, message: 'No network connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode >= 400 && statusCode < 500) {
          return ApiException(
            type: ApiExceptionType.client,
            statusCode: statusCode,
            message: e.response?.data?['message'] as String? ?? 'Client error',
          );
        }
        return ApiException(
          type: ApiExceptionType.server,
          statusCode: statusCode,
          message: 'Server error',
        );
      default:
        return ApiException(type: ApiExceptionType.unknown, message: e.message ?? 'Unknown error');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio, this._storage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final token = await _storage.read(key: 'access_token');
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        await _clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final newAccessToken = response.data['access_token'] as String?;
    if (newAccessToken == null) return false;

    await _storage.write(key: 'access_token', value: newAccessToken);
    return true;
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}
