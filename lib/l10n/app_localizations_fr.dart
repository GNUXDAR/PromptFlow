// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'Annuler';

  @override
  String commonError(String message) {
    return 'Erreur : $message';
  }

  @override
  String get homeImport => 'Importer .txt / .md';

  @override
  String get homeRemote => 'Télécommande';

  @override
  String get homeNewScript => 'Nouveau script';

  @override
  String homeEditScript(String title) {
    return 'Modifier $title';
  }

  @override
  String get homeSampleFileName => 'exemple.md';

  @override
  String get homeSampleScript =>
      '# Script d\'exemple\n\n## Ouverture\n[CAM 1] Bonjour et **bienvenue** dans PromptFlow. Ce script d\'exemple présente\nles repères disponibles. [PAUSE 2s]\n\nVous pouvez mettre des mots en **gras** pour les accentuer, ou les ==surligner==\nquand ils sont importants.\n\n## Démonstration\n[CAM 2] [CUE Demo] Changeons maintenant de caméra. Les pauses automatiques arrêtent le texte\nquelques secondes, puis il reprend tout seul. [PAUSE 1.5s]\n\nUne pause sans durée arrête le texte jusqu\'à ce que vous appuyiez sur Lecture. [PAUSE]\n\n## Conclusion\n[CAM 1] Merci de votre attention. Pilotez le prompteur depuis votre téléphone avec\nle mode **Télécommande**, ou avec une pédale Bluetooth.\n';

  @override
  String get editorNameHint => 'nom.md';

  @override
  String get editorSave => 'Enregistrer (Ctrl+S)';

  @override
  String get editorRehearse => 'Répéter dans le prompteur';

  @override
  String editorSavedTo(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String get editorUnsavedTitle => 'Modifications non enregistrées';

  @override
  String get editorUnsavedBody => 'Quitter sans enregistrer ?';

  @override
  String get editorLeave => 'Quitter';

  @override
  String get editorBodyHint =>
      '# Titre\n\n## Section\n[CAM 1] Texte du script avec **accentuation**. [PAUSE 2s]';

  @override
  String get editorBold => 'Gras';

  @override
  String get editorHighlight => 'Surligner';

  @override
  String get editorSection => '## Section';

  @override
  String get editorPause2s => 'Pause 2s';

  @override
  String get editorPauseManual => 'Pause manuelle';

  @override
  String get editorCue => 'Cue';

  @override
  String get editorCueSnippet => '[CUE nom] ';

  @override
  String editorStats(int words, int markers) {
    return '$words mots · $markers repères';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return 'Durée à $wpm WPM : $duration';
  }

  @override
  String get editorTargetHint => 'Durée cible';

  @override
  String get editorNoTarget => 'Aucune cible';

  @override
  String editorMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get editorPausesExceedTarget => 'Les pauses dépassent la cible';

  @override
  String editorNeededWpm(int wpm) {
    return 'Il vous faut $wpm WPM';
  }

  @override
  String get prompterExit => 'Quitter (Échap)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count télécommandes',
      one: '1 télécommande',
      zero: 'aucune télécommande',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'Serveur arrêté';

  @override
  String prompterServerPortError(int port, String message) {
    return 'Impossible d\'ouvrir le port $port : $message';
  }

  @override
  String get prompterBack5 => 'Reculer de 5 s (Pg préc)';

  @override
  String get prompterForward5 => 'Avancer de 5 s (Pg suiv)';

  @override
  String get prompterPlay => 'Lecture (Espace)';

  @override
  String get prompterPause => 'Pause (Espace)';

  @override
  String get prompterSlower => 'Plus lent (↓)';

  @override
  String get prompterFaster => 'Plus rapide (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · $remaining restantes';
  }

  @override
  String get prompterVoiceOn => 'Suivre ma voix';

  @override
  String get prompterVoiceOff => 'Désactiver le suivi vocal';

  @override
  String get prompterGoToSection => 'Aller à la section';

  @override
  String get prompterSettings => 'Paramètres (S)';

  @override
  String get statusPlaying => 'Lecture';

  @override
  String statusAutoPaused(String seconds) {
    return 'Pause $seconds s';
  }

  @override
  String get statusAutoPausedShort => 'Pause automatique';

  @override
  String get statusHolding => 'En pause — appuyez sur Lecture';

  @override
  String get statusHoldingShort => 'Pause du script';

  @override
  String get statusFinished => 'Fin';

  @override
  String get statusStopped => 'Arrêté';

  @override
  String get settingsFontSize => 'Taille du texte';

  @override
  String get settingsLineHeight => 'Interligne';

  @override
  String get settingsMargin => 'Marge latérale';

  @override
  String get settingsFocusLine => 'Ligne de lecture';

  @override
  String get settingsSpeed => 'Vitesse';

  @override
  String get settingsTextColor => 'Couleur du texte';

  @override
  String get settingsWhite => 'Blanc';

  @override
  String get settingsYellow => 'Jaune';

  @override
  String get settingsMirrorH => 'Miroir horizontal (H)';

  @override
  String get settingsMirrorV => 'Miroir vertical (V)';

  @override
  String get settingsFocusGuide => 'Repère de la ligne de lecture';

  @override
  String get voiceTitle => 'Suivi vocal';

  @override
  String get voiceLanguage => 'Langue de la voix';

  @override
  String voiceStatusDownloading(int percent) {
    return 'Téléchargement $percent %';
  }

  @override
  String get voiceStatusInstalling => 'Installation du modèle…';

  @override
  String get voiceStatusReady =>
      'Prêt : appuyez sur le micro du HUD et le texte suivra votre voix';

  @override
  String get voiceStatusNoEngine =>
      'Modèle installé, mais le moteur Vosk est absent (sous Linux : tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'Modèle non installé ($size Mo, téléchargé une seule fois)';
  }

  @override
  String voiceDownload(int size) {
    return 'Télécharger le modèle ($size Mo)';
  }

  @override
  String voiceDownloadPrompt(String language, int size) {
    return 'Le suivi vocal a besoin du modèle vocal $language ($size Mo). Il est téléchargé une seule fois, puis fonctionne hors ligne. Vous pouvez changer la langue dans Paramètres → Voix.';
  }

  @override
  String get voiceErrorNoModel =>
      'Téléchargez le modèle vocal dans Paramètres → Voix';

  @override
  String get voiceErrorNoEngine =>
      'Vosk n\'est pas installé (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'Accès au micro refusé. Autorisez-le dans les paramètres du système pour utiliser le suivi vocal.';

  @override
  String voiceErrorDownload(String message) {
    return 'Impossible de télécharger le modèle : $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'Erreur de reconnaissance vocale : $message';
  }

  @override
  String get remoteTitle => 'Télécommande';

  @override
  String get remoteConnectTitle => 'Se connecter à un prompteur';

  @override
  String get remoteReconnecting => 'Reconnexion…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => 'Se déconnecter';

  @override
  String get remotePinRequired =>
      'Saisissez le PIN à 4 chiffres affiché sur le prompteur';

  @override
  String get remoteBadPin => 'PIN incorrect';

  @override
  String remoteConnectFailed(String message) {
    return 'Connexion impossible : $message';
  }

  @override
  String get remotePinLabel => 'PIN du prompteur';

  @override
  String get remoteOnLan => 'Sur le réseau local';

  @override
  String get remoteSearch => 'Rechercher';

  @override
  String get remoteNoneFound =>
      'Aucun prompteur trouvé. Ouvrez-le sur l\'ordinateur Linux ou saisissez l\'IP manuellement.';

  @override
  String get remoteManualIp => 'IP manuelle (ex. 192.168.1.20)';

  @override
  String get remoteConnect => 'Se connecter';

  @override
  String get remotePosition => 'Position dans le script';

  @override
  String remoteRemaining(String remaining) {
    return '$remaining restantes';
  }

  @override
  String get remoteBack5 => 'Reculer de 5 s';

  @override
  String get remoteForward5 => 'Avancer de 5 s';

  @override
  String get remotePlay => 'Lecture';

  @override
  String get remotePause => 'Pause';

  @override
  String get remoteSlower => 'Plus lent';

  @override
  String get remoteFaster => 'Plus rapide';

  @override
  String get remoteMirrorH => 'Miroir H';

  @override
  String get remoteMirrorV => 'Miroir V';

  @override
  String get remoteFollowVoice => 'Suivre la voix';

  @override
  String get remoteStart => 'Début';

  @override
  String get remoteSections => 'Sections et cues';

  @override
  String get remoteChangeScript => 'Changer de script';

  @override
  String get aboutTitle => 'À propos';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutTagline =>
      'Prompteur pour Linux et Android : défilement fluide, télécommande sur le réseau local et suivi vocal hors ligne.';

  @override
  String get aboutCreatedBy => 'Créé par';

  @override
  String get aboutFollow => 'Suivre';

  @override
  String get aboutProject => 'Projet';

  @override
  String get aboutSourceCode => 'Code source';

  @override
  String get aboutContribute => 'Contribuer';

  @override
  String get aboutLicense => 'Licence MIT';

  @override
  String get aboutVoiceCredit =>
      'Reconnaissance vocale hors ligne : Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String aboutOpenFailed(String url) {
    return 'Impossible d\'ouvrir $url';
  }
}
