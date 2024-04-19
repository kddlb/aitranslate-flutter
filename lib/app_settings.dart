import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  AppSettingsState createState() => AppSettingsState();
}

class AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: AppLocalizations.of(context)!.settings,
      children: [
        /*SliderSettingsTile(
          title: AppLocalizations.of(context)!.settingsFontSize,
          settingKey: "fontSize",
          min: 12,
          max: 72,
          defaultValue: 16,
          leading: const Icon(Icons.format_size),
        ),*/
        TextInputSettingsTile(
          title: AppLocalizations.of(context)!.settingsApiKeyLabel,
          leading: const Icon(Icons.key),
          settingKey: "openAiApiKey",
          validator: (ak) => (ak != null && ak.isNotEmpty)
              ? null
              : AppLocalizations.of(context)!.settingsApiKeyValidatorRequired,
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
          leading: const Icon(Icons.message),
          subtitle: AppLocalizations.of(context)!
              .settingsSystemMessageLanguageRecommendation,
          validator: (ak) => (ak != null && ak.isNotEmpty)
              ? null
              : AppLocalizations.of(context)!
                  .settingsSystemMessageValidatorRequired,
        ),
        const AboutListTile(
            icon: Icon(Icons.info),
            applicationLegalese: "\u{a9} 2024 Kevin López Brante"),
      ],
    );
  }
}
