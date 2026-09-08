import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储：保存 access_token（Keychain/Keystore 加密）
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _keyToken = 'access_token';
  static const _keyPhone = 'user_phone';

  final FlutterSecureStorage _store = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String?> readToken() => _store.read(key: _keyToken);
  Future<String?> readPhone() => _store.read(key: _keyPhone);

  Future<void> saveToken(String token, {String? phone}) async {
    await _store.write(key: _keyToken, value: token);
    if (phone != null) await _store.write(key: _keyPhone, value: phone);
  }

  Future<void> clear() async {
    await _store.delete(key: _keyToken);
    await _store.delete(key: _keyPhone);
  }
}