import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telme/models/user_model.dart';
import 'package:telme/services/auth/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // account types for the dropdown menu
  final List<String> accountTypes = ['Employee', 'Employer'];
  late String _selectedType;
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
        access: "user",
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        Future.delayed(Duration(seconds: 3));
        final userData = await _auth.register(user, _selectedType);

        if (userData.user != null) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
        padding: EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 130, height: 130),
                SizedBox(height: 20),
                Form(
                  key: _regKey,
                  child: Column(
                    children: [
                      const Text(
                        'Account Type:',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 10),

                      //dropdown menu for selecting account type
                      DropdownButton(
                        items: accountTypes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedType = newValue!;
                            if(_selectedType=="Employee"){
                              _nameText="Full Name";
                            }
                            if(_selectedType=="Employer"){
                              _nameText="Company Name";
                            }
                          });
                        },
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                        dropdownColor: _themeData.focusColor,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                      ),
                      // Name
                      TextFormField(
                        controller: _nameController,
                        cursorColor: _themeData.focusColor,
                        decoration: InputDecoration(
                          labelText: _nameText,
                          labelStyle: TextStyle(color: _themeData.focusColor),
                          hintStyle: _themeData.textTheme.displayMedium,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: _themeData.focusColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _themeData.hintColor),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Required a Name";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        cursorColor: _themeData.focusColor,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: _themeData.focusColor),
                          hintStyle: _themeData.textTheme.displayMedium,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: _themeData.focusColor),
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
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        cursorColor: _themeData.focusColor,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: _themeData.focusColor),
                          hintStyle: _themeData.textTheme.displayMedium,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: _themeData.focusColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _themeData.hintColor),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Required a password";
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      // register in option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account?"),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, '/login'),
                            child: Text(
                              "Login",
                              style: _themeData.textTheme.displaySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _register,
                        child: Text('Register'),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
