// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;  // Current selected index
  final ValueChanged<int> onTabChanged;  // Callback when tab changes

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: GNav(
          backgroundColor: Colors.white,
          color: Theme.of(context).colorScheme.primary,
          tabBackgroundColor: Colors.grey.shade400,
          padding: const EdgeInsets.all(16),
          gap: 8,
          selectedIndex: selectedIndex,
          onTabChange: onTabChanged,
          tabs: const [
            GButton(
              icon: Icons.calendar_today,
              text: 'Schedule',
            ),
            GButton(
              icon: Icons.library_books,
              text: 'Content',
            ),
            GButton(
              icon: Icons.list_rounded,
              text: 'Tasks',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
