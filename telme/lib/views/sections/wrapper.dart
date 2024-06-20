import 'package:flutter/material.dart';
import 'package:telme/views/sections/home/home.dart';
import 'package:telme/views/sections/shift/shift.dart';

// Stateful widget that manages the state of the wrapper
class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

// State class for the Wrapper widget
class _WrapperState extends State<Wrapper> {
  // PageController to control the page view
  final PageController _pageController = PageController();

  // Variable to keep track of the selected screen index
  int _selectedScreen = 0;

  // List of screens (widgets) to be displayed
  final List<Widget> _screens = const [
    HomeSection(), // Home screen
    ShiftSection(), // Shift screen
  ];

  // Method to handle item tap on the bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedScreen = index; // Update the selected screen index
    });
    _pageController.animateToPage(
      index, // Navigate to the selected page
      duration: Duration(milliseconds: 300), // Animation duration
      curve: Curves.ease, // Animation curve
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController, // Attach the PageController
        onPageChanged: (index) {
          setState(() {
            _selectedScreen = index; // Update the selected screen index
          });
        },
        children: _screens, // Display the list of screens
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Icon for the home screen
            label: "Home", // Label for the home screen
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_outlined), // Icon for the shift screen
            label: "Shift", // Label for the shift screen
          ),
        ],
        currentIndex: _selectedScreen, // Set the current index
        onTap: _onItemTapped, // Handle item tap
      ),
    );
  }
}
