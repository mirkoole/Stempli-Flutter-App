// ignore_for_file: public_member_api_docs, diagnostic_describe_all_properties

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:stempli_flutter/themes/provider.dart';
import 'package:stempli_flutter/utils/config.dart';
import 'package:stempli_flutter/utils/datetime.dart';

class CustomSettingsScreen extends StatefulWidget {
  const CustomSettingsScreen({required this.title, super.key});

  final String title;

  @override
  State<CustomSettingsScreen> createState() => _CustomSettingsScreenState();
}

class _CustomSettingsScreenState extends State<CustomSettingsScreen> {
  double _weeklyWorkHours = 0;
  int _weeklyWorkDays = 0;
  String _dailyWorkTime = '...';

  @override
  void initState() {
    _weeklyWorkHours = Settings.getValue<double>(
      'weeklyWorkHours',
      defaultValue: defaultWeeklyWorkHours,
    )!;
    _weeklyWorkDays = Settings.getValue<int>(
      'weeklyWorkDays',
      defaultValue: defaultWeeklyWorkDays,
    )!;

    unawaited(updateDailyWorkTime());

    super.initState();
  }

  Future<void> updateDailyWorkTime() async {
    final dailyWorkTime =
        calcWeeklyWorkTimeToDailyWorktime(_weeklyWorkHours, _weeklyWorkDays);

    if (dailyWorkTime > 10) {
      _dailyWorkTime = '❌👮‍♀️';
    } else {
      _dailyWorkTime = getDailyWorkTimeString(dailyWorkTime);
      await Settings.setValue('dailyWorkTime', dailyWorkTime);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              SettingsGroup(
                title: 'Business Settings',
                children: <Widget>[
                  DropDownSettingsTile<double>(
                    leading: const Icon(Icons.calendar_month),
                    title: 'Weekly Work Hours',
                    settingKey: 'weeklyWorkHours',
                    values: <double, String>{
                      40.0: '40 h',
                      39.0: '39 h',
                      38.0: '38 h',
                      36.0: '36 h',
                      35.0: '35 h',
                      32.0: '32 h',
                      30.0: '30 h',
                      24.0: '24 h',
                      20.0: '20 h',
                    },
                    selected: _weeklyWorkHours,
                    onChange: (value) async {
                      _weeklyWorkHours = value;
                      await updateDailyWorkTime();
                      await Settings.setValue(
                        'weeklyWorkHours',
                        _weeklyWorkHours,
                      );
                      setState(() {});
                    },
                  ),
                  DropDownSettingsTile<int>(
                    leading: const Icon(Icons.calendar_month),
                    title: 'Weekly Work Days',
                    settingKey: 'weeklyWorkDays',
                    values: const <int, String>{
                      6: '6 Days',
                      5: '5 Days',
                      4: '4 Days',
                      3: '3 Days',
                      2: '2 Days',
                      1: '1 Day',
                    },
                    selected: _weeklyWorkDays,
                    onChange: (value) async {
                      _weeklyWorkDays = value;
                      await updateDailyWorkTime();
                      await Settings.setValue(
                        'weeklyWorkDays',
                        _weeklyWorkDays,
                      );
                      setState(() {});
                    },
                  ),
                  DropDownSettingsTile<int>(
                    leading: const Icon(Icons.timer),
                    title: 'Daily Work Time',
                    settingKey: 'ignoreMe2',
                    enabled: false,
                    values: <int, String>{
                      1: _dailyWorkTime,
                    },
                    selected: 1,
                  ),
                  DropDownSettingsTile<int>(
                    leading: const Icon(Icons.auto_fix_high),
                    title: 'Adjust Timer Interval',
                    settingKey: 'adjustInterval',
                    values: const <int, String>{
                      60 * 1: '1 Minute',
                      60 * 2: '2 Minutes',
                      60 * 3: '3 Minutes',
                      60 * 5: '5 Minutes',
                      60 * 10: '10 Minutes',
                    },
                    selected: 60 * 10,
                  ),
                ],
              ),
              SettingsGroup(
                title: 'View Settings',
                children: <Widget>[
                  SwitchSettingsTile(
                    defaultValue: defaultDarkMode,
                    settingKey: 'darkMode',
                    title: 'Enable Dark Mode',
                    leading: const Icon(Icons.dark_mode),
                    onChange: (value) async {
                      await context.read<ThemeProvider>().toggle();
                    },
                  ),
                  ColorPickerSettingsTile(
                    settingKey: 'colorThemeInt',
                    title: 'Design Color',
                    defaultValue: Color(
                      Settings.getValue<int>(
                        'colorTheme',
                        defaultValue: defaultColorTheme.value,
                      )!,
                    ),
                    leading: const Icon(Icons.color_lens),
                    onChange: (value) async {
                      debugPrint('key-color-picker: ${value.value}');
                      await context
                          .read<ThemeProvider>()
                          .setColorTheme(value.value);
                    },
                  ),
                  SwitchSettingsTile(
                    defaultValue: defaultShowProgressbar,
                    settingKey: 'showProgressbar',
                    title: 'Show Progressbar',
                    leading: const Icon(Icons.linear_scale),
                  ),
                  SwitchSettingsTile(
                    defaultValue: defaultShowCountdown,
                    settingKey: 'showCountdown',
                    title: 'Show Countdown',
                    leading: const Icon(Icons.alarm),
                  ),
                  SwitchSettingsTile(
                    defaultValue: defaultShowSeconds,
                    settingKey: 'showSeconds',
                    title: 'Show Seconds',
                    leading: const Icon(Icons.timer_10),
                  ),
                  DropDownSettingsTile(
                    enabled: false,
                    leading: const Icon(Icons.language),
                    title: 'Language (soon)',
                    settingKey: 'language',
                    selected: 'en',
                    values: const <String, String>{
                      'de': '🇩🇪  Deutsch',
                      'en': '🇬🇧  English'
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      );
}
