// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'Annulla';

  @override
  String commonError(String message) {
    return 'Errore: $message';
  }

  @override
  String get homeImport => 'Importa .txt / .md';

  @override
  String get homeRemote => 'Telecomando';

  @override
  String get homeNewScript => 'Nuovo copione';

  @override
  String homeEditScript(String title) {
    return 'Modifica $title';
  }

  @override
  String get homeSampleFileName => 'esempio.md';

  @override
  String get homeSampleScript =>
      '# Copione di esempio\n\n## Apertura\n[CAM 1] Ciao e **benvenuti** in PromptFlow. Questo copione di esempio mostra\ni marcatori disponibili. [PAUSE 2s]\n\nPuoi mettere le parole in **grassetto** per enfatizzarle, oppure ==evidenziarle==\nquando sono importanti.\n\n## Demo\n[CAM 2] [CUE Demo] Ora cambiamo telecamera. Le pause automatiche fermano il testo\nper qualche secondo e poi ripartono da sole. [PAUSE 1.5s]\n\nUna pausa senza durata ferma il testo finché non premi Riproduci. [PAUSE]\n\n## Chiusura\n[CAM 1] Grazie per la visione. Controlla il gobbo dal telefono con la\nmodalità **Telecomando**, oppure con un pedale Bluetooth.\n';

  @override
  String get editorNameHint => 'nome.md';

  @override
  String get editorSave => 'Salva (Ctrl+S)';

  @override
  String get editorRehearse => 'Prova nel gobbo';

  @override
  String editorSavedTo(String path) {
    return 'Salvato in $path';
  }

  @override
  String get editorUnsavedTitle => 'Modifiche non salvate';

  @override
  String get editorUnsavedBody => 'Uscire senza salvare?';

  @override
  String get editorLeave => 'Esci';

  @override
  String get editorBodyHint =>
      '# Titolo\n\n## Sezione\n[CAM 1] Testo del copione con **enfasi**. [PAUSE 2s]';

  @override
  String get editorBold => 'Grassetto';

  @override
  String get editorHighlight => 'Evidenzia';

  @override
  String get editorSection => '## Sezione';

  @override
  String get editorPause2s => 'Pausa 2s';

  @override
  String get editorPauseManual => 'Pausa manuale';

  @override
  String get editorCue => 'Cue';

  @override
  String get editorCueSnippet => '[CUE nome] ';

  @override
  String editorStats(int words, int markers) {
    return '$words parole · $markers marcatori';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return 'Durata a $wpm WPM: $duration';
  }

  @override
  String get editorTargetHint => 'Durata obiettivo';

  @override
  String get editorNoTarget => 'Nessun obiettivo';

  @override
  String editorMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get editorPausesExceedTarget => 'Le pause superano l\'obiettivo';

  @override
  String editorNeededWpm(int wpm) {
    return 'Servono $wpm WPM';
  }

  @override
  String get prompterExit => 'Esci (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count telecomandi',
      one: '1 telecomando',
      zero: 'nessun telecomando',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'Server arrestato';

  @override
  String prompterServerPortError(int port, String message) {
    return 'Impossibile aprire la porta $port: $message';
  }

  @override
  String get prompterBack5 => 'Indietro 5 s (Pag↑)';

  @override
  String get prompterForward5 => 'Avanti 5 s (Pag↓)';

  @override
  String get prompterPlay => 'Riproduci (Spazio)';

  @override
  String get prompterPause => 'Pausa (Spazio)';

  @override
  String get prompterSlower => 'Più lento (↓)';

  @override
  String get prompterFaster => 'Più veloce (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · mancano $remaining';
  }

  @override
  String get prompterVoiceOn => 'Segui la mia voce';

  @override
  String get prompterVoiceOff => 'Disattiva il controllo vocale';

  @override
  String get prompterGoToSection => 'Vai alla sezione';

  @override
  String get prompterSettings => 'Impostazioni (S)';

  @override
  String get statusPlaying => 'In riproduzione';

  @override
  String statusAutoPaused(String seconds) {
    return 'Pausa $seconds s';
  }

  @override
  String get statusAutoPausedShort => 'Pausa automatica';

  @override
  String get statusHolding => 'In pausa — premi Riproduci';

  @override
  String get statusHoldingShort => 'Pausa del copione';

  @override
  String get statusFinished => 'Fine';

  @override
  String get statusStopped => 'Fermo';

  @override
  String get settingsFontSize => 'Dimensione carattere';

  @override
  String get settingsLineHeight => 'Interlinea';

  @override
  String get settingsMargin => 'Margine laterale';

  @override
  String get settingsFocusLine => 'Linea di lettura';

  @override
  String get settingsSpeed => 'Velocità';

  @override
  String get settingsTextColor => 'Colore del testo';

  @override
  String get settingsWhite => 'Bianco';

  @override
  String get settingsYellow => 'Giallo';

  @override
  String get settingsMirrorH => 'Specchio orizzontale (H)';

  @override
  String get settingsMirrorV => 'Specchio verticale (V)';

  @override
  String get settingsFocusGuide => 'Guida della linea di lettura';

  @override
  String get voiceTitle => 'Inseguimento vocale';

  @override
  String get voiceLanguage => 'Lingua della voce';

  @override
  String voiceStatusDownloading(int percent) {
    return 'Download $percent %';
  }

  @override
  String get voiceStatusInstalling => 'Installazione del modello…';

  @override
  String get voiceStatusReady =>
      'Pronto: tocca il microfono dell\'HUD e il testo seguirà la tua voce';

  @override
  String get voiceStatusNoEngine =>
      'Modello installato, ma manca il motore Vosk (su Linux: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'Modello non installato ($size MB, scaricato una sola volta)';
  }

  @override
  String voiceDownload(int size) {
    return 'Scarica modello ($size MB)';
  }

  @override
  String get voiceErrorNoModel =>
      'Scarica il modello vocale in Impostazioni → Voce';

  @override
  String get voiceErrorNoEngine =>
      'Vosk non è installato (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'Autorizzazione al microfono negata. Consentila nelle impostazioni di sistema per usare il controllo vocale.';

  @override
  String voiceErrorDownload(String message) {
    return 'Impossibile scaricare il modello: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'Errore di riconoscimento vocale: $message';
  }

  @override
  String get remoteTitle => 'Telecomando';

  @override
  String get remoteConnectTitle => 'Connetti a un gobbo';

  @override
  String get remoteReconnecting => 'Riconnessione…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => 'Disconnetti';

  @override
  String get remotePinRequired =>
      'Inserisci il PIN a 4 cifre mostrato sul gobbo';

  @override
  String get remoteBadPin => 'PIN errato';

  @override
  String remoteConnectFailed(String message) {
    return 'Impossibile connettersi: $message';
  }

  @override
  String get remotePinLabel => 'PIN del gobbo';

  @override
  String get remoteOnLan => 'Sulla rete locale';

  @override
  String get remoteSearch => 'Cerca';

  @override
  String get remoteNoneFound =>
      'Nessun gobbo trovato. Aprilo sul computer Linux o usa l\'IP manuale.';

  @override
  String get remoteManualIp => 'IP manuale (es. 192.168.1.20)';

  @override
  String get remoteConnect => 'Connetti';

  @override
  String get remotePosition => 'Posizione nel copione';

  @override
  String remoteRemaining(String remaining) {
    return 'Mancano $remaining';
  }

  @override
  String get remoteBack5 => 'Indietro 5 s';

  @override
  String get remoteForward5 => 'Avanti 5 s';

  @override
  String get remotePlay => 'Riproduci';

  @override
  String get remotePause => 'Pausa';

  @override
  String get remoteSlower => 'Più lento';

  @override
  String get remoteFaster => 'Più veloce';

  @override
  String get remoteMirrorH => 'Specchio H';

  @override
  String get remoteMirrorV => 'Specchio V';

  @override
  String get remoteFollowVoice => 'Segui la voce';

  @override
  String get remoteStart => 'Inizio';

  @override
  String get remoteSections => 'Sezioni e cue';

  @override
  String get remoteChangeScript => 'Cambia copione';
}
