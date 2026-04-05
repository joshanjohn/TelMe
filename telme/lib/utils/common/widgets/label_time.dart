import 'package:flutter/material.dart';
import 'package:telme/utils/helpers/helper_function.dart';

class LabelTime extends StatelessWidget {
  const LabelTime({
    super.key,
    this.time,
    required this.label,
  });
  final DateTime? time;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "$label\n",
        style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(fontStyle: FontStyle.italic),
        children: [
          TextSpan(
            text: (time != null)
                ? AppHelper.extractShiftStamp(dateTime: time!, format: 'HH:mm')
                : "--/--",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color.fromARGB(255, 44, 51, 186),
                ),
          )
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
