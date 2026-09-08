import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// 登录页 — 手机号 + 密码
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _registerMode = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = ref.read(authControllerProvider.notifier);
    final ok = _registerMode
        ? await ctrl.register(phone: _phoneCtrl.text, password: _passCtrl.text)
        : await ctrl.login(phone: _phoneCtrl.text, password: _passCtrl.text);
    if (ok && mounted) context.go('/home');
  }

  String? _validatePhone(String? v) {
    if (v == null || v.length != 11) return '请输入 11 位手机号';
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(v)) return '手机号格式错误';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.length < 6) return '密码至少 6 位';
    if (v.length > 64) return '密码太长';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    '📘',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _registerMode ? '加入小蓝书' : '欢迎回到小蓝书',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _registerMode ? '记录生活，分享灵感' : '登录以继续',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),

                // 手机号
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_outlined),
                    labelText: '手机号',
                    hintText: '11 位手机号',
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 14),

                // 密码
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    labelText: '密码',
                    hintText: '至少 6 位',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: _validatePassword,
                ),

                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: AppColors.danger, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: state.loading ? null : _submit,
                  child: state.loading
                      ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                      : Text(_registerMode ? '注册并登录' : '登录'),
                ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: state.loading ? null : () => setState(() => _registerMode = !_registerMode),
                  child: Text(_registerMode ? '已有账号？去登录' : '还没有账号？立即注册'),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '登录即同意《用户协议》和《隐私政策》',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}