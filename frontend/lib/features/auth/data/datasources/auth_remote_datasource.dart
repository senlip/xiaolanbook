import 'package:dio/dio.dart';

import '../../domain/entities/user.dart';
import '../models/auth_response.dart';
import '../models/user_dto.dart';

/// 远程数据源 — 直接打 HTTP（可被 mock 替换）
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<AuthResponse> register({
    required String phone,
    required String password,
    String? nickname,
  }) async {
    final res = await _dio.post('/api/users/register', data: {
      'phone': phone,
      'password': password,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    });
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/api/users/login', data: {
      'phone': phone,
      'password': password,
    });
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<User> me() async {
    final res = await _dio.get('/api/users/me');
    final data = res.data as Map<String, dynamic>;
    // /me 返回 {"user": {...}}
    return UserDto.fromJson(data['user'] as Map<String, dynamic>).toEntity();
  }

  Future<void> sendSms(String phone) async {
    await _dio.post('/api/users/send-sms', data: {'phone': phone});
  }
}