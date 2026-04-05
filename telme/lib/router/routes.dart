import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/models/profile_model.dart';
import 'package:telme/views/auth/login_screen.dart';
import 'package:telme/views/auth/signup_screen.dart';
import 'package:telme/views/admin/admin_dashboard.dart';
import 'package:telme/views/employee/employee_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileFuture = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.value?.session?.user;
      final loggedIn = user != null;
      final isAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!loggedIn && !isAuthPage && state.matchedLocation != '/register') return '/login';
      if (loggedIn && (isAuthPage || state.matchedLocation == '/')) return '/dashboard';
      if (!loggedIn && state.matchedLocation == '/') return '/login';
      
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator()))),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const SignupScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          return profileFuture.when(
            data: (profile) {
              if (profile?.role == UserRole.admin) return const AdminDashboard();
              return const EmployeeDashboard();
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
          );
        },
      ),
    ],
  );
});
