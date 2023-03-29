import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:stempli_flutter/main.dart';

import '../utils/datetime.dart';

class CustomSettingsScreen extends StatefulWidget {
  const CustomSettingsScreen({super.key, required this.title});

  final String title;

  @override
  State<CustomSettingsScreen> createState() => _CustomSettingsScreenState();
}

class _CustomSettingsScreenState extends State<CustomSettingsScreen> {
  double _weeklyWorkHours = 0;
  int _weeklyWorkDays = 0;
  String _dailyWorkTime = "...";

  @override
  void initState() {
    _weeklyWorkHours =
        Settings.getValue<double>("weeklyWorkHours", defaultValue: 32)!;
    _weeklyWorkDays =
        Settings.getValue<int>("weeklyWorkDays", defaultValue: 4)!;

    updateDailyWorkTime();

    super.initState();
  }

  updateDailyWorkTime() {
    double dailyWorkTime =
        calcWeeklyWorkTimeToDailyWorktime(_weeklyWorkHours, _weeklyWorkDays);

    if (dailyWorkTime > 10) {
      _dailyWorkTime = "❌👮‍♀️";
    } else {
      _dailyWorkTime = getDailyWorkTimeString(dailyWorkTime);
      Settings.setValue("dailyWorkTime", dailyWorkTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
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
                  onChange: (value) {
                    setState(() {
                      _weeklyWorkHours = value;
                      updateDailyWorkTime();
                      Settings.setValue("weeklyWorkHours", _weeklyWorkHours);
                    });
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
                  selected: _weeklyWorkDays.toInt(),
                  onChange: (value) {
                    setState(() {
                      _weeklyWorkDays = value;
                      updateDailyWorkTime();
                      Settings.setValue("weeklyWorkDays", _weeklyWorkDays);
                    });
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
                  defaultValue: true,
                  settingKey: 'darkMode',
                  title: 'Enable Dark Mode',
                  leading: const Icon(Icons.dark_mode),
                  onChange: (value) {
                    context.read<ThemeProvider>().toggle();
                  },
                ),
                ColorPickerSettingsTile(
                  settingKey: 'colorThemeInt',
                  title: 'Design Color',
                  defaultValue: Colors.blue,
                  leading: const Icon(Icons.color_lens),
                  onChange: (value) {
                    debugPrint('key-color-picker: ${value.value}');
                    context.read<ThemeProvider>().update(value.value);
                  },
                ),
                SwitchSettingsTile(
                  defaultValue: true,
                  settingKey: 'showProgressbar',
                  title: 'Show Progressbar',
                  leading: const Icon(Icons.linear_scale),
                ),
                SwitchSettingsTile(
                  defaultValue: true,
                  settingKey: 'showCountdown',
                  title: 'Show Countdown',
                  leading: const Icon(Icons.alarm),
                ),
                SwitchSettingsTile(
                  defaultValue: true,
                  settingKey: 'showSeconds',
                  title: 'Show Seconds',
                  leading: const Icon(Icons.timer_10),
                ),
                DropDownSettingsTile(
                    enabled: false,
                    leading: const Icon(Icons.language),
                    title: "Language (coming soon)",
                    settingKey: "language",
                    selected: "en",
                    values: const <String, String>{
                      "de": "🇩🇪  Deutsch",
                      "en": "🇬🇧  English"
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
