import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_remote_datasource.dart';

/// 鉴权仓库实现 — 协调 remote + local token storage
class AuthRepositoryImpl {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStorage tokenStorage,
  })  : _remote = remote,
        _tokens = tokenStorage;

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokens;

  /// 登录成功 → 缓存 token + 返回 user
  Future<User> login({required String phone, required String password}) async {
    try {
      final res = await _remote.login(phone: phone, password: password);
      await _tokens.saveToken(res.token, phone: res.user.phone);
      return res.user;
    } catch (e) {
      throw ApiException(humanizeDioError(e));
    }
  }

  /// 注册成功 → 缓存 token + 返回 user
  Future<User> register({
    required String phone,
    required String password,
    String? nickname,
  }) async {
    try {
      final res = await _remote.register(
        phone: phone,
        password: password,
        nickname: nickname,
      );
      await _tokens.saveToken(res.token, phone: res.user.phone);
      return res.user;
    } catch (e) {
      throw ApiException(humanizeDioError(e));
    }
  }

  /// 拉当前用户（用于 App 启动时校验 token 是否还有效）
  Future<User?> fetchMe() async {
    final token = await _tokens.readToken();
    if (token == null) return null;
    try {
      return await _remote.me();
    } catch (_) {
      // token 失效 → 清掉
      await _tokens.clear();
      return null;
    }
  }

  Future<void> logout() async {
    await _tokens.clear();
  }

  Future<bool> hasToken() async {
    final t = await _tokens.readToken();
    return t != null && t.isNotEmpty;
  }
}