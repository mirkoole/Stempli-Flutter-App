// ignore_for_file: public_member_api_docs, prefer_mixin

import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/config.dart';

class ThemeProvider with ChangeNotifier {
  bool _darkMode = sharedPreferences.getBool("darkMode") ?? defaultDarkMode;
  int _colorTheme =
      sharedPreferences.getInt("colorTheme") ?? defaultColorTheme.toARGB32();

  bool get darkTheme => _darkMode;

  int get colorTheme => _colorTheme;

  /// setDarkTheme
  Future<void> setDarkTheme(bool value) async {
    _darkMode = value;
    await sharedPreferences.setBool('darkMode', value);
    notifyListeners();
  }

  /// setColorTheme
   void setColorTheme(int value) {
    _colorTheme = value;
    sharedPreferences.setInt('colorTheme', value);
    notifyListeners();
  }

  /// toggle
  void toggle() {
    setDarkTheme(!_darkMode);
  }

  /// toggleColorThemes
  void toggleColorThemes() {
    const colors = [
      Colors.green,
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    var random = Random().nextInt(colors.length);

    if (colorTheme != colors[random].toARGB32()) {
      setColorTheme(colors[random].toARGB32());
    } else {
      toggleColorThemes();
    }
  }
}
