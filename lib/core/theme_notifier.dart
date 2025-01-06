import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();