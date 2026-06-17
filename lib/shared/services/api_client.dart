import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 플랫폼별 백엔드 호스트
// - 웹 / iOS 시뮬레이터 / 데스크톱: localhost
// - Android 에뮬레이터: 10.0.2.2 (호스트 머신 별칭, localhost는 에뮬레이터 자신)
// TODO: 실서버 확정 후 환경별 URL로 교체
String _resolveBaseUrl() {
  if (kIsWeb) return 'http://localhost:8080';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}

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
        baseUrl: _resolveBaseUrl(),
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
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

  /// 원격 파일(이미지/오디오)을 로컬 경로로 다운로드한다.
  /// 오프라인 저장 등 바이너리 다운로드 전용. [url] 은 절대 URL 이어야 한다.
  Future<void> downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
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
          final rawData = e.response?.data;
          final msg = rawData is Map
              ? (rawData['message'] as String? ?? rawData['error'] as String? ?? 'Client error')
              : 'Client error';
          return ApiException(
            type: ApiExceptionType.client,
            statusCode: statusCode,
            message: msg,
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
      data: {'refreshToken': refreshToken},
    );
    final newAccessToken = response.data['accessToken'] as String?;
    final newRefreshToken = response.data['refreshToken'] as String?;
    if (newAccessToken == null) return false;

    await _storage.write(key: 'access_token', value: newAccessToken);
    if (newRefreshToken != null) {
      await _storage.write(key: 'refresh_token', value: newRefreshToken);
    }
    return true;
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}
