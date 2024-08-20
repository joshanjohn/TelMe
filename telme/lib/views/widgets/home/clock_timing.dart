import 'package:flutter/material.dart';
import 'package:telme/views/sections/home/home.dart';

class ClockTiming extends StatelessWidget {
  const ClockTiming({super.key, required this.widget});

  final HomeSection widget;

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // start time
        RichText(
          text: TextSpan(
            text: "clock In\n",
            style: _themeData.textTheme.displayMedium!
                .copyWith(fontStyle: FontStyle.italic),
            children: [
              TextSpan(
                text: "9:00",
                style: _themeData.textTheme.titleLarge!.copyWith(
                  color: Color.fromARGB(255, 44, 51, 186),
                ),
              )
            ],
          ),
          textAlign: TextAlign.center,
        ),

        // end time
        RichText(
          text: TextSpan(
            text: "clock out\n",
            style: _themeData.textTheme.displayMedium!
                .copyWith(fontStyle: FontStyle.italic),
            children: [
              TextSpan(
                text: "--/--",
                style: _themeData.textTheme.titleLarge!.copyWith(
                  color: Color.fromARGB(255, 44, 51, 186),
                ),
              )
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
