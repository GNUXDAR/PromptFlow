// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }

  @override
  String get homeImport => 'Importar .txt / .md';

  @override
  String get homeRemote => 'Control remoto';

  @override
  String get homeNewScript => 'Nuevo guion';

  @override
  String homeEditScript(String title) {
    return 'Editar $title';
  }

  @override
  String get homeSampleFileName => 'ejemplo.md';

  @override
  String get homeSampleScript =>
      '# Guion de ejemplo\n\n## Apertura\n[CAM 1] Hola y **bienvenidos** a PromptFlow. Este es un guion de ejemplo\nque muestra las marcas disponibles. [PAUSE 2s]\n\nPuedes poner palabras en **negrita** para enfatizar, o ==resaltarlas==\ncuando sean importantes.\n\n## Demostración\n[CAM 2] [CUE Demo] Ahora cambiamos de cámara. Las pausas automáticas detienen\nel texto unos segundos y continúan solas. [PAUSE 1.5s]\n\nUna pausa sin duración detiene el texto hasta que pulses Play. [PAUSE]\n\n## Cierre\n[CAM 1] Gracias por ver. Controla el prompter desde tu teléfono con el\nmodo **Control remoto**, o con un pedal Bluetooth.\n';

  @override
  String get editorNameHint => 'nombre.md';

  @override
  String get editorSave => 'Guardar (Ctrl+S)';

  @override
  String get editorRehearse => 'Ensayar en el prompter';

  @override
  String editorSavedTo(String path) {
    return 'Guardado en $path';
  }

  @override
  String get editorUnsavedTitle => 'Cambios sin guardar';

  @override
  String get editorUnsavedBody => '¿Salir sin guardar?';

  @override
  String get editorLeave => 'Salir';

  @override
  String get editorBodyHint =>
      '# Título\n\n## Sección\n[CAM 1] Texto del guion con **énfasis**. [PAUSE 2s]';

  @override
  String get editorBold => 'Negrita';

  @override
  String get editorHighlight => 'Resaltar';

  @override
  String get editorSection => '## Sección';

  @override
  String get editorPause2s => 'Pausa 2s';

  @override
  String get editorPauseManual => 'Pausa manual';

  @override
  String get editorCue => 'Cue';

  @override
  String get editorCueSnippet => '[CUE nombre] ';

  @override
  String editorStats(int words, int markers) {
    return '$words palabras · $markers marcas';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return 'Duración a $wpm WPM: $duration';
  }

  @override
  String get editorTargetHint => 'Duración objetivo';

  @override
  String get editorNoTarget => 'Sin objetivo';

  @override
  String editorMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get editorPausesExceedTarget => 'Las pausas superan el objetivo';

  @override
  String editorNeededWpm(int wpm) {
    return 'Necesitas $wpm WPM';
  }

  @override
  String get prompterExit => 'Salir (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mandos',
      one: '1 mando',
      zero: 'sin mandos',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'Servidor detenido';

  @override
  String prompterServerPortError(int port, String message) {
    return 'No se pudo abrir el puerto $port: $message';
  }

  @override
  String get prompterBack5 => 'Atrás 5 s (Re Pág)';

  @override
  String get prompterForward5 => 'Adelante 5 s (Av Pág)';

  @override
  String get prompterPlay => 'Reproducir (Espacio)';

  @override
  String get prompterPause => 'Pausa (Espacio)';

  @override
  String get prompterSlower => 'Más lento (↓)';

  @override
  String get prompterFaster => 'Más rápido (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · quedan $remaining';
  }

  @override
  String get prompterVoiceOn => 'Seguir mi voz';

  @override
  String get prompterVoiceOff => 'Desactivar seguimiento por voz';

  @override
  String get prompterGoToSection => 'Ir a sección';

  @override
  String get prompterSettings => 'Ajustes (S)';

  @override
  String get statusPlaying => 'Reproduciendo';

  @override
  String statusAutoPaused(String seconds) {
    return 'Pausa $seconds s';
  }

  @override
  String get statusAutoPausedShort => 'Pausa automática';

  @override
  String get statusHolding => 'Pausa — pulsa Play';

  @override
  String get statusHoldingShort => 'Pausa del guion';

  @override
  String get statusFinished => 'Fin';

  @override
  String get statusStopped => 'Detenido';

  @override
  String get settingsFontSize => 'Tamaño de letra';

  @override
  String get settingsLineHeight => 'Interlineado';

  @override
  String get settingsMargin => 'Margen lateral';

  @override
  String get settingsFocusLine => 'Línea de enfoque';

  @override
  String get settingsSpeed => 'Velocidad';

  @override
  String get settingsTextColor => 'Color del texto';

  @override
  String get settingsWhite => 'Blanco';

  @override
  String get settingsYellow => 'Amarillo';

  @override
  String get settingsMirrorH => 'Espejo horizontal (H)';

  @override
  String get settingsMirrorV => 'Espejo vertical (V)';

  @override
  String get settingsFocusGuide => 'Guía de la línea de enfoque';

  @override
  String get voiceTitle => 'Seguimiento por voz';

  @override
  String get voiceLanguage => 'Idioma de la voz';

  @override
  String voiceStatusDownloading(int percent) {
    return 'Descargando $percent %';
  }

  @override
  String get voiceStatusInstalling => 'Instalando modelo…';

  @override
  String get voiceStatusReady =>
      'Listo: pulsa el micrófono del HUD para que el texto siga tu voz';

  @override
  String get voiceStatusNoEngine =>
      'Modelo instalado, pero falta el motor Vosk (en Linux: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'Modelo no instalado ($size MB, se descarga una sola vez)';
  }

  @override
  String voiceDownload(int size) {
    return 'Descargar modelo ($size MB)';
  }

  @override
  String get voiceErrorNoModel => 'Descarga el modelo de voz en Ajustes → Voz';

  @override
  String get voiceErrorNoEngine =>
      'Vosk no está instalado (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'Permiso de micrófono denegado. Actívalo en los ajustes del sistema para usar el seguimiento por voz.';

  @override
  String voiceErrorDownload(String message) {
    return 'No se pudo descargar el modelo: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'Error del reconocimiento de voz: $message';
  }

  @override
  String get remoteTitle => 'Control remoto';

  @override
  String get remoteConnectTitle => 'Conectar a un prompter';

  @override
  String get remoteReconnecting => 'Reconectando…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => 'Desconectar';

  @override
  String get remotePinRequired =>
      'Introduce el PIN de 4 dígitos que muestra el prompter';

  @override
  String get remoteBadPin => 'PIN incorrecto';

  @override
  String remoteConnectFailed(String message) {
    return 'No se pudo conectar: $message';
  }

  @override
  String get remotePinLabel => 'PIN del prompter';

  @override
  String get remoteOnLan => 'En la red local';

  @override
  String get remoteSearch => 'Buscar';

  @override
  String get remoteNoneFound =>
      'No se encontró ningún prompter. Ábrelo en el equipo Linux o usa la IP manual.';

  @override
  String get remoteManualIp => 'IP manual (ej. 192.168.1.20)';

  @override
  String get remoteConnect => 'Conectar';

  @override
  String get remotePosition => 'Posición en el guion';

  @override
  String remoteRemaining(String remaining) {
    return 'Quedan $remaining';
  }

  @override
  String get remoteBack5 => 'Atrás 5 s';

  @override
  String get remoteForward5 => 'Adelante 5 s';

  @override
  String get remotePlay => 'Play';

  @override
  String get remotePause => 'Pausa';

  @override
  String get remoteSlower => 'Más lento';

  @override
  String get remoteFaster => 'Más rápido';

  @override
  String get remoteMirrorH => 'Espejo H';

  @override
  String get remoteMirrorV => 'Espejo V';

  @override
  String get remoteFollowVoice => 'Seguir voz';

  @override
  String get remoteStart => 'Inicio';

  @override
  String get remoteSections => 'Secciones y cues';

  @override
  String get remoteChangeScript => 'Cambiar de guion';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutTagline =>
      'Teleprompter para Linux y Android: scroll suave, control remoto por la red local y seguimiento por voz sin conexión.';

  @override
  String get aboutCreatedBy => 'Creado por';

  @override
  String get aboutFollow => 'Sígueme';

  @override
  String get aboutProject => 'Proyecto';

  @override
  String get aboutSourceCode => 'Código fuente';

  @override
  String get aboutContribute => 'Contribuir';

  @override
  String get aboutLicense => 'Licencia MIT';

  @override
  String get aboutVoiceCredit =>
      'Reconocimiento de voz sin conexión: Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String aboutOpenFailed(String url) {
    return 'No se pudo abrir $url';
  }
}
