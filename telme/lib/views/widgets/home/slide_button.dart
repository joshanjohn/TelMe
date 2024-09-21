import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/shift_services/shift_service.dart';

class SlideButton extends StatelessWidget {
  const SlideButton({
    super.key,
    required this.shift,
  });

  final ShiftModel shift;

  @override
  Widget build(BuildContext context) {
    return SlideAction(
      onSubmit: () async {
        ShiftService shiftService = ShiftService();
        if (shift.clockIn == null) {
          shiftService.markClockIn(shift.shiftId!);
        } else {
          shiftService.markClockOut(shift.shiftId!);
        }
        await Future.delayed(const Duration(seconds: 4));
      },
      outerColor: const Color.fromARGB(255, 195, 171, 232),
      text: (shift.clockIn == null) ? "Clock In" : "ClockOut",
      textColor: const Color.fromARGB(144, 115, 50, 128),
      borderRadius: 15,
      elevation: 4,
      sliderRotate: false,
      innerColor: const Color.fromARGB(255, 147, 97, 221),
      sliderButtonIcon: const Icon(
        Icons.play_circle_filled_rounded,
        color: Colors.white,
      ),
    );
  }
}
