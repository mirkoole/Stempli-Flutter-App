// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

ThemeData getThemeData(bool isDarkMode, int seedColor, BuildContext context) =>
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(seedColor),
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
