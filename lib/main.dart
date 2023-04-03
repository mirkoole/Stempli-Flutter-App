// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:stempli_flutter/screens/home.dart';
import 'package:stempli_flutter/screens/settings.dart';
import 'package:stempli_flutter/themes/provider.dart';
import 'package:stempli_flutter/themes/styles.dart';

void main() async {
  await Settings.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const StempliApp(),
    ),
  );
}

class StempliApp extends StatelessWidget {
  const StempliApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Stempli',
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(title: 'Stempli'),
          '/settings': (context) =>
              const CustomSettingsScreen(title: 'Settings'),
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
        theme: getThemeData(
          context.watch<ThemeProvider>().darkTheme,
          context.watch<ThemeProvider>().colorTheme,
          context,
        ),
      );
}
