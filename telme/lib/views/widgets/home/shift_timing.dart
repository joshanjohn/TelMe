import 'package:flutter/material.dart';
import 'package:telme/views/sections/home/home.dart';

class ShiftTiming extends StatelessWidget {
  const ShiftTiming({
    super.key,
    required this.widget,
  });

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
            text: "start time\n",
            style: _themeData.textTheme.displayMedium!
                .copyWith(fontStyle: FontStyle.italic),
            children: [
              TextSpan(
                text: "9:00",
                style: _themeData.textTheme.displayMedium!.copyWith(
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
            text: "end time\n",
            style: _themeData.textTheme.displayMedium!
                .copyWith(fontStyle: FontStyle.italic),
            children: [
              TextSpan(
                text: "--/--",
                style: _themeData.textTheme.displayMedium!.copyWith(
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
