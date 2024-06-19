import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:telme/services/auth_service.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  //controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _authKey = GlobalKey<FormState>();

  // String _errorMessage = 'test';

  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<void> _login() async {
  //   try {
  //     //try get credentials from supplied email and password
  //     UserCredential credential = await _auth.signInWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //     //just a test to see if we were able to login
  //     setState(() {
  //       _errorMessage = "you have logged in. welcome!";
  //     });
  //   } catch (err) {
  //     setState(() {
  //       _errorMessage = err.toString();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final ThemeData _themeData = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(width: 200, height: 200, 'assets/logo.png'),
            ),
            Expanded(
              child: Form(
                key: _authKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      cursorColor: _themeData.focusColor,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color: _themeData.focusColor), // Add this line
                        hintStyle: _themeData.textTheme.displayMedium,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _themeData.focusColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _themeData.hintColor),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Required an Email Id";
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      cursorColor: _themeData.focusColor,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: _themeData.focusColor), // Add this line
                        hintStyle: _themeData.textTheme.displayMedium,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _themeData.focusColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _themeData.hintColor),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Required an password";
                        }
                      },
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_authKey.currentState!.validate()) {
                          login(_emailController.text.trim(),
                              _passwordController.text.trim(), context);
                        }
                      },
                      child: Text('Login'),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
