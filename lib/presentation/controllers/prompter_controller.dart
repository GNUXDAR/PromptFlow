import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../data/repositories/script_repository.dart';
import '../../domain/entities/prompter_settings.dart';
import '../../domain/entities/script.dart';
import '../../engine/script_layout.dart';
import '../../engine/scroll_engine.dart';
import '../../remote/protocol/messages.dart';
import '../../remote/server/remote_server.dart';
import '../../voice/speech_recognizer.dart';
import '../../voice/voice_aligner.dart';

/// ViewModel del prompter. Punto único de entrada de comandos: teclado,
/// pedal, gestos, mando remoto y voz llaman a [execute].
class PrompterController extends ChangeNotifier implements RemoteHost {
  PrompterController({
    required TickerProvider vsync,
    required this.repository,
    required Script script,
    PrompterSettings settings = const PrompterSettings(),
    SpeechRecognizer? recognizer,
  })  : _script = script, // ignore: prefer_initializing_formals
        _settings = settings,
        _recognizer = recognizer ?? VoskSpeechRecognizer() {
    engine = ScrollEngine(vsync: vsync)..setWpm(settings.wpm);
    server = RemoteServer(host: this, name: Platform.localHostname);
    _refreshScripts();
  }

  final ScriptRepository repository;
  late final ScrollEngine engine;
  late final RemoteServer server;
  final SpeechRecognizer _recognizer;

  Script _script;
  PrompterSettings _settings;
  List<ScriptSummary> _scripts = const [];
  Size? _layoutSize;
  TextScaler? _layoutScaler;
  PrompterSettings? _layoutSettings;

  VoiceAligner? _aligner;
  StreamSubscription<RecognizedSpeech>? _voiceSub;
  bool _voiceActive = false;
  bool? _voiceAvailable;
  String? serverError;
  int _settingsRev = 0; // se suma a engine.revision en el snapshot

  Script get script => _script;
  PrompterSettings get settings => _settings;
  bool get voiceActive => _voiceActive;
  bool get voiceAvailable => _voiceAvailable ?? false;

  Future<void> startServer() async {
    try {
      await server.start();
      serverError = null;
    } on SocketException catch (e) {
      serverError = 'No se pudo abrir el puerto ${PfProtocol.defaultWsPort}: ${e.osError?.message ?? e.message}';
    }
    _voiceAvailable = await _recognizer.isAvailable;
    notifyListeners();
  }

  /// Llamado desde el `LayoutBuilder`. Re-maqueta solo si cambian el tamaño,
  /// la escala de texto o un ajuste que afecte a la maquetación.
  void ensureLayout(Size size, TextScaler scaler) {
    final s = _layoutSettings;
    if (size == _layoutSize && scaler == _layoutScaler && s != null && !s.affectsLayout(_settings) &&
        engine.layout != null) {
      return;
    }
    _layoutSize = size;
    _layoutScaler = scaler;
    _layoutSettings = _settings;
    engine.setLayout(
      ScriptLayout.build(_script, _settings, size.width, textScaler: scaler),
      notify: false,
    );
  }

  void updateSettings(PrompterSettings Function(PrompterSettings) update) {
    _settings = update(_settings);
    _settingsRev++;
    engine.setWpm(_settings.wpm);
    notifyListeners();
  }

  Future<void> loadScript(Script script) async {
    engine.pause();
    _script = script;
    _layoutSettings = null; // fuerza re-maquetación
    if (_layoutSize != null) {
      engine.setLayout(
        ScriptLayout.build(script, _settings, _layoutSize!.width, textScaler: _layoutScaler!),
        keepPosition: false,
      );
      _layoutSettings = _settings;
    }
    if (_voiceActive) _aligner = VoiceAligner(script.readableWords);
    await _refreshScripts();
    server.publishCatalog();
    notifyListeners();
  }

