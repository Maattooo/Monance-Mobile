import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/main_shell_view.dart';
import '../../views/dashboard/dashboard_view.dart';
import '../../views/calendar/calendar_view.dart';
import '../../views/goal/goal_view.dart';
import '../../views/settings/settings_view.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref ref;

  RouterNotifier(this.ref) {
    ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final currentAuth = ref.read(authProvider);
      final isAuth = currentAuth.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';

      // While determining session state, don't redirect yet
      if (currentAuth.status == AuthStatus.initial || currentAuth.status == AuthStatus.loading) {
        return null;
      }

      // If user is not authenticated and not heading to login/register, push to /login
      if (!isAuth && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      // If user is authenticated and trying to access login/register, redirect to dashboard
      if (isAuth && (isGoingToLogin || isGoingToRegister)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellView(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarView(),
          ),
          GoRoute(
            path: '/goal',
            builder: (context, state) => const GoalView(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsView(),
          ),
        ],
      ),
    ],
  );
});
