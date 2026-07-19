import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import 'auth_secure_storage.dart';

/// HTTP client configured with token injection and automatic refresh handling.
class DioClient {
  DioClient({
    required String baseUrl,
    AuthSecureStorage? secureStorage,
    Dio? dio,
  })  : _secureStorage = secureStorage ?? AuthSecureStorage(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  final Dio _dio;
  final AuthSecureStorage _secureStorage;

  Dio get client => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer ';
      }
    } catch (_) {
      // If secure storage fails, continue without token injection.
    }

    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final response = error.response;
    final requestOptions = error.requestOptions;

    if (response?.statusCode == 401 &&
        requestOptions.extra['retry'] != true &&
        !requestOptions.path.endsWith('/api/v1/auth/refresh')) {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshResponse = await _dio.post(
            '/api/v1/auth/refresh',
            data: {'refreshToken': refreshToken},
          );
          final refreshedData = refreshResponse.data as Map<String, dynamic>?;
          final newAccessToken = refreshedData?['token']?.toString();
          final newRefreshToken = refreshedData?['refreshToken']?.toString();

          if (newAccessToken != null && newRefreshToken != null) {
            await _secureStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
 
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            requestOptions.extra['retry'] = true;
            final retryResponse = await _dio.fetch(requestOptions);
            handler.resolve(retryResponse);
            return;
          }
        } catch (_) {
          // ignore and fall through to return original error below
        }
      }

      await _secureStorage.clearTokens();
    }

    final mappedError = _mapDioException(error);
    handler.reject(
      error.copyWith(
        message: mappedError.message,
        error: mappedError,
      ),
    );
  }

  AppException _mapDioException(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return const BadRequestException();
        case 401:
          return const UnauthorizedException();
        case 403:
          return const ForbiddenException();
        case 404:
          return const NotFoundException();
        case 500:
          return const InternalServerErrorException();
        default:
          if (statusCode >= 500) {
            return const ServerException();
          }
          if (statusCode >= 400) {
            return const ServerException(
                'La petición contiene datos inválidos.');
          }
      }
    }

    return const NetworkException();
  }
}














