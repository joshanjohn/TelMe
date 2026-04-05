import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required TextEditingController controller,
    required String label,
    bool? obsecureText,
    String? Function(String?)? validator,
  })  : _controller = controller,
        _label = label,
        _validator = validator,
        _obsecureText = obsecureText;

  final TextEditingController _controller;
  final String _label;
  final bool? _obsecureText;
  final String? Function(String?)? _validator;

  @override
  Widget build(BuildContext context) {
    final ThemeData _themeData = Theme.of(context);

    return TextFormField(
      controller: _controller,
      cursorColor: _themeData.focusColor,
      decoration: InputDecoration(
        labelText: _label,
        labelStyle: TextStyle(color: _themeData.focusColor), // Add this line
        hintStyle: _themeData.textTheme.displayMedium,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _themeData.focusColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _themeData.hintColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: _validator,
      obscureText: _obsecureText ?? false,
    );
  }
}
