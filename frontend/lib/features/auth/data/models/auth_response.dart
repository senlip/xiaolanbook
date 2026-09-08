import '../../domain/entities/user.dart';
import 'user_dto.dart';

/// 后端 TokenOut JSON → (token, user)
class AuthResponse {
  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['access_token'] as String,
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>).toEntity(),
      );

  final String token;
  final User user;
}