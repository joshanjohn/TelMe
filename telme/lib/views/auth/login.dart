import 'package:flutter/material.dart';
import 'package:telme/services/auth_services/auth_service.dart';
import 'package:telme/views/widgets/common/custom_textfield.dart';

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100), // Add some spacing at the top
              Image.asset(
                'assets/signin.png',
                width: 250,
                height: 250,
              ),
              const SizedBox(
                  height:
                      50), // Add some spacing between the image and the form
              Form(
                key: _authKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: "Email",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Required an Email Id";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      label: "Password",
                      obsecureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Required a password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // register in option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Doesn't have an account?"),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () => Navigator.pushNamedAndRemoveUntil(
                              context, '/register', (route) => false),
                          child: Text(
                            "Register",
                            style: _themeData.textTheme.displaySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (_authKey.currentState!.validate()) {
                          _authService.login(_emailController.text.trim(),
                              _passwordController.text.trim(), context);
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
