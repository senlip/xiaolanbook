import '../../domain/entities/user.dart';

/// 后端 UserOut JSON → User 实体
class UserDto {
  UserDto({
    required this.id,
    required this.phone,
    required this.nickname,
    this.avatarUrl,
    this.gender,
    this.bio,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as int,
        phone: json['phone'] as String,
        nickname: json['nickname'] as String,
        avatarUrl: json['avatar_url'] as String?,
        gender: json['gender'] as String?,
        bio: json['bio'] as String?,
      );

  final int id;
  final String phone;
  final String nickname;
  final String? avatarUrl;
  final String? gender;
  final String? bio;

  User toEntity() => User(
        id: id,
        phone: phone,
        nickname: nickname,
        avatarUrl: avatarUrl,
        gender: gender,
        bio: bio,
      );
}