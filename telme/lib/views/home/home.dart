import 'package:flutter/material.dart';
import 'package:telme/views/home/sections/home_section.dart';
import 'package:telme/views/home/sections/shift_section.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _selectedScreen = 0;

  final List<Widget> _screens = const [
    HomeSection(),
    ShiftSection(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedScreen = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
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