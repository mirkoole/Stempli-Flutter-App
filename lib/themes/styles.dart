import 'package:flutter/material.dart';


class Styles {
  static ThemeData themeData(
      bool isDarkMode, int seedColor, BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(seedColor),
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }
}
