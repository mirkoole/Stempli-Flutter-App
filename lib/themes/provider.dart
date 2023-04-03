// ignore_for_file: public_member_api_docs, prefer_mixin

import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:stempli_flutter/utils/config.dart';

class ThemeProvider with ChangeNotifier {
  bool _darkMode = Settings.getValue<bool>(
    'darkMode',
    defaultValue: true,
  )!;
  int _colorTheme = Settings.getValue<int>(
    'colorTheme',
    defaultValue: defaultColorTheme.value,
  )!;

  /// darkTheme
  bool get darkTheme => _darkMode;

  /// colorTheme
  int get colorTheme => _colorTheme;

  /// setDarkTheme
  Future<void> setDarkTheme(bool value) async {
    _darkMode = value;
    await Settings.setValue('darkMode', value);
    notifyListeners();
  }

  /// setColorTheme
  Future<void> setColorTheme(int value) async {
    _colorTheme = value;
    await Settings.setValue('colorTheme', value);
    notifyListeners();
  }

  /// toggle
  Future<void> toggle() async {
    await setDarkTheme(!_darkMode);
  }
}
