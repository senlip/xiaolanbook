/// User 实体（领域层 — 与后端解耦）
class User {
  const User({
    required this.id,
    required this.phone,
    required this.nickname,
    this.avatarUrl,
    this.gender,
    this.bio,
  });

  final int id;
  final String phone;
  final String nickname;
  final String? avatarUrl;
  final String? gender; // 'M' / 'F' / null
  final String? bio;

  String get displayPhone => phone.replaceAllMapped(
        RegExp(r'(\d{3})\d{4}(\d{4})'),
        (m) => '${m.group(1)}****${m.group(2)}',
      );
}