import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('----------------------------------------------------------------');
    debugPrint('🚀 [API REQUEST] ${options.method} ${options.uri}');
    debugPrint('   Headers: ${options.headers}');
    if (options.data != null) {
      if (options.data is FormData) {
        final formData = options.data as FormData;
        debugPrint('   FormData Fields: ${formData.fields}');
        debugPrint('   FormData Files: ${formData.files.map((e) => "${e.key}: ${e.value.filename}")}');
      } else {
        try {
          debugPrint('   Body: ${jsonEncode(options.data)}');
        } catch (_) {
          debugPrint('   Body: ${options.data}');
        }
      }
    }
    if (options.queryParameters.isNotEmpty) {
      debugPrint('   QueryParams: ${options.queryParameters}');
    }
    debugPrint('----------------------------------------------------------------');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('----------------------------------------------------------------');
    debugPrint('📥 [API RESPONSE] [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}');
    try {
      debugPrint('   Data: ${jsonEncode(response.data)}');
    } catch (_) {
      debugPrint('   Data: ${response.data}');
    }
    debugPrint('----------------------------------------------------------------');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('----------------------------------------------------------------');
    debugPrint('❌ [API ERROR] [${err.response?.statusCode ?? "NO_STATUS"}] ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('   Type: ${err.type}');
    debugPrint('   Message: ${err.message}');
    if (err.response?.data != null) {
      try {
        debugPrint('   Response Data: ${jsonEncode(err.response?.data)}');
      } catch (_) {
        debugPrint('   Response Data: ${err.response?.data}');
      }
    }
    debugPrint('----------------------------------------------------------------');
    return super.onError(err, handler);
  }
}
