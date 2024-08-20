import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:telme/models/user_model.dart';
import 'package:telme/services/auth/auth_service.dart';
import 'package:telme/views/widgets/home/clock_timing.dart';
import 'package:telme/views/widgets/home/shift_timing.dart';

class HomeSection extends StatefulWidget {
  final UserModel user;
  const HomeSection({super.key, required this.user});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  // a flag indicator for changing color
  bool isGreen = false;

  @override
  Widget build(BuildContext ctx) {
    final _themeData = Theme.of(ctx);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 157, 32, 215),
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout().then((value) =>
                  Navigator.pushNamedAndRemoveUntil(
                      ctx, '/', (route) => false));
            },
            icon: const Icon(
              Icons.logout_outlined,
              size: 26,
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
        title: Text(
          "Home",
          style: _themeData.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // name of the person

            Expanded(
              flex: 1,
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Hi,",
                      style: _themeData.textTheme.displayMedium,
                      children: [
                        TextSpan(
                            text: " ${widget.user.name ?? 'error'}",
                            style: _themeData.textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.normal))
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        label: Text("Control"),
                        icon: Icon(Icons.phone),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(203, 111, 58, 227),
                          foregroundColor: Colors.white
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        label: Text("Details"),
                        icon: Icon(Icons.file_copy),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(202, 45, 128, 184),
                          foregroundColor: Colors.white,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            // time detials

            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text(
                      "Hickey Pharmacy",
                      style: _themeData.textTheme.titleLarge,
                    ),
                  ),
                  ClockTiming(widget: widget),
                  // ClockButton
                  // ClockButton(),
                  // display start and end timing
                  ShiftTiming(widget: widget),
                  SlideAction(
                    onSubmit: () async {
                      await Future.delayed(Duration(seconds: 25));
                      // Add any further action here that you want to occur after the delay
                      // For example, showing a message or navigating to another screen
                    },
                    outerColor: Color.fromARGB(255, 195, 171, 232),
                    text: "Clock In",
                    borderRadius: 15,
                    elevation: 5,
                    sliderRotate: false,
                    innerColor: Color.fromARGB(255, 147, 97, 221),
                    sliderButtonIcon: Icon(
                      Icons.play_circle_filled_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
