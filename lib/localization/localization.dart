// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StempliLocalizations {
  StempliLocalizations(this.locale);

  final Locale locale;

  static StempliLocalizations of(BuildContext context) =>
      Localizations.of<StempliLocalizations>(context, StempliLocalizations)!;

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

  String get title => _localizedValues[locale.languageCode]!['title']!;

  String get settings => _localizedValues[locale.languageCode]!['settings']!;
}

class StempliLocalizationsDelegate
    extends LocalizationsDelegate<StempliLocalizations> {
  const StempliLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      StempliLocalizations.languages().contains(locale.languageCode);

  @override
  Future<StempliLocalizations> load(Locale locale) =>
      SynchronousFuture<StempliLocalizations>(StempliLocalizations(locale));

  @override
  bool shouldReload(StempliLocalizationsDelegate old) => false;
}
