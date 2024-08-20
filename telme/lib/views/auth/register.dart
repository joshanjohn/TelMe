import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telme/models/user_model.dart';
import 'package:telme/services/auth/auth_service.dart';
import 'package:telme/views/widgets/common/custom_textfield.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // account types for the dropdown menu
  final List<String> accountTypes = ['Employee', 'Employer'];
  late String _selectedType = "Employee";
  String _nameText = "Full Name";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // form key for validation
  final _regKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  // register function
  void _register() async {
    if (_regKey.currentState!.validate()) {
      UserModel user = UserModel(
        name: _nameController.text.trim(),
        access: _selectedType,
        email: _emailController.text.trim(),
      );

      try {
        Future.delayed(const Duration(seconds: 3));
        final userData = await _auth.register(
            user: user, password: _passwordController.text, context: context);

        if (userData?.user != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Successfully created account, login now"),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        List errors = e.toString().split(']');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors[1]),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Image.asset('assets/signup.png', width: 200, height: 200),
                  const SizedBox(height: 20),
                  Form(
                    key: _regKey,
                    child: Column(
                      children: [
                        const Text(
                          'Account Type:',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 10),

                        //dropdown menu for selecting account type
                        DropdownButton(
                          value: _selectedType,
                          items: accountTypes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue!;
                              if (_selectedType == "Employee") {
                                _nameText = "Full Name";
                              }
                              if (_selectedType == "Employer") {
                                _nameText = "Company Name";
                              }
                            });
                          },
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 16),
                          dropdownColor: _themeData.focusColor,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.blue),
                        ),
                        // Name
                        CustomTextField(
                          controller: _nameController,
                          label: "Full Name",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Required a Name";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
                        // Email
                        CustomTextField(
                          controller: _emailController,
                          label: "Email",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Required an Email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password
                        CustomTextField(
                          controller: _passwordController,
                          label: "Password",
                          obsecureText: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Required an password";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // register in option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () => Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false),
                              child: Text(
                                "Login",
                                style: _themeData.textTheme.displaySmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _register,
                          child: const Text('Register'),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
