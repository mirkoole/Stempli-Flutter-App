// ignore_for_file: public_member_api_docs, diagnostic_describe_all_properties

import 'package:flutter/material.dart';

import 'package:settings_ui/settings_ui.dart';
import 'package:stempli_flutter/main.dart';
import 'package:stempli_flutter/utils/config.dart';

class CustomSettingsLanguageScreen extends StatefulWidget {
  const CustomSettingsLanguageScreen({required this.title, super.key});

  final String title;

  @override
  State<CustomSettingsLanguageScreen> createState() =>
      _CustomSettingsLanguageScreenState();
}

class _CustomSettingsLanguageScreenState
    extends State<CustomSettingsLanguageScreen> {
  get year => DateTime.now().year;

  final String _language =
      sharedPreferences.getString('language') ?? defaultLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text("Language"),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                trailing: _language == 'en' ? const Icon(Icons.check) : null,
                onPressed: (context) {
                  sharedPreferences.setString("language", "en");
                  Navigator.pop(context);
                },
              ),
              SettingsTile(
                enabled: false,
                leading: const Icon(Icons.language),
                title: const Text('Deutsch (bald verfügbar)'),
                trailing: _language == 'de' ? const Icon(Icons.check) : null,
                onPressed: (context) {
                  sharedPreferences.setString("language", "de");
                  Navigator.pop(context);
                },
              ),
              SettingsTile(
                enabled: false,
                leading: const Icon(Icons.language),
                title: const Text('Español'),
                trailing: _language == 'es' ? const Icon(Icons.check) : null,
                onPressed: (context) {
                  sharedPreferences.setString("language", "es");
                  Navigator.pop(context);
                },
              ),
              SettingsTile(
                enabled: false,
                leading: const Icon(Icons.language),
                title: const Text('Français'),
                trailing: _language == 'fr' ? const Icon(Icons.check) : null,
                onPressed: (context) {
                  sharedPreferences.setString("language", "fr");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
