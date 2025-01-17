import 'package:ecu_scholar/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:ecu_scholar/pages/schedule_page.dart';
import 'package:ecu_scholar/pages/content_page.dart';
import 'package:ecu_scholar/pages/tasks_page.dart';
import 'package:ecu_scholar/pages/profile_page.dart';

import '../constants/text_styles.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Selected index for the bottom navigation bar
  int _selectedIndex = 0;

  // List of screens to navigate to
  final List<Widget> _pages = [
    const SchedulePage(), // Placeholder for Schedule screen
     ContentPage(),  // Placeholder for Content screen
     TasksPage(),    // Placeholder for Tasks screen
     ProfilePage(),  // Placeholder for Profile screen
  ];

  // Method to handle tab changes
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,       // Pass selected index
        onTabChanged: _navigateBottomBar,         // Handle tab change
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      
      body: _pages[_selectedIndex],  // Display the selected screen
    );
  }
}
