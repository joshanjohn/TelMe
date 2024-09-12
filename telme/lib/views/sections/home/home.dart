import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:go_router/go_router.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/models/user_model.dart';
import 'package:telme/services/auth_services/auth_service.dart';
import 'package:telme/services/shift_services/shift_service.dart';
import 'package:telme/services/user_services/user_service.dart';
import 'package:telme/utils/constants/Image_string.dart';
import 'package:telme/views/widgets/home/clock_timing.dart';
import 'package:telme/views/widgets/home/shift_timing.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      user = await UserService().getUserInfo();
      print("User fetched successfully: ${user?.name}");
    } catch (e) {
      print("Error fetching user info: $e");
      // Optionally handle error state
    } finally {
      setState(() {}); // Trigger a rebuild after fetching
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final _themeData = Theme.of(ctx);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 157, 32, 215),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().logout().then((value) {
                GoRouter.of(context).go('/login');
              });
            },
            icon: const Icon(Icons.logout_outlined, size: 26),
          ),
          const SizedBox(width: 20)
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
                          text: " ${user!.name}",
                          style: _themeData.textTheme.titleLarge!
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await FlutterPhoneDirectCaller.callNumber(
                              "+3530899600979");
                        },
                        label: const Text("Control"),
                        icon: const Icon(Icons.phone),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(203, 111, 58, 227),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        label: const Text("Details"),
                        icon: const Icon(Icons.file_copy),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(202, 45, 128, 184),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: StreamBuilder(
                stream: ShiftService().getUpcomingShift(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData && snapshot.data == null) {
                    return Center(
                        child: Column(
                      children: [
                        Text("No Shift found",
                            style: _themeData.textTheme.titleLarge!.copyWith(color: Colors.purple)),
                        Image.asset(AppImages.no_shift)
                      ],
                    ));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    final ShiftModel shift = snapshot.data!;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: Text(
                            shift.name,
                            style: _themeData.textTheme.titleLarge,
                          ),
                        ),
                        ClockTiming(widget: widget),
                        ShiftTiming(widget: widget),
                        SlideAction(
                          onSubmit: () async {
                            await Future.delayed(const Duration(seconds: 25));
                            // Add further actions here
                          },
                          outerColor: const Color.fromARGB(255, 195, 171, 232),
                          text: "Clock In",
                          textColor: const Color.fromARGB(144, 115, 50, 128),
                          borderRadius: 15,
                          elevation: 4,
                          sliderRotate: false,
                          innerColor: const Color.fromARGB(255, 147, 97, 221),
                          sliderButtonIcon: const Icon(
                            Icons.play_circle_filled_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
