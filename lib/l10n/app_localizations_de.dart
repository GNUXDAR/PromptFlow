// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String commonError(String message) {
    return 'Fehler: $message';
  }

  @override
  String get homeImport => '.txt / .md importieren';

  @override
  String get homeRemote => 'Fernbedienung';

  @override
  String get homeNewScript => 'Neues Skript';

  @override
  String homeEditScript(String title) {
    return '$title bearbeiten';
  }

  @override
  String get homeSampleFileName => 'beispiel.md';

  @override
  String get homeSampleScript =>
      '# Beispielskript\n\n## Einstieg\n[CAM 1] Hallo und **willkommen** bei PromptFlow. Dieses Beispielskript zeigt\ndie verfügbaren Markierungen. [PAUSE 2s]\n\nDu kannst Wörter zur Betonung **fett** setzen oder sie ==hervorheben==,\nwenn sie wichtig sind.\n\n## Demo\n[CAM 2] [CUE Demo] Jetzt wechseln wir die Kamera. Automatische Pausen halten den Text\nein paar Sekunden an, danach läuft er von selbst weiter. [PAUSE 1.5s]\n\nEine Pause ohne Dauer hält den Text an, bis du auf Abspielen drückst. [PAUSE]\n\n## Abschluss\n[CAM 1] Danke fürs Zuschauen. Steuere den Prompter mit dem Handy im Modus\n**Fernbedienung** oder mit einem Bluetooth-Pedal.\n';

  @override
  String get editorNameHint => 'name.md';

  @override
  String get editorSave => 'Speichern (Strg+S)';

  @override
  String get editorRehearse => 'Im Prompter proben';

  @override
  String editorSavedTo(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String get editorUnsavedTitle => 'Ungespeicherte Änderungen';

  @override
  String get editorUnsavedBody => 'Ohne Speichern verlassen?';

  @override
  String get editorLeave => 'Verlassen';

  @override
  String get editorBodyHint =>
      '# Titel\n\n## Abschnitt\n[CAM 1] Skripttext mit **Betonung**. [PAUSE 2s]';

  @override
  String get editorBold => 'Fett';

  @override
  String get editorHighlight => 'Hervorheben';

  @override
  String get editorSection => '## Abschnitt';

  @override
  String get editorPause2s => 'Pause 2s';

  @override
  String get editorPauseManual => 'Manuelle Pause';

  @override
  String get editorCue => 'Cue';

  @override
  String get editorCueSnippet => '[CUE name] ';

  @override
  String editorStats(int words, int markers) {
    return '$words Wörter · $markers Markierungen';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return 'Dauer bei $wpm WPM: $duration';
  }

  @override
  String get editorTargetHint => 'Zieldauer';

  @override
  String get editorNoTarget => 'Kein Ziel';

  @override
  String editorMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get editorPausesExceedTarget => 'Die Pausen überschreiten das Ziel';

  @override
  String editorNeededWpm(int wpm) {
    return 'Benötigt: $wpm WPM';
  }

  @override
  String get prompterExit => 'Beenden (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fernbedienungen',
      one: '1 Fernbedienung',
      zero: 'keine Fernbedienung',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'Server gestoppt';

  @override
  String prompterServerPortError(int port, String message) {
    return 'Port $port konnte nicht geöffnet werden: $message';
  }

  @override
  String get prompterBack5 => '5 s zurück (Bild↑)';

  @override
  String get prompterForward5 => '5 s vor (Bild↓)';

  @override
  String get prompterPlay => 'Abspielen (Leertaste)';

  @override
  String get prompterPause => 'Pause (Leertaste)';

  @override
  String get prompterSlower => 'Langsamer (↓)';

  @override
  String get prompterFaster => 'Schneller (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · noch $remaining';
  }

  @override
  String get prompterVoiceOn => 'Meiner Stimme folgen';

  @override
  String get prompterVoiceOff => 'Sprachverfolgung ausschalten';

  @override
  String get prompterGoToSection => 'Zu Abschnitt springen';

  @override
  String get prompterSettings => 'Einstellungen (S)';

  @override
  String get statusPlaying => 'Läuft';

  @override
  String statusAutoPaused(String seconds) {
    return 'Pause $seconds s';
  }

  @override
  String get statusAutoPausedShort => 'Automatische Pause';

  @override
  String get statusHolding => 'Angehalten — Abspielen drücken';

  @override
  String get statusHoldingShort => 'Skriptpause';

  @override
  String get statusFinished => 'Ende';

  @override
  String get statusStopped => 'Gestoppt';

  @override
  String get settingsFontSize => 'Schriftgröße';

  @override
  String get settingsLineHeight => 'Zeilenabstand';

  @override
  String get settingsMargin => 'Seitenrand';

  @override
  String get settingsFocusLine => 'Fokuszeile';

  @override
  String get settingsSpeed => 'Geschwindigkeit';

  @override
  String get settingsTextColor => 'Textfarbe';

  @override
  String get settingsWhite => 'Weiß';

  @override
  String get settingsYellow => 'Gelb';

  @override
  String get settingsMirrorH => 'Horizontal spiegeln (H)';

  @override
  String get settingsMirrorV => 'Vertikal spiegeln (V)';

  @override
  String get settingsFocusGuide => 'Hilfslinie für Fokuszeile';

  @override
  String get voiceTitle => 'Sprachverfolgung';

  @override
  String get voiceLanguage => 'Sprache';

  @override
  String voiceStatusDownloading(int percent) {
    return 'Download $percent %';
  }

  @override
  String get voiceStatusInstalling => 'Modell wird installiert…';

  @override
  String get voiceStatusReady =>
      'Bereit: Tippe im HUD auf das Mikrofon, dann folgt der Text deiner Stimme';

  @override
  String get voiceStatusNoEngine =>
      'Modell installiert, aber die Vosk-Engine fehlt (unter Linux: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'Modell nicht installiert ($size MB, einmaliger Download)';
  }

  @override
  String voiceDownload(int size) {
    return 'Modell herunterladen ($size MB)';
  }

  @override
  String voiceDownloadPrompt(String language, int size) {
    return 'Die Sprachverfolgung braucht das Sprachmodell für $language ($size MB). Es wird einmal heruntergeladen und funktioniert danach offline. Die Sprache kannst du unter Einstellungen → Sprache ändern.';
  }

  @override
  String get voiceErrorNoModel =>
      'Lade das Sprachmodell unter Einstellungen → Sprache herunter';

  @override
  String get voiceErrorNoEngine =>
      'Vosk ist nicht installiert (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'Mikrofonzugriff verweigert. Erlaube ihn in den Systemeinstellungen, um die Sprachverfolgung zu nutzen.';

  @override
  String voiceErrorDownload(String message) {
    return 'Modell konnte nicht heruntergeladen werden: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'Fehler bei der Spracherkennung: $message';
  }

  @override
  String get remoteTitle => 'Fernbedienung';

  @override
  String get remoteConnectTitle => 'Mit Prompter verbinden';

  @override
  String get remoteReconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => 'Trennen';

  @override
  String get remotePinRequired =>
      'Gib die 4-stellige PIN ein, die der Prompter anzeigt';

  @override
  String get remoteBadPin => 'Falsche PIN';

  @override
  String remoteConnectFailed(String message) {
    return 'Verbindung fehlgeschlagen: $message';
  }

  @override
  String get remotePinLabel => 'Prompter-PIN';

  @override
  String get remoteOnLan => 'Im lokalen Netzwerk';

  @override
  String get remoteSearch => 'Suchen';

  @override
  String get remoteNoneFound =>
      'Kein Prompter gefunden. Öffne ihn auf dem Linux-Computer oder gib die IP manuell ein.';

  @override
  String get remoteManualIp => 'Manuelle IP (z. B. 192.168.1.20)';

  @override
  String get remoteConnect => 'Verbinden';

  @override
  String get remotePosition => 'Position im Skript';

  @override
  String remoteRemaining(String remaining) {
    return 'Noch $remaining';
  }

  @override
  String get remoteBack5 => '5 s zurück';

  @override
  String get remoteForward5 => '5 s vor';

  @override
  String get remotePlay => 'Abspielen';

  @override
  String get remotePause => 'Pause';

  @override
  String get remoteSlower => 'Langsamer';

  @override
  String get remoteFaster => 'Schneller';

  @override
  String get remoteMirrorH => 'Spiegeln H';

  @override
  String get remoteMirrorV => 'Spiegeln V';

  @override
  String get remoteFollowVoice => 'Stimme folgen';

  @override
  String get remoteStart => 'Anfang';

  @override
  String get remoteSections => 'Abschnitte und Cues';

  @override
  String get remoteChangeScript => 'Skript wechseln';

  @override
  String get aboutTitle => 'Über';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutTagline =>
      'Teleprompter für Linux und Android: flüssiges Scrollen, Fernsteuerung im lokalen Netzwerk und Sprachverfolgung ohne Internet.';

  @override
  String get aboutCreatedBy => 'Erstellt von';

  @override
  String get aboutFollow => 'Folgen';

  @override
  String get aboutProject => 'Projekt';

  @override
  String get aboutSourceCode => 'Quellcode';

  @override
  String get aboutContribute => 'Mitwirken';

  @override
  String get aboutLicense => 'MIT-Lizenz';

  @override
  String get aboutVoiceCredit => 'Offline-Spracherkennung: Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => 'Open-Source-Lizenzen';

  @override
  String aboutOpenFailed(String url) {
    return '$url konnte nicht geöffnet werden';
  }
}
