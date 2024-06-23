import 'package:flutter/material.dart';
import 'package:telme/services/auth/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService();
  //controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _authKey = GlobalKey<FormState>();

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
              child: Image.asset(width: 130, height: 130, 'assets/logo.png'),
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

                    // register in option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Does'nt have an account?"),
                        SizedBox(width: 5),
                        InkWell(
                          onTap: ()=>Navigator.pushNamed(context, '/register'),
                          child: Text(
                            "Register",
                            style: _themeData.textTheme.displaySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (_authKey.currentState!.validate()) {
                          _authService.login(_emailController.text.trim(),
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
