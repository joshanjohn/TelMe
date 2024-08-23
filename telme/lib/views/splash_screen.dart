import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Splash Screen", style: TextStyle(fontSize: 32),),
      ),
    );
  }

  void isLogin() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String? _userId = _pref.getString("userId");
    print("isLogin user id = $_userId");

    if (_userId != null) {
      Timer(const Duration(seconds: 3), () {
        context.go('/wrapper');
      });
    } else {
      Timer(const Duration(seconds: 3), () {
        context.go('/login');
      });
    }
  }
}
