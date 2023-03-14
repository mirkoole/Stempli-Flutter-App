import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'screens/home.dart';
import 'screens/settings.dart';

void main() async {
  await Settings.init();

  runApp(const StempliApp());
}

class StempliApp extends StatelessWidget {
  const StempliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stempli App',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(title: 'Stempli App'),
        '/settings': (context) => const CustomSettingsScreen(title: 'Settings'),
      },
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.blue,
          onPrimary: Colors.white,
          secondary: Colors.blue,
          onSecondary: Colors.white,
          background: Colors.grey,
          onBackground: Colors.white70,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.blue,
          onSurface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.blue,
          onPrimary: Colors.white,
          secondary: Colors.blue,
          onSecondary: Colors.white70,
          background: Colors.black54,
          onBackground: Colors.white70,
          error: Colors.red,
          onError: Colors.black87,
          surface: Colors.blue,
          onSurface: Colors.white,
        ),
        dividerColor: Colors.black12,
      ),
    );
  }
}
