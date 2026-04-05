import 'package:flutter/material.dart';

// Define the StatefulWidget ClockButton
class ClockButton extends StatefulWidget {
  ClockButton({super.key});

  @override
  State<ClockButton> createState() => _ClockButtonState();
}

// Define the State class for ClockButton
class _ClockButtonState extends State<ClockButton> {
  // Boolean variable to keep track of the color state
  bool _isGreen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Logic to toggle the color state on long press
      onLongPress: () {
        setState(() {
          _isGreen = !_isGreen;
        });
      },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer AnimatedContainer with gradient background
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isGreen
                      ? [
                          Colors.green[900]!,
                          Colors.green[700]!,
                          Colors.green[500]!,
                          Colors.green[300]!,
                        ]
                      : [
                          Colors.red[900]!,
                          Colors.red[300]!,
                          Colors.red[700]!,
                          Colors.red[500]!,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Inner AnimatedContainer with solid background color
            AnimatedContainer(
              duration: Duration(seconds: 1),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isGreen ? Colors.green[200] : Colors.red[200],
              ),
              alignment: Alignment.center,
              // Text in the center of the button
              child: Text(
                "Clock Out",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
