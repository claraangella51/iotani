import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/core/router/app_router.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/auth/providers/auth_provider.dart';
import 'package:iotani_berhasil/features/splash/presentation/pages/splash_page.dart';

class IoTaniApp extends ConsumerStatefulWidget {
  const IoTaniApp({super.key});

  @override
  ConsumerState<IoTaniApp> createState() => _IoTaniAppState();
}

class _IoTaniAppState extends ConsumerState<IoTaniApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    final isAuthenticated = authState.asData?.value != null;

    return MaterialApp.router(
      title: 'IoTani',
      theme: AppTheme.lightTheme(),
      routerConfig: appRouter(isAuthenticated: isAuthenticated),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (_showSplash) {
          return const SplashPage();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
