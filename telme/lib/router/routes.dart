import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/models/profile_model.dart';
import 'package:telme/views/auth/login_screen.dart';
import 'package:telme/views/auth/signup_screen.dart';
import 'package:telme/views/admin/admin_dashboard.dart';
import 'package:telme/views/employee/employee_dashboard.dart';
import 'package:telme/views/employee/shift_details_page.dart';
import 'package:telme/views/employee/clock_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileFuture = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.value?.session?.user;
      final loggedIn = user != null;
      final isAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!loggedIn && !isAuthPage) return '/login';
      if (loggedIn && (isAuthPage || state.matchedLocation == '/')) return '/dashboard';
      
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator()))),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const SignupScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final profile = profileFuture.value;
          if (profile?.role == UserRole.admin) return const AdminDashboard();
          return const EmployeeDashboard();
        },
      ),
      GoRoute(
        path: '/shift/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ShiftDetailsPage(shiftId: id);
        },
      ),
      GoRoute(
        path: '/clock',
        builder: (context, state) => const ClockPage(),
      ),
    ],
  );
});
