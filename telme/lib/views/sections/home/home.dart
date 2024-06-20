import 'package:flutter/material.dart';
import 'package:telme/services/auth/auth_service.dart';
import 'package:telme/views/sections/home/widgets/clock_button.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  // a flag indicator for changing color
  bool isGreen = false;

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
            icon: Icon(Icons.logout_outlined, size: 26,),
          ), 
          SizedBox(width: 20,)
        ],
        title: Text(
          "Home",
          style: _themeData.textTheme.displayMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black26,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // name of the person
            Text("Naiomi Jerry", style: _themeData.textTheme.titleLarge),
            // ClockButton
            Expanded(
              child: ClockButton(),
            ),
          ],
        ),
      ),
    );
  }
}
