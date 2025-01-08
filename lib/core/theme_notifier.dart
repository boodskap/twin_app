import 'package:flutter/material.dart';
import 'package:twin_commons/core/storage.dart';
import 'package:twin_app/core/session_variables.dart' as session;

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme = session.defaultDarkTheme;

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme(bool value) {
    _isDarkTheme = value;
    Storage.putBool('theme.dark', value);
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();
