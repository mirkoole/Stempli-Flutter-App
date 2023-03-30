import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'package:provider/provider.dart';

import 'themes/provider.dart';
import 'themes/styles.dart';

import 'screens/home.dart';
import 'screens/settings.dart';

void main() async {
  await Settings.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const StempliApp(),
    ),
  );
}

class StempliApp extends StatefulWidget {
  const StempliApp({super.key});

  @override
  State<StempliApp> createState() => _StempliAppState();
}

class _StempliAppState extends State<StempliApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stempli App',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(title: 'Stempli App'),
        '/settings': (context) => const CustomSettingsScreen(title: 'Settings'),
      },
      /*
      onGenerateTitle: (context) => StempliLocalizations.of(context).title,
      localizationsDelegates: const [
        StempliLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'GB'),
        Locale('de', 'DE'),
      ],
      */
      theme: Styles.themeData(context.watch<ThemeProvider>().darkTheme,
          context.watch<ThemeProvider>().colorTheme, context),
    );
  }
}
