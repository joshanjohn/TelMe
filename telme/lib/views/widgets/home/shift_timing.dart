import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/utils/common/widgets/label_time.dart';

class ShiftTiming extends StatelessWidget {
  const ShiftTiming({
    super.key, required this.shift,
  });
  final ShiftModel shift;

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // start time
        LabelTime(label: "start time", time: shift.startTime,),

        // end time
        LabelTime(label: "end time", time: shift.endTime,)
      ],
    );
  }
}