  @override
  void execute(PrompterCommand c) {
    switch (c) {
      case PlayCommand():
        engine.play();
      case PauseCommand():
        engine.pause();
      case ToggleCommand():
        engine.toggle();
      case SeekCommand(:final seconds):
        engine.seekSeconds(seconds);
        _aligner?.reset(engine.wordPosition.round());
      case SetSpeedCommand(:final wpm):
        updateSettings((s) => s.copyWith(wpm: wpm));
      case NudgeSpeedCommand(:final delta):
        updateSettings((s) => s.copyWith(wpm: s.wpm + delta));
      case JumpCommand(:final target):
        engine.jumpToMarker(target);
        _aligner?.reset(engine.layout?.wordAt(engine.layout?.offsetForMarker(target) ?? 0).round() ?? 0);
      case GotoWordCommand(:final word):
        final l = engine.layout;
        if (l != null) engine.seekToOffset(l.offsetForWord(word));
        _aligner?.reset(word.round());
      case MirrorCommand(:final horizontal, :final vertical):
        updateSettings((s) => s.copyWith(mirrorHorizontal: horizontal, mirrorVertical: vertical));
      case ToggleMirrorCommand(:final axis):
        updateSettings((s) => axis == MirrorAxis.horizontal
            ? s.copyWith(mirrorHorizontal: !s.mirrorHorizontal)
            : s.copyWith(mirrorVertical: !s.mirrorVertical));
      case FontNudgeCommand(:final delta):
        updateSettings((s) => s.copyWith(fontSize: s.fontSize + delta));
      case LoadScriptCommand(:final scriptId):
        repository.loadById(scriptId).then((s) {
          if (s != null) loadScript(s);
        });
      case VoiceSyncCommand(:final enabled):
        setVoiceSync(enabled);
    }
  }

  // ───────────────────────── Voz (Módulo D) ─────────────────────────

  Future<void> setVoiceSync(bool enabled) async {
    if (enabled == _voiceActive) return;
    if (enabled) {
      if (!await _recognizer.isAvailable) return;
      final dir = await repository.root;
      _aligner = VoiceAligner(_script.readableWords)..reset(engine.wordPosition.round());
      _voiceSub = _recognizer.results.listen((r) {
        final idx = _aligner?.feed(r.text);
        if (idx != null) engine.followWord(idx.toDouble());
      });
      await _recognizer.start(modelPath: '${dir.path}/models/vosk-es');
      engine.setMode(ScrollMode.voiceFollow);
    } else {
      await _voiceSub?.cancel();
      _voiceSub = null;
      await _recognizer.stop();
      engine.setMode(ScrollMode.timed);
      _aligner = null;
    }
    _voiceActive = enabled;
    notifyListeners();
  }

  // ───────────────────────── RemoteHost ─────────────────────────

  String? get currentSectionId {
    final l = engine.layout;
    if (l == null) return null;
    String? id;
    for (final m in l.markers) {
      if (m.y > engine.offset + 1) break;
      if (m.kind != MarkerKind.pause) id = m.id;
    }
    return id;
  }

  @override
  PrompterSnapshot snapshot() => PrompterSnapshot(
        rev: engine.revision + _settingsRev,
        status: engine.status.name,
        word: engine.wordPosition,
        wordCount: engine.layout?.wordCount ?? _script.wordCount,
        wpm: engine.wpm,
        remainingMs: engine.remaining.inMilliseconds,
        progress: engine.progress,
        scriptId: _script.id,
        scriptTitle: _script.title,
        sectionId: currentSectionId,
        mirrorH: _settings.mirrorHorizontal,
        mirrorV: _settings.mirrorVertical,
        voice: _voiceActive,
        ts: DateTime.now().millisecondsSinceEpoch,
      );

  @override
  Map<String, Object?> catalog() => {
        'scripts': [for (final s in _scripts) s.toJson()],
        'sections': [for (final s in _script.sections) s.toJson()],
      };

  Future<void> _refreshScripts() async {
    try {
      _scripts = await repository.list();
    } on Object catch (e) {
      debugPrint('PF: no se pudo listar guiones: $e');
    }
  }

  @override
  void dispose() {
    _voiceSub?.cancel();
    server.dispose();
    engine.dispose();
    super.dispose();
  }
}
