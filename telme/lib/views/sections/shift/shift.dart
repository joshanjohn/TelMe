import 'package:flutter/material.dart';
import 'package:telme/services/auth/auth_service.dart';

class ShiftSection extends StatefulWidget {
  const ShiftSection({super.key});

  @override
  State<ShiftSection> createState() => _ShiftSectionState();
}

class _ShiftSectionState extends State<ShiftSection> {
  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout().then((value) =>
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false));
            },
            icon: Icon(
              Icons.logout_outlined,
              size: 26,
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
        title: Text(
          "Shift",
          style: _themeData.textTheme.displayMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black26,
      ),
      body: Container(
        child: ListView(
          children: [],
        ),
      ),
    );
  }
}
