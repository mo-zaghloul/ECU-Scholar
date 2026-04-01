import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../themes/dark_mode.dart';
import '../themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;
  bool _followSystem = true;

  ThemeProvider() {
    // Initialize based on system brightness
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    _themeData = brightness == Brightness.dark ? darkMode : lightMode;
  }

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;
  bool get followsSystem => _followSystem;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  /// Update theme based on system brightness (call when system theme changes)
  void updateFromSystem(Brightness brightness) {
    if (_followSystem) {
      final newTheme = brightness == Brightness.dark ? darkMode : lightMode;
      if (_themeData != newTheme) {
        _themeData = newTheme;
        notifyListeners();
      }
    }
  }

  /// Toggle between light and dark mode manually (disables system follow)
  void toggleTheme() {
    _followSystem = false;
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  /// Re-enable following system theme
  void followSystemTheme() {
    _followSystem = true;
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    updateFromSystem(brightness);
  }
}
