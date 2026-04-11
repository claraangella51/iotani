import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iotani_berhasil/features/auth/presentation/pages/login_page.dart';
import 'package:iotani_berhasil/features/auth/presentation/pages/register_page.dart';
import 'package:iotani_berhasil/shared/widgets/bottom_nav_shell.dart';
import 'package:iotani_berhasil/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:iotani_berhasil/features/monitoring/presentation/pages/monitoring_page.dart';
import 'package:iotani_berhasil/features/control/presentation/pages/control_page.dart';
import 'package:iotani_berhasil/features/history/presentation/pages/history_page.dart';
import 'package:iotani_berhasil/features/settings/presentation/pages/device_profile_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

GoRouter appRouter({required bool isAuthenticated}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isAuthenticated ? '/dashboard' : '/login',
    redirect: (context, state) {
      final isAuth = isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuth && !isAuthRoute) {
        return '/login';
      }

      if (isAuth && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Shell route for main navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/monitoring',
            name: 'monitoring',
            builder: (context, state) => const MonitoringPage(),
          ),
          GoRoute(
            path: '/control',
            name: 'control',
            builder: (context, state) => const ControlPage(),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (context, state) => const HistoryPage(),
          ),
        ],
      ),

      // Settings route (outside shell)
      GoRoute(
        path: '/device-profile',
        builder: (context, state) => const DeviceProfilePage(),
      ),
    ],
  );
}

extension GoRouterExtension on GoRouter {
  void goToDashboard(BuildContext context) => go('/dashboard');
  void goToMonitoring(BuildContext context) => go('/monitoring');
  void goToControl(BuildContext context) => go('/control');
  void goToHistory(BuildContext context) => go('/history');
  void goToDeviceProfile(BuildContext context) => go('/device-profile');
}
