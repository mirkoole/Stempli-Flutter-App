// ignore_for_file: public_member_api_docs, prefer_mixin

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stempli_flutter/main.dart';
import 'package:stempli_flutter/utils/config.dart';

class ThemeProvider with ChangeNotifier {
  bool _darkMode = sharedPreferences.getBool("darkMode") ?? defaultDarkMode;
  int _colorTheme =
      sharedPreferences.getInt("colorTheme") ?? defaultColorTheme.value;

  bool get darkTheme => _darkMode;

  int get colorTheme => _colorTheme;

  /// setDarkTheme
  setDarkTheme(bool value) async {
    _darkMode = value;
    await sharedPreferences.setBool('darkMode', value);
    notifyListeners();
  }

  /// setColorTheme
  setColorTheme(int value) async {
    _colorTheme = value;
    await sharedPreferences.setInt('colorTheme', value);
    notifyListeners();
  }

  /// toggle
  toggle() {
    setDarkTheme(!_darkMode);
  }

  /// toggleColorThemes
  toggleColorThemes() {
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

    if (colorTheme != colors[random].value) {
      setColorTheme(colors[random].value);
    } else {
      toggleColorThemes();
    }
  }
}
