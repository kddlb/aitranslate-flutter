import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  AppSettingsState createState() => AppSettingsState();
}

class AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: SettingsScreen(
        hasAppBar: false,
        children: [
          DropDownSettingsTile(title: AppLocalizations.of(context)!.model, settingKey: "model", selected: "gemini-1.5-flash-latest", values: const {
            "gemini-1.5-flash-latest": "Gemini 1.5 Flash",
            "gemini-1.5-pro-latest": "Gemini 1.5 Pro",
          }),
          TextInputSettingsTile(
            title: AppLocalizations.of(context)!.settingsApiKeyLabel,
            settingKey: "openAiApiKey",
            validator: (ak) => (ak != null && ak.isNotEmpty) ? null : AppLocalizations.of(context)!.settingsApiKeyValidatorRequired,
          ),
          SwitchSettingsTile(
            title: AppLocalizations.of(context)!.settingsScrollAutomatically,
            settingKey: "scrollOnChunk",
            leading: const Icon(Icons.arrow_downward),
            defaultValue: true,
          ),
          TextInputSettingsTile(
            title: AppLocalizations.of(context)!.settingsSystemMessageLabel,
            settingKey: "openAiSystemMessage",
            initialValue: "Translate to English.",
            helperText: AppLocalizations.of(context)!.settingsSystemMessageLanguageRecommendation,
            validator: (ak) => (ak != null && ak.isNotEmpty) ? null : AppLocalizations.of(context)!.settingsSystemMessageValidatorRequired,
          ),
          const AboutListTile(icon: Icon(Icons.info), applicationLegalese: "\u{a9} 2024 Kevin López Brante"),
        ],
      ),
    );
  }
}
