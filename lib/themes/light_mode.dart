import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: const Color(0xFFF2F2F7), // iOS-style light gray background
    primary: Colors.black,
    secondary: const Color(0xFFE5E5EA), // Card background
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade700,
    error: const Color(0xFFCE1407), // App accent red from logo
  ),
  scaffoldBackgroundColor: const Color(0xFFF2F2F7),
);