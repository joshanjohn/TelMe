import 'package:flutter/material.dart';

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
          title: Text(
            "Shift",
            style: _themeData.textTheme.displayMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black26,
        ),
        body: Container(
          child: Center(child: Text("Shift")),
        ));
  }
}
