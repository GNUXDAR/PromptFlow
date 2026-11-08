// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'Cancel';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }

  @override
  String get homeImport => 'Import .txt / .md';

  @override
  String get homeRemote => 'Remote control';

  @override
  String get homeNewScript => 'New script';

  @override
  String homeEditScript(String title) {
    return 'Edit $title';
  }

  @override
  String get homeSampleFileName => 'sample.md';

  @override
  String get homeSampleScript =>
      '# Sample script\n\n## Opening\n[CAM 1] Hello and **welcome** to PromptFlow. This sample script shows\nthe available markers. [PAUSE 2s]\n\nYou can put words in **bold** for emphasis, or ==highlight== them\nwhen they matter.\n\n## Demo\n[CAM 2] [CUE Demo] Now we switch cameras. Automatic pauses stop the text\nfor a few seconds and then continue on their own. [PAUSE 1.5s]\n\nA pause without a duration stops the text until you press Play. [PAUSE]\n\n## Closing\n[CAM 1] Thanks for watching. Control the prompter from your phone with\n**Remote control** mode, or with a Bluetooth pedal.\n';

  @override
  String get editorNameHint => 'name.md';

  @override
  String get editorSave => 'Save (Ctrl+S)';

  @override
  String get editorRehearse => 'Rehearse in the prompter';

  @override
  String editorSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get editorUnsavedTitle => 'Unsaved changes';

  @override
  String get editorUnsavedBody => 'Leave without saving?';

  @override
  String get editorLeave => 'Leave';

  @override
  String get editorBodyHint =>
      '# Title\n\n## Section\n[CAM 1] Script text with **emphasis**. [PAUSE 2s]';

  @override
  String get editorBold => 'Bold';

  @override
  String get editorHighlight => 'Highlight';

  @override
  String get editorSection => '## Section';

  @override
  String get editorPause2s => 'Pause 2s';

  @override
  String get editorPauseManual => 'Manual pause';

  @override
  String get editorCue => 'Cue';

  @override
  String get editorCueSnippet => '[CUE name] ';

  @override
  String editorStats(int words, int markers) {
    return '$words words · $markers markers';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return 'Duration at $wpm WPM: $duration';
  }

  @override
  String get editorTargetHint => 'Target duration';

  @override
  String get editorNoTarget => 'No target';

  @override
  String editorMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get editorPausesExceedTarget => 'The pauses exceed the target';

  @override
  String editorNeededWpm(int wpm) {
    return 'You need $wpm WPM';
  }

  @override
  String get prompterExit => 'Exit (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count remotes',
      one: '1 remote',
      zero: 'no remotes',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'Server stopped';

  @override
  String prompterServerPortError(int port, String message) {
    return 'Could not open port $port: $message';
  }

  @override
  String get prompterBack5 => 'Back 5 s (Page Up)';

  @override
  String get prompterForward5 => 'Forward 5 s (Page Down)';

  @override
  String get prompterPlay => 'Play (Space)';

  @override
  String get prompterPause => 'Pause (Space)';

  @override
  String get prompterSlower => 'Slower (↓)';

  @override
  String get prompterFaster => 'Faster (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · $remaining left';
  }

  @override
  String get prompterVoiceOn => 'Follow my voice';

  @override
  String get prompterVoiceOff => 'Turn off voice following';

  @override
  String get prompterGoToSection => 'Go to section';

  @override
  String get prompterSettings => 'Settings (S)';

  @override
  String get statusPlaying => 'Playing';

  @override
  String statusAutoPaused(String seconds) {
    return 'Pause $seconds s';
  }

  @override
  String get statusAutoPausedShort => 'Automatic pause';

  @override
  String get statusHolding => 'Paused — press Play';

  @override
  String get statusHoldingShort => 'Script pause';

  @override
  String get statusFinished => 'End';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get settingsFontSize => 'Font size';

  @override
  String get settingsLineHeight => 'Line spacing';

  @override
  String get settingsMargin => 'Side margin';

  @override
  String get settingsFocusLine => 'Focus line';

  @override
  String get settingsSpeed => 'Speed';

  @override
  String get settingsTextColor => 'Text color';

  @override
  String get settingsWhite => 'White';

  @override
  String get settingsYellow => 'Yellow';

  @override
  String get settingsMirrorH => 'Horizontal mirror (H)';

  @override
  String get settingsMirrorV => 'Vertical mirror (V)';

  @override
  String get settingsFocusGuide => 'Focus line guide';

  @override
  String get voiceTitle => 'Voice following';

  @override
  String get voiceLanguage => 'Voice language';

  @override
  String voiceStatusDownloading(int percent) {
    return 'Downloading $percent %';
  }

  @override
  String get voiceStatusInstalling => 'Installing model…';

  @override
  String get voiceStatusReady =>
      'Ready: press the HUD microphone and the text will follow your voice';

  @override
  String get voiceStatusNoEngine =>
      'Model installed, but the Vosk engine is missing (on Linux: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'Model not installed ($size MB, downloaded only once)';
  }

  @override
  String voiceDownload(int size) {
    return 'Download model ($size MB)';
  }

  @override
  String voiceDownloadPrompt(String language, int size) {
    return 'Voice following needs the $language speech model ($size MB). It is downloaded once and then works offline. You can change the language in Settings → Voice.';
  }

  @override
  String get voiceErrorNoModel =>
      'Download the voice model in Settings → Voice';

  @override
  String get voiceErrorNoEngine =>
      'Vosk is not installed (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'Microphone permission denied. Allow it in the system settings to use voice following.';

  @override
  String voiceErrorDownload(String message) {
    return 'Could not download the model: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'Voice recognition error: $message';
  }

  @override
  String get remoteTitle => 'Remote control';

  @override
  String get remoteConnectTitle => 'Connect to a prompter';

  @override
  String get remoteReconnecting => 'Reconnecting…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => 'Disconnect';

  @override
  String get remotePinRequired => 'Enter the 4-digit PIN shown on the prompter';

  @override
  String get remoteBadPin => 'Wrong PIN';

  @override
  String remoteConnectFailed(String message) {
    return 'Could not connect: $message';
  }

  @override
  String get remotePinLabel => 'Prompter PIN';

  @override
  String get remoteOnLan => 'On the local network';

  @override
  String get remoteSearch => 'Search';

  @override
  String get remoteNoneFound =>
      'No prompter found. Open it on the Linux computer or use the manual IP.';

  @override
  String get remoteManualIp => 'Manual IP (e.g. 192.168.1.20)';

  @override
  String get remoteConnect => 'Connect';

  @override
  String get remotePosition => 'Position in the script';

  @override
  String remoteRemaining(String remaining) {
    return '$remaining left';
  }

  @override
  String get remoteBack5 => 'Back 5 s';

  @override
  String get remoteForward5 => 'Forward 5 s';

  @override
  String get remotePlay => 'Play';

  @override
  String get remotePause => 'Pause';

  @override
  String get remoteSlower => 'Slower';

  @override
  String get remoteFaster => 'Faster';

  @override
  String get remoteMirrorH => 'Mirror H';

  @override
  String get remoteMirrorV => 'Mirror V';

  @override
  String get remoteFollowVoice => 'Follow voice';

  @override
  String get remoteStart => 'Start';

  @override
  String get remoteSections => 'Sections and cues';

  @override
  String get remoteChangeScript => 'Change script';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutTagline =>
      'Teleprompter for Linux and Android: smooth scrolling, remote control over your local network and offline voice following.';

  @override
  String get aboutCreatedBy => 'Created by';

  @override
  String get aboutFollow => 'Follow';

  @override
  String get aboutProject => 'Project';

  @override
  String get aboutSourceCode => 'Source code';

  @override
  String get aboutContribute => 'Contribute';

  @override
  String get aboutLicense => 'MIT License';

  @override
  String get aboutVoiceCredit =>
      'Offline speech recognition: Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => 'Open-source licenses';

  @override
  String aboutOpenFailed(String url) {
    return 'Could not open $url';
  }
}
