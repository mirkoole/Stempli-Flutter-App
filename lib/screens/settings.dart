import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../utils/datetime.dart';

class CustomSettingsScreen extends StatefulWidget {
  const CustomSettingsScreen({super.key, required this.title});

  final String title;

  @override
  State<CustomSettingsScreen> createState() => _CustomSettingsScreenState();
}

class _CustomSettingsScreenState extends State<CustomSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white,
            ),
            onPressed: () => {},
            tooltip: "Help",
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SettingsGroup(
              title: 'Business Settings',
              children: <Widget>[
                DropDownSettingsTile<double>(
                  enabled: false,
                  leading: const Icon(Icons.calendar_month),
                  title: 'Weekly Work Time',
                  settingKey: 'key-weekly-work-time',
                  values: <double, String>{
                    40.0: '40 h -> ${getDailyWorkTimeString(calcWeeklyWorkTimeToDailyWorktime(40, 5))}',
                    39.0: '39 h -> ${getDailyWorkTimeString(calcWeeklyWorkTimeToDailyWorktime(39, 5))}',
                    38.0: '38 h -> ${getDailyWorkTimeString(calcWeeklyWorkTimeToDailyWorktime(38, 5))}',
                    36.0: '36 h -> ${getDailyWorkTimeString(calcWeeklyWorkTimeToDailyWorktime(36, 5))}',
                    35.0: '35 h -> ${getDailyWorkTimeString(calcWeeklyWorkTimeToDailyWorktime(35, 5))}',
                    32.0: '32 h -> ${getDailyWorkTimeString(calcWeeklyWorkTimeToDailyWorktime(32, 5))}',
                  },
                  selected: 40.0,
                  onChange: (value) {
                    debugPrint('key-dropdown-email-view: $value');

                  },
                ),
                DropDownSettingsTile<int>(
                  enabled: false,
                  leading: const Icon(Icons.auto_fix_high),
                  title: 'Adjust Timer Interval',
                  settingKey: 'key-adjust-timer-interval',
                  values: const <int, String>{
                    1: '1 Minute',
                    2: '2 Minutes',
                    3: '3 Minutes',
                    4: '5 Minutes',
                    5: '10 Minutes',
                  },
                  selected: 5,
                ),
              ],
            ),
            SettingsGroup(
              title: 'View Settings',
              children: <Widget>[
                SwitchSettingsTile(
                  settingKey: 'key-seconds-enabled',
                  title: 'Show Seconds',
                  leading: const Icon(Icons.access_time_filled),
                ),
                SwitchSettingsTile(
                  settingKey: 'key-countdown-enabled',
                  title: 'Show Countdown',
                  leading: const Icon(Icons.timer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
