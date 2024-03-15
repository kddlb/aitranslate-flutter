import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_settings.dart';

void main() {
  Settings.init().then((_) => runApp(MainApp()));
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        title: "AITranslate",
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepOrange,
            textTheme: GoogleFonts.interTightTextTheme()),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepOrange,
            textTheme: GoogleFonts.interTightTextTheme(),
            brightness: Brightness.dark));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _sourceTec = TextEditingController();
  final TextEditingController _translationTec = TextEditingController();

  late LinkedScrollControllerGroup _controllers;
  late ScrollController _sourceScroll;
  late ScrollController _translationScroll;

  bool shouldFabBeVisible = false;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _sourceScroll = _controllers.addAndGet();
    _translationScroll = _controllers.addAndGet();

    var ak = Settings.getValue<String>("openAiApiKey");
    if (ak == null || ak.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.firstRunAlertTitle),
            content:
                Text(AppLocalizations.of(context)!.firstRunAlertDescription),
            actions: <Widget>[
              TextButton(
                  onPressed: () =>
                      {launchUrlString("https://platform.openai.com/api-keys")},
                  child:
                      Text(AppLocalizations.of(context)!.firstRunAlertLinkOut)),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showSettingsModal(context);
                  },
                  child: Text(AppLocalizations.of(context)!.firstRunAlertSet))
            ],
          ),
        );
      });
    }
  }

  void showSettingsModal(BuildContext context) {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      showModalBottomSheet(
          context: context,
          builder: (context) => const AppSettings(),
          elevation: 4.0,
          shape: const RoundedRectangleBorder(),
          showDragHandle: false,
          isScrollControlled: true);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const AppSettings(),
      ));
    }
  }

  @override
  void dispose() {
    _sourceTec.dispose();
    _translationTec.dispose();

    _sourceScroll.dispose();
    _translationScroll.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isWide =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            onPressed: () {
              _sourceTec.text = "";
              _translationTec.text = "";
              shouldFabBeVisible = false;
            },
            icon: const Icon(Icons.backspace),
            tooltip: AppLocalizations.of(context)!.clearTextTooltip,
          ),
          IconButton(
            onPressed: () {
              showSettingsModal(context);
            },
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
          )
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 1280,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        0, 0, isWide ? 8 : 0, isWide ? 0 : 8),
                    child: TextField(
                      controller: _sourceTec,
                      scrollController: _sourceScroll,
                      maxLines: null,
                      expands: true,
                      autofocus: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                          labelText:
                              AppLocalizations.of(context)!.sourceTextLabel),
                      onChanged: (val) => {
                        setState(() {
                          shouldFabBeVisible = val != "";
                        })
                      },
                    ),
                  ),
                ),
                Expanded(
                    child: LoaderOverlay(
                  overlayWholeScreen: false,
                  overlayColor: Colors.black.withOpacity(0),
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutCirc,
                    padding: EdgeInsets.fromLTRB(
                        0, 0, isWide ? 8 : 0, shouldFabBeVisible ? 80 : 0),
                    child: TextField(
                      controller: _translationTec,
                      scrollController: _translationScroll,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      readOnly: true,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        labelText:
                            AppLocalizations.of(context)!.translationLabel,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: shouldFabBeVisible
          ? FloatingActionButton.extended(
              onPressed: onFabPress,
              icon: const Icon(Icons.translate),
              label: Text(AppLocalizations.of(context)!.translateButton),
            )
          : null,
    );
  }

  void onFabPress() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    var value = Settings.getValue<String>("openAiApiKey");

    var scrollOnChunk = Settings.getValue<bool>("scrollOnChunk")!;

    if (value == null || value.isEmpty) {
      var errorSnackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.apiKeyRequired),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.apiKeyRequiredAction,
            onPressed: () => showSettingsModal(context),
          ));
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    } else {
      _sourceScroll.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      context.loaderOverlay.show();
      _translationTec.text = "";
      setState(() {
        shouldFabBeVisible = false;
      });

      OpenAI.apiKey = value;

      final requestMessages = [
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  Settings.getValue<String>("openAiSystemMessage")!)
            ]),
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  _sourceTec.text)
            ]),
      ];

      final chatStream = OpenAI.instance.chat.createStream(
        model: Settings.getValue<String>("openAiModel")!,
        messages: requestMessages,
        maxTokens: 4096,
      );

      chatStream.listen(
        (streamChatCompletion) {
          final content = streamChatCompletion.choices.first.delta.content;
          if (content != null) {
            var completion = content.first?.text ?? "";
            _translationTec.text += completion;
            if (scrollOnChunk) {
              _translationScroll.animateTo(
                  _translationScroll.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            }
          }
        },
        onDone: () {
          print("Done");
          context.loaderOverlay.hide();
        },
      );
    }
  }
}
