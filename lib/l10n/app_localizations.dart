import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// App name. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'PromptFlow'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String commonError(String message);

  /// No description provided for @homeImport.
  ///
  /// In en, this message translates to:
  /// **'Import .txt / .md'**
  String get homeImport;

  /// No description provided for @homeRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote control'**
  String get homeRemote;

  /// No description provided for @homeNewScript.
  ///
  /// In en, this message translates to:
  /// **'New script'**
  String get homeNewScript;

  /// No description provided for @homeEditScript.
  ///
  /// In en, this message translates to:
  /// **'Edit {title}'**
  String homeEditScript(String title);

  /// File name of the sample script created on first run. Keep the .md extension, use only letters, digits and dashes.
  ///
  /// In en, this message translates to:
  /// **'sample.md'**
  String get homeSampleFileName;

  /// Sample script in Markdown. Translate the prose and the section titles. Keep EXACTLY the markup: '#', '##', '**…**', '==…==', and the tags [CAM 1], [CAM 2], [CUE Demo], [PAUSE 2s], [PAUSE 1.5s], [PAUSE] in English and unchanged.
  ///
  /// In en, this message translates to:
  /// **'# Sample script\n\n## Opening\n[CAM 1] Hello and **welcome** to PromptFlow. This sample script shows\nthe available markers. [PAUSE 2s]\n\nYou can put words in **bold** for emphasis, or ==highlight== them\nwhen they matter.\n\n## Demo\n[CAM 2] [CUE Demo] Now we switch cameras. Automatic pauses stop the text\nfor a few seconds and then continue on their own. [PAUSE 1.5s]\n\nA pause without a duration stops the text until you press Play. [PAUSE]\n\n## Closing\n[CAM 1] Thanks for watching. Control the prompter from your phone with\n**Remote control** mode, or with a Bluetooth pedal.\n'**
  String get homeSampleScript;

  /// No description provided for @editorNameHint.
  ///
  /// In en, this message translates to:
  /// **'name.md'**
  String get editorNameHint;

  /// No description provided for @editorSave.
  ///
  /// In en, this message translates to:
  /// **'Save (Ctrl+S)'**
  String get editorSave;

  /// No description provided for @editorRehearse.
  ///
  /// In en, this message translates to:
  /// **'Rehearse in the prompter'**
  String get editorRehearse;

  /// No description provided for @editorSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String editorSavedTo(String path);

  /// No description provided for @editorUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get editorUnsavedTitle;

  /// No description provided for @editorUnsavedBody.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get editorUnsavedBody;

  /// No description provided for @editorLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get editorLeave;

  /// Placeholder of the editor. Keep the markup and the [CAM 1] / [PAUSE 2s] tags unchanged.
  ///
  /// In en, this message translates to:
  /// **'# Title\n\n## Section\n[CAM 1] Script text with **emphasis**. [PAUSE 2s]'**
  String get editorBodyHint;

  /// No description provided for @editorBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get editorBold;

  /// No description provided for @editorHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get editorHighlight;

  /// Toolbar chip that inserts a section heading. Keep the leading '## '.
  ///
  /// In en, this message translates to:
  /// **'## Section'**
  String get editorSection;

  /// No description provided for @editorPause2s.
  ///
  /// In en, this message translates to:
  /// **'Pause 2s'**
  String get editorPause2s;

  /// No description provided for @editorPauseManual.
  ///
  /// In en, this message translates to:
  /// **'Manual pause'**
  String get editorPauseManual;

  /// No description provided for @editorCue.
  ///
  /// In en, this message translates to:
  /// **'Cue'**
  String get editorCue;

  /// Inserted text. Keep '[CUE ' and ']' unchanged, translate only 'name'.
  ///
  /// In en, this message translates to:
  /// **'[CUE name] '**
  String get editorCueSnippet;

  /// No description provided for @editorStats.
  ///
  /// In en, this message translates to:
  /// **'{words} words · {markers} markers'**
  String editorStats(int words, int markers);

  /// No description provided for @editorDurationAt.
  ///
  /// In en, this message translates to:
  /// **'Duration at {wpm} WPM: {duration}'**
  String editorDurationAt(int wpm, String duration);

  /// No description provided for @editorTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Target duration'**
  String get editorTargetHint;

  /// No description provided for @editorNoTarget.
  ///
  /// In en, this message translates to:
  /// **'No target'**
  String get editorNoTarget;

  /// No description provided for @editorMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String editorMinutes(int minutes);

  /// No description provided for @editorPausesExceedTarget.
  ///
  /// In en, this message translates to:
  /// **'The pauses exceed the target'**
  String get editorPausesExceedTarget;

  /// No description provided for @editorNeededWpm.
  ///
  /// In en, this message translates to:
  /// **'You need {wpm} WPM'**
  String editorNeededWpm(int wpm);

  /// No description provided for @prompterExit.
  ///
  /// In en, this message translates to:
  /// **'Exit (Esc)'**
  String get prompterExit;

  /// No description provided for @prompterServerInfo.
  ///
  /// In en, this message translates to:
  /// **'{address}:{port}  PIN {pin}  · {count, plural, =0{no remotes} =1{1 remote} other{{count} remotes}}'**
  String prompterServerInfo(String address, int port, String pin, int count);

  /// No description provided for @prompterServerStopped.
  ///
  /// In en, this message translates to:
  /// **'Server stopped'**
  String get prompterServerStopped;

  /// No description provided for @prompterServerPortError.
  ///
  /// In en, this message translates to:
  /// **'Could not open port {port}: {message}'**
  String prompterServerPortError(int port, String message);

  /// No description provided for @prompterBack5.
  ///
  /// In en, this message translates to:
  /// **'Back 5 s (Page Up)'**
  String get prompterBack5;

  /// No description provided for @prompterForward5.
  ///
  /// In en, this message translates to:
  /// **'Forward 5 s (Page Down)'**
  String get prompterForward5;

  /// No description provided for @prompterPlay.
  ///
  /// In en, this message translates to:
  /// **'Play (Space)'**
  String get prompterPlay;

  /// No description provided for @prompterPause.
  ///
  /// In en, this message translates to:
  /// **'Pause (Space)'**
  String get prompterPause;

  /// No description provided for @prompterSlower.
  ///
  /// In en, this message translates to:
  /// **'Slower (↓)'**
  String get prompterSlower;

  /// No description provided for @prompterFaster.
  ///
  /// In en, this message translates to:
  /// **'Faster (↑)'**
  String get prompterFaster;

  /// No description provided for @prompterWpm.
  ///
  /// In en, this message translates to:
  /// **'{wpm} WPM'**
  String prompterWpm(int wpm);

  /// No description provided for @prompterStatusLine.
  ///
  /// In en, this message translates to:
  /// **'{status} · {remaining} left'**
  String prompterStatusLine(String status, String remaining);

  /// No description provided for @prompterVoiceOn.
  ///
  /// In en, this message translates to:
  /// **'Follow my voice'**
  String get prompterVoiceOn;

  /// No description provided for @prompterVoiceOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off voice following'**
  String get prompterVoiceOff;

  /// No description provided for @prompterGoToSection.
  ///
  /// In en, this message translates to:
  /// **'Go to section'**
  String get prompterGoToSection;

  /// No description provided for @prompterSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings (S)'**
  String get prompterSettings;

  /// No description provided for @statusPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get statusPlaying;

  /// No description provided for @statusAutoPaused.
  ///
  /// In en, this message translates to:
  /// **'Pause {seconds} s'**
  String statusAutoPaused(String seconds);

  /// No description provided for @statusAutoPausedShort.
  ///
  /// In en, this message translates to:
  /// **'Automatic pause'**
  String get statusAutoPausedShort;

  /// No description provided for @statusHolding.
  ///
  /// In en, this message translates to:
  /// **'Paused — press Play'**
  String get statusHolding;

  /// No description provided for @statusHoldingShort.
  ///
  /// In en, this message translates to:
  /// **'Script pause'**
  String get statusHoldingShort;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get statusFinished;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get statusStopped;

  /// No description provided for @settingsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get settingsFontSize;

  /// No description provided for @settingsLineHeight.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get settingsLineHeight;

  /// No description provided for @settingsMargin.
  ///
  /// In en, this message translates to:
  /// **'Side margin'**
  String get settingsMargin;

  /// No description provided for @settingsFocusLine.
  ///
  /// In en, this message translates to:
  /// **'Focus line'**
  String get settingsFocusLine;

  /// No description provided for @settingsSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get settingsSpeed;

  /// No description provided for @settingsTextColor.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get settingsTextColor;

  /// No description provided for @settingsWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get settingsWhite;

  /// No description provided for @settingsYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get settingsYellow;

  /// No description provided for @settingsMirrorH.
  ///
  /// In en, this message translates to:
  /// **'Horizontal mirror (H)'**
  String get settingsMirrorH;

  /// No description provided for @settingsMirrorV.
  ///
  /// In en, this message translates to:
  /// **'Vertical mirror (V)'**
  String get settingsMirrorV;

  /// No description provided for @settingsFocusGuide.
  ///
  /// In en, this message translates to:
  /// **'Focus line guide'**
  String get settingsFocusGuide;

  /// No description provided for @settingsHighlightSpoken.
  ///
  /// In en, this message translates to:
  /// **'Highlight what I say (voice)'**
  String get settingsHighlightSpoken;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice following'**
  String get voiceTitle;

  /// No description provided for @voiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Voice language'**
  String get voiceLanguage;

  /// No description provided for @voiceStatusDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {percent} %'**
  String voiceStatusDownloading(int percent);

  /// No description provided for @voiceStatusInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing model…'**
  String get voiceStatusInstalling;

  /// No description provided for @voiceStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready: press the HUD microphone and the text will follow your voice'**
  String get voiceStatusReady;

  /// No description provided for @voiceStatusNoEngine.
  ///
  /// In en, this message translates to:
  /// **'Model installed, but the Vosk engine is missing (on Linux: tool/setup_vosk_linux.sh)'**
  String get voiceStatusNoEngine;

  /// No description provided for @voiceStatusNoModel.
  ///
  /// In en, this message translates to:
  /// **'Model not installed ({size} MB, downloaded only once)'**
  String voiceStatusNoModel(int size);

  /// No description provided for @voiceDownload.
  ///
  /// In en, this message translates to:
  /// **'Download model ({size} MB)'**
  String voiceDownload(int size);

  /// Shown when the user taps the microphone and the speech model is missing. {language} is the language name in its own language (e.g. Español).
  ///
  /// In en, this message translates to:
  /// **'Voice following needs the {language} speech model ({size} MB). It is downloaded once and then works offline. You can change the language in Settings → Voice.'**
  String voiceDownloadPrompt(String language, int size);

  /// No description provided for @voiceErrorNoModel.
  ///
  /// In en, this message translates to:
  /// **'Download the voice model in Settings → Voice'**
  String get voiceErrorNoModel;

  /// No description provided for @voiceErrorNoEngine.
  ///
  /// In en, this message translates to:
  /// **'Vosk is not installed (tool/setup_vosk_linux.sh)'**
  String get voiceErrorNoEngine;

  /// No description provided for @voiceErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied. Allow it in the system settings to use voice following.'**
  String get voiceErrorPermission;

  /// No description provided for @voiceErrorDownload.
  ///
  /// In en, this message translates to:
  /// **'Could not download the model: {message}'**
  String voiceErrorDownload(String message);

  /// No description provided for @voiceErrorEngine.
  ///
  /// In en, this message translates to:
  /// **'Voice recognition error: {message}'**
  String voiceErrorEngine(String message);

  /// No description provided for @remoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote control'**
  String get remoteTitle;

  /// No description provided for @remoteConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to a prompter'**
  String get remoteConnectTitle;

  /// No description provided for @remoteReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get remoteReconnecting;

  /// No description provided for @remoteRtt.
  ///
  /// In en, this message translates to:
  /// **'RTT {ms} ms'**
  String remoteRtt(String ms);

  /// No description provided for @remoteDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get remoteDisconnect;

  /// No description provided for @remotePinRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit PIN shown on the prompter'**
  String get remotePinRequired;

  /// No description provided for @remoteBadPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get remoteBadPin;

  /// No description provided for @remoteConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect: {message}'**
  String remoteConnectFailed(String message);

  /// No description provided for @remotePinLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompter PIN'**
  String get remotePinLabel;

  /// No description provided for @remoteOnLan.
  ///
  /// In en, this message translates to:
  /// **'On the local network'**
  String get remoteOnLan;

  /// No description provided for @remoteSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get remoteSearch;

  /// No description provided for @remoteNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No prompter found. Open it on the Linux computer or use the manual IP.'**
  String get remoteNoneFound;

  /// No description provided for @remoteManualIp.
  ///
  /// In en, this message translates to:
  /// **'Manual IP (e.g. 192.168.1.20)'**
  String get remoteManualIp;

  /// No description provided for @remoteConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get remoteConnect;

  /// No description provided for @remotePosition.
  ///
  /// In en, this message translates to:
  /// **'Position in the script'**
  String get remotePosition;

  /// No description provided for @remoteRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} left'**
  String remoteRemaining(String remaining);

  /// No description provided for @remoteBack5.
  ///
  /// In en, this message translates to:
  /// **'Back 5 s'**
  String get remoteBack5;

  /// No description provided for @remoteForward5.
  ///
  /// In en, this message translates to:
  /// **'Forward 5 s'**
  String get remoteForward5;

  /// No description provided for @remotePlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get remotePlay;

  /// No description provided for @remotePause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get remotePause;

  /// No description provided for @remoteSlower.
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get remoteSlower;

  /// No description provided for @remoteFaster.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get remoteFaster;

  /// No description provided for @remoteMirrorH.
  ///
  /// In en, this message translates to:
  /// **'Mirror H'**
  String get remoteMirrorH;

  /// No description provided for @remoteMirrorV.
  ///
  /// In en, this message translates to:
  /// **'Mirror V'**
  String get remoteMirrorV;

  /// No description provided for @remoteFollowVoice.
  ///
  /// In en, this message translates to:
  /// **'Follow voice'**
  String get remoteFollowVoice;

  /// No description provided for @remoteStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get remoteStart;

  /// No description provided for @remoteSections.
  ///
  /// In en, this message translates to:
  /// **'Sections and cues'**
  String get remoteSections;

  /// No description provided for @remoteChangeScript.
  ///
  /// In en, this message translates to:
  /// **'Change script'**
  String get remoteChangeScript;

  /// Title of the About screen and tooltip of its button on the home screen.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Teleprompter for Linux and Android: smooth scrolling, remote control over your local network and offline voice following.'**
  String get aboutTagline;

  /// No description provided for @aboutCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get aboutCreatedBy;

  /// No description provided for @aboutFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get aboutFollow;

  /// No description provided for @aboutProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get aboutProject;

  /// No description provided for @aboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSourceCode;

  /// No description provided for @aboutContribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get aboutContribute;

  /// No description provided for @aboutLicense.
  ///
  /// In en, this message translates to:
  /// **'MIT License'**
  String get aboutLicense;

  /// No description provided for @aboutVoiceCredit.
  ///
  /// In en, this message translates to:
  /// **'Offline speech recognition: Vosk (Apache 2.0)'**
  String get aboutVoiceCredit;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String aboutOpenFailed(String url);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
