import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config.dart';
import '../storage/token_storage.dart';

/// Dio 实例 — 携带 baseUrl + Bearer Token 拦截器
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
    validateStatus: (s) => s != null && s < 500, // 让业务错误落到 catchError
  ));

  // 请求拦截器：自动加 Bearer
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await TokenStorage.instance.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (e, handler) {
      // 业务错误（如 401/422）原样抛出
      handler.next(e);
    },
  ));

  return dio;
});

/// API 业务异常 — 带可读消息
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.detail});
  final String message;
  final int? statusCode;
  final dynamic detail;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// DioException → ApiException 包装
String humanizeDioError(Object e) {
  if (e is DioException) {
    final res = e.response;
    if (res != null) {
      final data = res.data;
      String msg = '请求失败（${res.statusCode}）';
      if (data is Map) {
        // FastAPI 错误结构：{"detail": "..."} 或 {"detail": [{...}]}
        final d = data['detail'];
        if (d is String) msg = d;
        else if (d is List && d.isNotEmpty) {
          final first = d.first;
          if (first is Map && first['msg'] is String) msg = first['msg'] as String;
        }
      }
      return msg;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络超时，请检查后端是否启动';
      case DioExceptionType.connectionError:
        return '无法连接服务器（${AppConfig.apiBaseUrl}）';
      default:
        return e.message ?? '未知网络错误';
    }
  }
  return e.toString();
}