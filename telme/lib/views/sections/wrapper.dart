import 'package:flutter/material.dart';
import 'package:telme/views/sections/home/home.dart';
import 'package:telme/views/sections/shift/shift.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({
    super.key,
  });

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final PageController _pageController = PageController();
  int _selectedScreen = 0;
  final List<Widget> _screens = [
    HomeSection(),
    ShiftSection(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedScreen = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedScreen = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_outlined),
            label: "Shift",
          ),
        ],
        currentIndex: _selectedScreen,
        onTap: _onItemTapped,
      ),
    );
  }
}
