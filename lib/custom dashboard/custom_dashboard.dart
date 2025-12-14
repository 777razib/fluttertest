/*
import 'package:curve_nav_bar/home/screen/home_screen.dart';
import 'package:flutter/material.dart';

import '../custom nuv bar/custom_bottom_navigation_bar.dart';
import '../favourite/screen/favourite_page.dart';
import '../message/screen/message_screen.dart';
import '../profile/screen/profile_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    FavouritePage(),
    MessagePage(),
     ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

*/
