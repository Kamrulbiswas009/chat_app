import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../storage/storage_service.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';
import 'api_logger.dart';

class ApiClient {
  static ApiClient get to => getx.Get.find();

  late Dio dio;
  final StorageService _storage = StorageService.to;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: _storage.getBaseUrl(),
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 1. Logger Interceptor (Console output for every request, response, and error)
    dio.interceptors.add(ApiLoggerInterceptor());

    // 2. Auth & Auto-refresh Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = _storage.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: _storage.getBaseUrl()));
                final response = await refreshDio.post(
                  ApiConstants.refreshToken,
                  data: {'refreshToken': refreshToken},
                );

                final data = response.data is Map ? response.data : {'data': response.data};
                final rootData = data['data'] is Map ? data['data'] : data;
                final tokensData = rootData['tokens'] is Map ? rootData['tokens'] : (data['tokens'] is Map ? data['tokens'] : null);
                
                final newAccessToken = tokensData?['accessToken'] ?? 
                    tokensData?['access_token'] ?? 
                    rootData['accessToken'] ?? 
                    rootData['access_token'] ?? 
                    rootData['token'] ?? 
                    data['accessToken'] ?? 
                    data['access_token'] ?? 
                    data['token'];

                final newRefreshToken = tokensData?['refreshToken'] ?? 
                    tokensData?['refresh_token'] ?? 
                    rootData['refreshToken'] ?? 
                    rootData['refresh_token'] ?? 
                    data['refreshToken'] ?? 
                    data['refresh_token'];
                
                if (newAccessToken != null && newAccessToken.toString().isNotEmpty) {
                  await _storage.setAccessToken(newAccessToken.toString());
                  if (newRefreshToken != null && newRefreshToken.toString().isNotEmpty) {
                    await _storage.setRefreshToken(newRefreshToken.toString());
                  }

                  // Retry original request with new token
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';
                  final cloneReq = await dio.request(
                    opts.path,
                    options: Options(method: opts.method, headers: opts.headers),
                    data: opts.data,
                    queryParameters: opts.queryParameters,
                  );
                  return handler.resolve(cloneReq);
                }
              } catch (_) {
                await _storage.clearAuth();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
    _storage.setBaseUrl(newUrl);
  }

  ApiException handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Connection timed out. Please try again.');
        case DioExceptionType.connectionError:
          return NetworkException('Unable to reach server. Please check internet connection or backend URL.');
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          final data = error.response?.data;
          String msg = 'Server error ($status)';

          if (data is Map) {
            if (data['message'] != null) {
              if (data['message'] is List) {
                msg = (data['message'] as List).join(', ');
              } else {
                msg = data['message'].toString();
              }
            } else if (data['error'] != null) {
              msg = data['error'].toString();
            }
          }

          if (status == 401) return UnauthorizedException(msg);
          if (status == 404) return NotFoundException(msg);
          if (status == 500) return ApiException(message: 'Server error (500): Database or service temporarily unavailable on host', statusCode: 500, data: data);
          return ApiException(message: msg, statusCode: status, data: data);
        default:
          return ApiException(message: error.message ?? 'Unexpected network error');
      }
    }
    return ApiException(message: error.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''));
  }
}
