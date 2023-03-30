import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class ThemeProvider with ChangeNotifier {
  bool _darkMode = Settings.getValue<bool>("darkMode", defaultValue: true)!;
  int _colorTheme =
  Settings.getValue<int>("colorTheme", defaultValue: Colors.blue.value)!;

  bool get darkTheme => _darkMode;

  int get colorTheme => _colorTheme;

  set darkTheme(bool value) {
    _darkMode = value;
    Settings.setValue("darkMode", value);
    notifyListeners();
  }

  set colorTheme(int value) {
    _colorTheme = value;
    Settings.setValue("colorTheme", value);
    notifyListeners();
  }

  void update(int value) {
    colorTheme = value;
  }

  void toggle() {
    darkTheme = !_darkMode;
  }
}
