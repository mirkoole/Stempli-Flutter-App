// ignore_for_file: public_member_api_docs, diagnostic_describe_all_properties

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:stempli_flutter/main.dart';
import 'package:stempli_flutter/themes/provider.dart';
import 'package:stempli_flutter/utils/config.dart';
import 'package:stempli_flutter/utils/datetime.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomSettingsScreen extends StatefulWidget {
  const CustomSettingsScreen({required this.title, super.key});

  final String title;

  @override
  State<CustomSettingsScreen> createState() => _CustomSettingsScreenState();
}

class _CustomSettingsScreenState extends State<CustomSettingsScreen> {
  int get year => DateTime.now().year;

  final int _dailyWorkTime =
      sharedPreferences.getInt("dailyWorkTime") ?? defaultDailyWorkTime;

  int _adjustInterval =
      sharedPreferences.getInt("adjustInterval") ?? defaultAdjustInterval;

  bool _darkMode = sharedPreferences.getBool("darkMode") ?? defaultDarkMode;
  bool _showSeconds =
      sharedPreferences.getBool("showSeconds") ?? defaultShowSeconds;
  bool _showProgressbar =
      sharedPreferences.getBool("showProgressbar") ?? defaultShowProgressbar;
  bool _showCountdown =
      sharedPreferences.getBool("showCountdown") ?? defaultShowCountdown;
  final bool _customDailyWorkTimes =
      sharedPreferences.getBool("customDailyWorkTimes") ??
          defaultCustomDailyWorkTimes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text("General"),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text("Language"),
                description: kIsWeb ? const Text("English") : null,
                trailing: const Text("English"),
                onPressed: (context) async =>
                    {Navigator.pushNamed(context, '/settings/language')},
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.dark_mode),
                onToggle: (bool value) {
                  context.read<ThemeProvider>().toggle();
                  setState(() {
                    _darkMode = !_darkMode;
                  });
                },
                initialValue: _darkMode,
                title: const Text('Enable Dark Mode'),
              ),
              SettingsTile(
                leading: const Icon(Icons.color_lens),
                title: const Text("App Color"),
                onPressed: (context) {
                  context.read<ThemeProvider>().toggleColorThemes();
                  setState(() {});
                },
                description: kIsWeb
                    ? Text(
                        style: TextStyle(
                          backgroundColor:
                              Color(context.read<ThemeProvider>().colorTheme),
                          color:
                              Color(context.read<ThemeProvider>().colorTheme),
                        ),
                        " cp ")
                    : null,
                trailing: Text(
                    style: TextStyle(
                      backgroundColor:
                          Color(context.read<ThemeProvider>().colorTheme),
                      color: Color(context.read<ThemeProvider>().colorTheme),
                    ),
                    " cp "),
              ),
            ],
          ),
          SettingsSection(
            title: const Text("Time"),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.timer),
                title: const Text("Daily Work Time"),
                description: kIsWeb
                    ? _customDailyWorkTimes
                        ? const Text('custom')
                        : Text(getDailyWorkTimeString(_dailyWorkTime))
                    : null,
                trailing: _customDailyWorkTimes
                    ? const Text('custom')
                    : Text(getDailyWorkTimeString(_dailyWorkTime)),
                onPressed: (context) async => {
                  Navigator.pushNamed(context, '/settings/time')
                      .then((_) => setState(() {}))
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.auto_fix_high),
                title: const Text("Adjust Timer Interval"),
                trailing: Text(getAdjustIntervalMinute(_adjustInterval)),
                description: kIsWeb
                    ? Text(getAdjustIntervalMinute(_adjustInterval))
                    : null,
                onPressed: (context) async {
                  var resultingDuration = await showDurationPicker(
                    context: context,
                    initialTime: Duration(seconds: _adjustInterval),
                    baseUnit: BaseUnit.minute,
                  );

                  if (resultingDuration != null) {
                    int adjustInterval =
                        convertDurationToSeconds(resultingDuration);

                    if (adjustInterval > 60 * 60 * 1) {
                      const snackBar = SnackBar(
                        duration: Duration(seconds: 10),
                        content: Text('Sorry, max. 1 hour interval possible.'),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    } else {
                      sharedPreferences.setInt(
                          "adjustInterval", adjustInterval);

                      setState(() {
                        _adjustInterval = adjustInterval;
                      });
                    }
                  }
                },
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.timer),
                onToggle: (bool value) {
                  setState(() {
                    _showProgressbar = !_showProgressbar;
                  });
                  sharedPreferences.setBool(
                      "showProgressbar", _showProgressbar);
                },
                initialValue: _showProgressbar,
                title: const Text('Show Progressbar'),
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.timer),
                onToggle: (bool value) {
                  setState(() {
                    _showCountdown = !_showCountdown;
                  });
                  sharedPreferences.setBool("showCountdown", _showCountdown);
                },
                initialValue: _showCountdown,
                title: const Text('Show Countdown'),
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.timer),
                onToggle: (bool value) {
                  setState(() {
                    _showSeconds = !_showSeconds;
                  });
                  sharedPreferences.setBool("showSeconds", _showSeconds);
                },
                initialValue: _showSeconds,
                title: const Text('Show Seconds'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text("About"),
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.code),
                title: const Text("App Version"),
                description:
                    kIsWeb ? const Text('$appVersion ($buildVersion)') : null,
                trailing: const Text('$appVersion ($buildVersion)'),
                onPressed: (context) => {
                  launchUrl(Uri.parse(
                      "https://github.com/mirkoole/Stempli-Flutter-App/"))
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.email),
                title: const Text("E-Mail"),
                trailing: const Text("mirko@codepunks.net"),
                description: kIsWeb ? const Text("mirko@codepunks.net") : null,
                onPressed: (context) =>
                    {launchUrl(Uri.parse("https://www.codepunks.net"))},
              ),
              SettingsTile(
                leading: const Icon(Icons.copyright),
                title: Text("$year Mirko Oleszuk"),
                trailing: const Text("codepunks.net"),
                description: kIsWeb ? const Text("codepunks.net") : null,
                onPressed: (context) =>
                    {launchUrl(Uri.parse("https://www.codepunks.net"))},
              )
            ],
          )
        ],
      ),
    );
  }
}
