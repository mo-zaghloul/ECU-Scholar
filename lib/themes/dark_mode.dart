import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: const Color(0xFF000000), // Pure black background (iOS dark)
    primary: Colors.white,
    secondary: const Color(0xFF1C1C1E), // Card background (iOS dark card)
    tertiary: const Color(0xFF2C2C2E), // Elevated card background
    inversePrimary: const Color(0xFF5A5A5E),
    error: const Color(0xFFCE1407), // App accent red from logo
  ),
  scaffoldBackgroundColor: const Color(0xFF000000),
);