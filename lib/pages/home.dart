import 'package:flutter/material.dart';
import 'package:swd_mobile/components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Track the selected tab
  Map<String, bool> _drawerSectionState = {
    "Home": false,
    "Xuất-nhập ngoại": false,
    "Xuất-nhập nội": false,
    "Quản lý hàng hóa": false,
  };

  final List<Widget> tabs = [
    const Center(child: Text('Home', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Search', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context), // Use the function from components.dart
      drawer: buildNavigationDrawer(context, _drawerSectionState, setState), // Use the drawer function
      body: tabs[_currentIndex], // Display the selected tab
      bottomNavigationBar: buildBottomNavigationBar(_currentIndex, (index) {
        if (index == 3) {
          handleLogout(context); // Call the function from components.dart
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      }), // Use the bottom navigation bar function
    );
  }
}
