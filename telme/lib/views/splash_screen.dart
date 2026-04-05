import 'dart:async';
import 'dart:ui';

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
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              left: -100,
              top: -20,
              child: Container(
                height: 600,
                width: 250,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 177, 127, 242),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                height: 600,
                width: 250,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 152, 100, 198),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: -100,
              child: Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 210, 100, 207),
                  borderRadius: BorderRadius.circular(150),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -100,
              bottom: -50,
              child: Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 98, 91, 196),
                  borderRadius: BorderRadius.circular(150),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            const Positioned(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "TEL\n ME",
                      style: TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 59, 19, 82)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(229, 222, 200, 102),
                        strokeWidth: 10,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
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
