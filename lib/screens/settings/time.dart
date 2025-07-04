// ignore_for_file: public_member_api_docs, diagnostic_describe_all_properties

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:duration_picker/duration_picker.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../main.dart';
import '../../utils/config.dart';
import '../../utils/datetime.dart';

class CustomSettingsTimeScreen extends StatefulWidget {
  const CustomSettingsTimeScreen({required this.title, super.key});

  final String title;

  @override
  State<CustomSettingsTimeScreen> createState() =>
      _CustomSettingsTimeScreenState();
}

class _CustomSettingsTimeScreenState extends State<CustomSettingsTimeScreen> {
  int get year => DateTime.now().year;

  bool _customDailyWorkTimes =
      sharedPreferences.getBool("customDailyWorkTimes") ??
          defaultCustomDailyWorkTimes;

  int _dailyWorkTime =
      sharedPreferences.getInt("dailyWorkTime") ?? defaultDailyWorkTime;

  final Map _dailyWorkTimes = {};

  void resetCustomWorkTimes({bool reset = false}) {
    const List days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    if (!reset) {
      for (var element in days) {
        _dailyWorkTimes[element] =
            sharedPreferences.getInt('dailyWorkTime$element') ??
                defaultDailyWorkTime;
      }
    } else {
      for (var element in days) {
        _dailyWorkTimes[element] = _dailyWorkTime;
        sharedPreferences.setInt('dailyWorkTime$element', _dailyWorkTime);
      }

      for (var element in ['sat', 'sun']) {
        // free weekend should be default :)
        _dailyWorkTimes[element] = 0;
        sharedPreferences.setInt('dailyWorkTime$element', 0);
      }
    }
  }

  Future<void> showDurationPickerAndSave(String key) async {
    var resultingDuration = await showDurationPicker(
      context: context,
      initialTime: Duration(seconds: _dailyWorkTimes[key]),
    );

    if (resultingDuration != null) {
      int dailyWorkTime = convertDurationToSeconds(resultingDuration);
      sharedPreferences.setInt("dailyWorkTime$key", dailyWorkTime);
      setState(() {
        _dailyWorkTimes[key] = dailyWorkTime;
      });
    }
  }

  @override
  void initState() {
    resetCustomWorkTimes(reset: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text("Time Settings"),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.timer),
                title: const Text("Daily Work Time"),
                enabled: !_customDailyWorkTimes,
                description: kIsWeb
                    ? !_customDailyWorkTimes
                        ? Text(getDailyWorkTimeString(_dailyWorkTime))
                        : const Text("")
                    : null,
                trailing: !_customDailyWorkTimes
                    ? Text(getDailyWorkTimeString(_dailyWorkTime))
                    : const Text(""),
                onPressed: (context) async {
                  var resultingDuration = await showDurationPicker(
                    context: context,
                    initialTime: Duration(seconds: _dailyWorkTime),
                  );

                  if (resultingDuration != null) {
                    int dailyWorkTime =
                        convertDurationToSeconds(resultingDuration);
                    sharedPreferences.setInt("dailyWorkTime", dailyWorkTime);
                    setState(() {
                      _dailyWorkTime = dailyWorkTime;
                    });
                  }
                },
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.timer),
                title: const Text('Custom Daily Worktimes'),
                description: const Text(
                    "Enable this if your worktime is different on some days (e.g. short friday)."),
                initialValue: _customDailyWorkTimes,
                onToggle: (bool value) {
                  if (value) {
                    resetCustomWorkTimes(reset: true);
                  }

                  setState(() {
                    _customDailyWorkTimes = !_customDailyWorkTimes;
                  });

                  sharedPreferences.setBool(
                      "customDailyWorkTimes", _customDailyWorkTimes);
                },
              ),
            ],
          ),
          _customDailyWorkTimes
              ? SettingsSection(
                  title: const Text("Weekly Work Time Settings"),
                  tiles: [
                    SettingsTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Monday'),
                      description: kIsWeb
                          ? Text(
                              getDailyWorkTimeString(_dailyWorkTimes['mon']),
                            )
                          : null,
                      trailing: Text(
                        getDailyWorkTimeString(_dailyWorkTimes['mon']),
                      ),
                      onPressed: (context) =>
                          {showDurationPickerAndSave('mon')},
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Tuesday'),
                      description: kIsWeb
                          ? Text(
                              getDailyWorkTimeString(_dailyWorkTimes['tue']),
                            )
                          : null,
                      trailing: Text(
                        getDailyWorkTimeString(_dailyWorkTimes['tue']),
                      ),
                      onPressed: (context) =>
                          {showDurationPickerAndSave('tue')},
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Wednesday'),
                      description: kIsWeb
                          ? Text(
                              getDailyWorkTimeString(_dailyWorkTimes['wed']),
                            )
                          : null,
                      trailing: Text(
                        getDailyWorkTimeString(_dailyWorkTimes['wed']),
                      ),
                      onPressed: (context) =>
                          {showDurationPickerAndSave('wed')},
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Thursday'),
                      description: kIsWeb
                          ? Text(
                              getDailyWorkTimeString(_dailyWorkTimes['thu']),
                            )
                          : null,
                      trailing: Text(
                        getDailyWorkTimeString(_dailyWorkTimes['thu']),
                      ),
                      onPressed: (context) =>
                          {showDurationPickerAndSave('thu')},
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Friday'),
                      description: kIsWeb
                          ? Text(
                              getDailyWorkTimeString(_dailyWorkTimes['fri']),
                            )
                          : null,
                      trailing: Text(
                        getDailyWorkTimeString(_dailyWorkTimes['fri']),
                      ),
                      onPressed: (context) =>
                          {showDurationPickerAndSave('fri')},
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Saturday'),
                      description: kIsWeb
                          ? Text(
                              getDailyWorkTimeString(_dailyWorkTimes['sat']),
                            )
                          : null,
                      trailing: Text(
                        getDailyWorkTimeString(_dailyWorkTimes['sat']),
                      ),
                      onPressed: (context) =>
                          {showDurationPickerAndSave('sat')},
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Sunday'),
                      description: kIsWeb
                          ? Text(
                              getDailyWorkTimeString(_dailyWorkTimes['sun']),
                            )
                          : null,
                      trailing: Text(
                        getDailyWorkTimeString(_dailyWorkTimes['sun']),
                      ),
                      onPressed: (context) =>
                          {showDurationPickerAndSave('sun')},
                    ),
                  ],
                )
              : const EmptySettingsPlaceholder(),
        ],
      ),
    );
  }
}

class EmptySettingsPlaceholder extends AbstractSettingsSection {
  const EmptySettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
