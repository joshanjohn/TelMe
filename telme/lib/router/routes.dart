import 'package:go_router/go_router.dart';
import 'package:telme/views/auth/login.dart';
import 'package:telme/views/auth/register.dart';
import 'package:telme/views/sections/wrapper.dart';
import 'package:telme/views/splash_screen.dart';

GoRouter appRouter = GoRouter(routes: [
  GoRoute(path: '/',builder: (context, state) => SplashScreen(),),
  GoRoute(
    path: '/login',
    builder: (context, state) => Login(),
  ),
  GoRoute(
    path: '/register',
    builder: (context, state) => Register(),
  ),
  GoRoute(
    path: '/wrapper',
    builder: (context, state) => Wrapper(),
  )
]);
