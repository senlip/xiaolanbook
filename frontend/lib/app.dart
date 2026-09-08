import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/home_placeholder_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';

class XiaolanbookApp extends ConsumerWidget {
  const XiaolanbookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/home', builder: (_, __) => const HomePlaceholderPage()),
      ],
    );

    return MaterialApp.router(
      title: '小蓝书',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}