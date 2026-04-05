import 'package:flutter/material.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/utils/common/widgets/label_time.dart';

class ClockTiming extends StatelessWidget {
  const ClockTiming({super.key, required this.shift});
  final ShiftModel shift;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // start time
        LabelTime(label: "clock In", time: shift.clockIn),

        // end time
        LabelTime(label: "clock out", time: shift.clockOut),
      ],
    );
  }
}
