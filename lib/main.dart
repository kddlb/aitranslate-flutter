import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'app_settings.dart';

void main() {
  Settings.init().then((_) {
    //<editor-fold desc="license for Inter">
    LicenseRegistry.addLicense(() => Stream<LicenseEntry>.value(const LicenseEntryWithLineBreaks(<String>['inter'], '''
Copyright (c) 2016 The Inter Project Authors (https://github.com/rsms/inter)

This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is copied below, and is also available with a FAQ at:
http://scripts.sil.org/OFL

-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded,
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply
to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software components as
distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting,
or substituting -- in part or in whole -- any of the components of the
Original Version, by changing formats or by porting the Font Software to a
new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION AND CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font
Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components,
in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the corresponding
Copyright Holder. This restriction only applies to the primary font name as
presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created
using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.''')));
    //</editor-fold>
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        title: "AITranslate",
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange, fontFamily: 'Inter Variable LoSnoCo'),
        darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange, brightness: Brightness.dark));
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
  bool shouldProgressBeVisible = false;

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
            content: Text(AppLocalizations.of(context)!.firstRunAlertDescription),
            actions: <Widget>[
              TextButton(onPressed: () => {launchUrlString("https://aistudio.google.com/app/apikey")}, child: Text(AppLocalizations.of(context)!.firstRunAlertLinkOut)),
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
    if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) {
      showModalBottomSheet(context: context, builder: (context) => const AppSettings(), elevation: 4.0, shape: const RoundedRectangleBorder(), showDragHandle: false, isScrollControlled: true);
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

  final clipboard = SystemClipboard.instance;

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        bottom: shouldProgressBeVisible
            ? const PreferredSize(
                preferredSize: Size.fromHeight(6.0),
                child: LinearProgressIndicator(
                  value: null,
                ),
              )
            : null,
        actions: [
          if (clipboard != null)
            IconButton(
              onPressed: () async {
                final item = DataWriterItem();
                item.add(Formats.plainText(_translationTec.text));
                await clipboard!.write([item]);
              },
              icon: const Icon(Icons.content_copy),
              tooltip: AppLocalizations.of(context)!.copy,
            ),
          if (clipboard != null)
            IconButton(
              onPressed: () async {
                final reader = await clipboard!.read();

                if (reader.canProvide(Formats.htmlText)) {
                  final html = await reader.readValue(Formats.htmlText);
                  _sourceTec.text = html!;
                }

                if (reader.canProvide(Formats.plainText)) {
                  final text = await reader.readValue(Formats.plainText);
                  _sourceTec.text = text!;
                }

                setState(() {
                  shouldFabBeVisible = true;
                });
              },
              icon: const Icon(Icons.content_paste),
              tooltip: AppLocalizations.of(context)!.paste,
            ),
          IconButton(
            onPressed: shouldProgressBeVisible
                ? null
                : () {
                    _sourceTec.text = "";
                    _translationTec.text = "";
                    shouldFabBeVisible = false;
                  },
            icon: const Icon(Icons.backspace),
            tooltip: AppLocalizations.of(context)!.clearTextTooltip,
          ),
          IconButton(
            onPressed: shouldProgressBeVisible
                ? null
                : () {
                    showSettingsModal(context);
                  },
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, isWide ? 8 : 0, isWide ? 0 : 8),
                  child: TextField(
                    controller: _sourceTec,
                    scrollController: _sourceScroll,
                    maxLines: null,
                    expands: true,
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(border: const OutlineInputBorder(), alignLabelWithHint: true, labelText: AppLocalizations.of(context)!.sourceTextLabel),
                    onChanged: (val) => {
                      setState(() {
                        shouldFabBeVisible = val != "";
                      })
                    },
                  ),
                ),
              ),
              Expanded(
                  child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutCirc,
                padding: EdgeInsets.fromLTRB(0, 0, 0, shouldFabBeVisible ? 80 : 0),
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
                    labelText: AppLocalizations.of(context)!.translationLabel,
                  ),
                ),
              )),
            ],
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

    var selectedModel = Settings.getValue<String>("model") ?? "gemini-1.5-flash-latest";

    if (value == null || value.isEmpty) {
      var errorSnackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.apiKeyRequired),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.apiKeyRequiredAction,
            onPressed: () => showSettingsModal(context),
          ));
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    } else {
      _sourceScroll.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      _translationTec.text = "";
      setState(() {
        shouldProgressBeVisible = true;
        shouldFabBeVisible = false;
      });

      final model = GenerativeModel(
          model: selectedModel,
          apiKey: value,
          requestOptions: const RequestOptions(apiVersion: "v1beta"),
          safetySettings: [SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none), SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none), SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none), SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none)],
          systemInstruction: Content.system(Settings.getValue<String>("openAiSystemMessage")!));

      final generationStream = model.generateContentStream([Content.text(_sourceTec.text)]);

      generationStream.listen((event) {
        _translationTec.text += event.text ?? "";
        if (scrollOnChunk) {
          _translationScroll.animateTo(_translationScroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        }
      }, onDone: () {
        if (scrollOnChunk) {
          _translationScroll.animateTo(_translationScroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        }
        setState(() {
          shouldProgressBeVisible = false;
        });
      }, onError: (err) {
        setState(() {
          shouldProgressBeVisible = false;
        });
        var errorSnackBar = SnackBar(
          content: Text("Error: $err"),
        );
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
      });
    }
  }
}
