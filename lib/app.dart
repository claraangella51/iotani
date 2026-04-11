import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/core/router/app_router.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/auth/providers/auth_provider.dart';

class IoTaniApp extends ConsumerWidget {
  const IoTaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        final isAuthenticated = user != null;
        return MaterialApp.router(
          title: 'IoTani',
          theme: AppTheme.lightTheme(),
          routerConfig: appRouter(isAuthenticated: isAuthenticated),
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, _) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Terjadi kesalahan saat menginisialisasi aplikasi'),
          ),
        ),
      ),
    );
  }
}
