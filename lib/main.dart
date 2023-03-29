import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'themes/themes.dart';
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
      theme: Styles.themeData(context.watch<ThemeProvider>().darkTheme,
          context.watch<ThemeProvider>().colorTheme, context),
    );
  }
}

class StempliLocalizations {
  StempliLocalizations(this.locale);

  final Locale locale;

  static StempliLocalizations of(BuildContext context) {
    return Localizations.of<StempliLocalizations>(
        context, StempliLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'title': 'Stempli App EN',
      'work_countdown': 'Work Countdown',
      'work_time': 'Work Time',
      'break_time': 'Break Time',
      'add_X_work': '',
      'add_X_break': '',
      'move_X_min': '',
      'reset_timer': '',
      'settings': 'Settings',
      'business_settings': '',
      'view_settings': '',
      'weekly_work_hours': '',
      'weekly_work_days': '',
      'daily_work_time': '',
      'adjust_timer_interval': '',
      'show_seconds': '',
      'show_countdown': '',
      'language': '',
      'day': '',
      'days': '',
      'minute': '',
      'minutes': '',
      'toggle_timer': '',
    },
    'de': {
      'title': 'Stempli App DE',
      'work_countdown': 'Arbeitsrunterzähli',
      'work_time': 'Arbeitszeit',
      'break_time': 'Pausenzeit',
      'add_X_work': '',
      'add_X_break': '',
      'move_X_min': '',
      'reset_timer': '',
      'settings': 'Einstellungen',
      'business_settings': '',
      'view_settings': '',
      'weekly_work_hours': '',
      'weekly_work_days': '',
      'daily_work_time': '',
      'adjust_timer_interval': '',
      'show_seconds': '',
      'show_countdown': '',
      'language': '',
      'day': '',
      'days': '',
      'minute': '',
      'minutes': '',
      'toggle_timer': '',
    },
  };

  static List<String> languages() => _localizedValues.keys.toList();

  String get title {
    return _localizedValues[locale.languageCode]!['title']!;
  }

  String get settings {
    return _localizedValues[locale.languageCode]!['settings']!;
  }
}

// #docregion Delegate
class StempliLocalizationsDelegate
    extends LocalizationsDelegate<StempliLocalizations> {
  const StempliLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      StempliLocalizations.languages().contains(locale.languageCode);

  @override
  Future<StempliLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<StempliLocalizations>(
        StempliLocalizations(locale));
  }

  @override
  bool shouldReload(StempliLocalizationsDelegate old) => false;
}

class ThemeProvider with ChangeNotifier {
  bool _darkMode = Settings.getValue<bool>("darkMode", defaultValue: true)!;
  int _colorTheme = Settings.getValue<int>("colorTheme", defaultValue: Colors.blue.value)!;

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
