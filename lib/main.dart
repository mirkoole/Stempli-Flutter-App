// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stempli_flutter/screens/home.dart';
import 'package:stempli_flutter/screens/settings.dart';
import 'package:stempli_flutter/screens/settings/language.dart';
import 'package:stempli_flutter/screens/settings/time.dart';
import 'package:stempli_flutter/themes/provider.dart';
import 'package:stempli_flutter/themes/styles.dart';

import 'utils/config.dart';

late SharedPreferences sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();

  if (sharedPreferences.getString("buildVersion") == null) {
    sharedPreferences.clear();
    sharedPreferences.setString("buildVersion", buildVersion);
  }

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
          '/settings/language': (context) =>
              const CustomSettingsLanguageScreen(title: 'Language'),
          '/settings/time': (context) =>
              const CustomSettingsTimeScreen(title: 'Daily Work Time'),
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
