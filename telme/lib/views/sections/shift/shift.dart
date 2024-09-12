import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telme/utils/constants/Image_string.dart';
import 'package:telme/views/widgets/shift/list_of_shifts.dart';

class ShiftSection extends StatelessWidget {
  const ShiftSection({super.key});

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 157, 32, 215),
        actions: [
          IconButton(
            onPressed: () => GoRouter.of(context).push('/addShift'),
            icon: const Icon(
              Icons.add_circle_outline,
              size: 30,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 20),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(
             AppImages.shiftIcon,
              width: 40,
              height: 40,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Daily Shifts",
              style: _themeData.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListOfShifts(),
      ),
    );
  }
}
