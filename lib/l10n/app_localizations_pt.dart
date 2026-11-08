// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String commonError(String message) {
    return 'Erro: $message';
  }

  @override
  String get homeImport => 'Importar .txt / .md';

  @override
  String get homeRemote => 'Controle remoto';

  @override
  String get homeNewScript => 'Novo roteiro';

  @override
  String homeEditScript(String title) {
    return 'Editar $title';
  }

  @override
  String get homeSampleFileName => 'exemplo.md';

  @override
  String get homeSampleScript =>
      '# Roteiro de exemplo\n\n## Abertura\n[CAM 1] Olá e **bem-vindo** ao PromptFlow. Este roteiro de exemplo mostra\nos marcadores disponíveis. [PAUSE 2s]\n\nVocê pode colocar palavras em **negrito** para dar ênfase, ou ==destacá-las==\nquando forem importantes.\n\n## Demonstração\n[CAM 2] [CUE Demo] Agora trocamos de câmera. As pausas automáticas param o texto\npor alguns segundos e depois ele continua sozinho. [PAUSE 1.5s]\n\nUma pausa sem duração para o texto até você pressionar Reproduzir. [PAUSE]\n\n## Encerramento\n[CAM 1] Obrigado por assistir. Controle o teleprompter pelo celular com\no modo **Controle remoto**, ou com um pedal Bluetooth.\n';

  @override
  String get editorNameHint => 'nome.md';

  @override
  String get editorSave => 'Salvar (Ctrl+S)';

  @override
  String get editorRehearse => 'Ensaiar no teleprompter';

  @override
  String editorSavedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String get editorUnsavedTitle => 'Alterações não salvas';

  @override
  String get editorUnsavedBody => 'Sair sem salvar?';

  @override
  String get editorLeave => 'Sair';

  @override
  String get editorBodyHint =>
      '# Título\n\n## Seção\n[CAM 1] Texto do roteiro com **ênfase**. [PAUSE 2s]';

  @override
  String get editorBold => 'Negrito';

  @override
  String get editorHighlight => 'Destacar';

  @override
  String get editorSection => '## Seção';

  @override
  String get editorPause2s => 'Pausa 2s';

  @override
  String get editorPauseManual => 'Pausa manual';

  @override
  String get editorCue => 'Cue';

  @override
  String get editorCueSnippet => '[CUE nome] ';

  @override
  String editorStats(int words, int markers) {
    return '$words palavras · $markers marcadores';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return 'Duração a $wpm WPM: $duration';
  }

  @override
  String get editorTargetHint => 'Duração desejada';

  @override
  String get editorNoTarget => 'Sem meta';

  @override
  String editorMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get editorPausesExceedTarget => 'As pausas excedem a meta';

  @override
  String editorNeededWpm(int wpm) {
    return 'Você precisa de $wpm WPM';
  }

  @override
  String get prompterExit => 'Sair (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count controles',
      one: '1 controle',
      zero: 'nenhum controle',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'Servidor parado';

  @override
  String prompterServerPortError(int port, String message) {
    return 'Não foi possível abrir a porta $port: $message';
  }

  @override
  String get prompterBack5 => 'Voltar 5 s (Page Up)';

  @override
  String get prompterForward5 => 'Avançar 5 s (Page Down)';

  @override
  String get prompterPlay => 'Reproduzir (Espaço)';

  @override
  String get prompterPause => 'Pausar (Espaço)';

  @override
  String get prompterSlower => 'Mais lento (↓)';

  @override
  String get prompterFaster => 'Mais rápido (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · faltam $remaining';
  }

  @override
  String get prompterVoiceOn => 'Seguir minha voz';

  @override
  String get prompterVoiceOff => 'Desativar acompanhamento de voz';

  @override
  String get prompterGoToSection => 'Ir para a seção';

  @override
  String get prompterSettings => 'Configurações (S)';

  @override
  String get statusPlaying => 'Reproduzindo';

  @override
  String statusAutoPaused(String seconds) {
    return 'Pausa $seconds s';
  }

  @override
  String get statusAutoPausedShort => 'Pausa automática';

  @override
  String get statusHolding => 'Pausado — pressione Reproduzir';

  @override
  String get statusHoldingShort => 'Pausa do roteiro';

  @override
  String get statusFinished => 'Fim';

  @override
  String get statusStopped => 'Parado';

  @override
  String get settingsFontSize => 'Tamanho da fonte';

  @override
  String get settingsLineHeight => 'Espaçamento entre linhas';

  @override
  String get settingsMargin => 'Margem lateral';

  @override
  String get settingsFocusLine => 'Linha de foco';

  @override
  String get settingsSpeed => 'Velocidade';

  @override
  String get settingsTextColor => 'Cor do texto';

  @override
  String get settingsWhite => 'Branco';

  @override
  String get settingsYellow => 'Amarelo';

  @override
  String get settingsMirrorH => 'Espelho horizontal (H)';

  @override
  String get settingsMirrorV => 'Espelho vertical (V)';

  @override
  String get settingsFocusGuide => 'Guia da linha de foco';

  @override
  String get voiceTitle => 'Acompanhamento de voz';

  @override
  String get voiceLanguage => 'Idioma da voz';

  @override
  String voiceStatusDownloading(int percent) {
    return 'Baixando $percent %';
  }

  @override
  String get voiceStatusInstalling => 'Instalando modelo…';

  @override
  String get voiceStatusReady =>
      'Pronto: toque no microfone do HUD e o texto seguirá sua voz';

  @override
  String get voiceStatusNoEngine =>
      'Modelo instalado, mas falta o mecanismo Vosk (no Linux: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'Modelo não instalado ($size MB, baixado só uma vez)';
  }

  @override
  String voiceDownload(int size) {
    return 'Baixar modelo ($size MB)';
  }

  @override
  String voiceDownloadPrompt(String language, int size) {
    return 'O acompanhamento de voz precisa do modelo de voz em $language ($size MB). Ele é baixado uma única vez e depois funciona offline. Você pode mudar o idioma em Configurações → Voz.';
  }

  @override
  String get voiceErrorNoModel =>
      'Baixe o modelo de voz em Configurações → Voz';

  @override
  String get voiceErrorNoEngine =>
      'O Vosk não está instalado (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'Permissão de microfone negada. Ative-a nas configurações do sistema para usar o acompanhamento de voz.';

  @override
  String voiceErrorDownload(String message) {
    return 'Não foi possível baixar o modelo: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'Erro no reconhecimento de voz: $message';
  }

  @override
  String get remoteTitle => 'Controle remoto';

  @override
  String get remoteConnectTitle => 'Conectar a um teleprompter';

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
      'Digite o PIN de 4 dígitos exibido no teleprompter';

  @override
  String get remoteBadPin => 'PIN incorreto';

  @override
  String remoteConnectFailed(String message) {
    return 'Não foi possível conectar: $message';
  }

  @override
  String get remotePinLabel => 'PIN do teleprompter';

  @override
  String get remoteOnLan => 'Na rede local';

  @override
  String get remoteSearch => 'Buscar';

  @override
  String get remoteNoneFound =>
      'Nenhum teleprompter encontrado. Abra-o no computador Linux ou use o IP manual.';

  @override
  String get remoteManualIp => 'IP manual (ex.: 192.168.1.20)';

  @override
  String get remoteConnect => 'Conectar';

  @override
  String get remotePosition => 'Posição no roteiro';

  @override
  String remoteRemaining(String remaining) {
    return 'Faltam $remaining';
  }

  @override
  String get remoteBack5 => 'Voltar 5 s';

  @override
  String get remoteForward5 => 'Avançar 5 s';

  @override
  String get remotePlay => 'Reproduzir';

  @override
  String get remotePause => 'Pausar';

  @override
  String get remoteSlower => 'Mais lento';

  @override
  String get remoteFaster => 'Mais rápido';

  @override
  String get remoteMirrorH => 'Espelho H';

  @override
  String get remoteMirrorV => 'Espelho V';

  @override
  String get remoteFollowVoice => 'Seguir voz';

  @override
  String get remoteStart => 'Início';

  @override
  String get remoteSections => 'Seções e cues';

  @override
  String get remoteChangeScript => 'Trocar roteiro';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutTagline =>
      'Teleprompter para Linux e Android: rolagem suave, controle remoto pela rede local e acompanhamento de voz offline.';

  @override
  String get aboutCreatedBy => 'Criado por';

  @override
  String get aboutFollow => 'Siga';

  @override
  String get aboutProject => 'Projeto';

  @override
  String get aboutSourceCode => 'Código-fonte';

  @override
  String get aboutContribute => 'Contribuir';

  @override
  String get aboutLicense => 'Licença MIT';

  @override
  String get aboutVoiceCredit =>
      'Reconhecimento de voz offline: Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => 'Licenças de código aberto';

  @override
  String aboutOpenFailed(String url) {
    return 'Não foi possível abrir $url';
  }
}
