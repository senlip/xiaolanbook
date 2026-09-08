import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

// ---------- 依赖图 ----------

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage.instance);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepositoryImpl>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

// ---------- AuthState ----------

@immutable
class AuthState {
  const AuthState({this.user, this.loading = false, this.error});
  final User? user;
  final bool loading;
  final String? error;

  bool get isLoggedIn => user != null;

  AuthState copyWith({User? user, bool? loading, String? error, bool clearUser = false, bool clearError = false}) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState());
  final AuthRepositoryImpl _repo;

  /// App 启动时调用 — 检查本地 token 并拉 /me
  Future<void> bootstrap() async {
    state = state.copyWith(loading: true, clearError: true);
    final user = await _repo.fetchMe();
    state = AuthState(user: user, loading: false);
  }

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repo.login(phone: phone, password: password);
      state = AuthState(user: user);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String phone,
    required String password,
    String? nickname,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repo.register(phone: phone, password: password, nickname: nickname);
      state = AuthState(user: user);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);