import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'script_layout.dart';

enum ScrollMode {
  /// Velocidad constante a partir de los WPM objetivo.
  timed,

  /// La posición la marca el reconocimiento de voz; el motor la persigue
  /// con un controlador proporcional suavizado (sin saltos).
  voiceFollow,
}

enum PlaybackStatus { stopped, playing, autoPaused, holding, finished }

/// Motor de desplazamiento del teleprompter (Módulo A).
///
/// ### Bucle de animación
/// * Un [Ticker] sincronizado con el VSync del compositor: 60 Hz, o 90/120 Hz
///   si la pantalla lo permite, sin tearing (Flutter presenta en el VSync).
/// * Integración por **tiempo delta** (`v·dt`), no por frame: si un frame se
///   retrasa, el siguiente avanza lo proporcional y la velocidad percibida no
///   cambia. El `dt` se acota a [maxFrameDelta] para que una suspensión de la
///   app no provoque un salto.
/// * La velocidad se acerca a la objetivo con un filtro exponencial
///   (constante [velocityTau]): play/pause/cambios de WPM arrancan y frenan
///   con suavidad, como una inercia física.
/// * Los saltos (Rewind/Forward 5 s, secciones) también se animan con un
///   decaimiento exponencial independiente del frame-rate.
/// * El Ticker se detiene cuando no hay nada que animar (0 % CPU en reposo).
///
/// El motor no pinta: expone [offset] y notifica a sus listeners. El
/// `PrompterPainter` se registra como `repaint:` del `CustomPaint`, así cada
/// frame repinta **solo** la capa del texto, sin reconstruir widgets.
/// El mirroring horizontal/vertical se aplica en el pintor como transformación
/// del canvas, de modo que no tiene coste por frame.
class ScrollEngine extends ChangeNotifier {
  ScrollEngine({required TickerProvider vsync, this.onMarker}) : _wallClock = (Stopwatch()..start()).elapsedFn {
    _ticker = vsync.createTicker(_onTick);
  }

  /// Constructor para tests: sin Ticker, se avanza con [advance]. [clock]
  /// permite simular el paso del tiempo real en el seguimiento por voz.
  @visibleForTesting
  ScrollEngine.manual({this.onMarker, Duration Function()? clock})
      : _ticker = null,
        _wallClock = clock ?? (Stopwatch()..start()).elapsedFn;

  /// Reloj de pared. El seguimiento por voz mide la velocidad del habla con
  /// él y no con el reloj del Ticker, que se detiene cuando el motor reposa.
  final Duration Function() _wallClock;
  double get _now => _wallClock().inMicroseconds / 1e6;

  static const maxFrameDelta = Duration(milliseconds: 250);
  static const velocityTau = 0.22; // s — rampa de arranque/frenado
  static const seekTau = 0.12; // s — animación de saltos
  static const followGain = 2.5; // 1/s — corrección proporcional del error
  /// Rampa en modo voz. Lazo P + filtro de 1er orden: amortiguamiento
  /// crítico cuando 4·τ·K = 1 → τ = 0.1 s con K = 2.5 (sin sobrepaso).
  static const followVelocityTau = 0.1;
  static const followMaxSpeed = 3000.0; // px/s — tope para alcanzar saltos grandes
  static const followStale = 1.5; // s sin reconocer → el orador se detuvo
  /// Latencia típica del reconocedor (audio → parcial). El objetivo se
  /// proyecta este tiempo hacia delante a la velocidad del habla, para que
  /// el texto vaya con la voz y no medio segundo por detrás.
  static const followLatency = 0.35;
  /// Horizonte máximo de la proyección: si el orador calla, el texto se
  /// adelanta como mucho esto antes de detenerse.
  static const followMaxProjection = 0.8;

  late final Ticker? _ticker;

  /// Avisa cuando la lectura cruza una pausa/cue (para HUD y clientes remotos).
  final void Function(LayoutMarker marker)? onMarker;

  ScriptLayout? _layout;
  double _offset = 0;
  double _velocity = 0; // px/s actuales
  double _wpm = 140;
  double _pendingSeek = 0; // px aún por recorrer de un salto animado
  double? _followTarget; // px objetivo en modo voz
  double _followRate = 0; // px/s estimados del habla (feed-forward)
  double? _lastFollowAt; // reloj de pared (s) del último reconocimiento
  int _nextMarker = 0;
  Duration? _autoPauseLeft;
  Duration _lastElapsed = Duration.zero;
  PlaybackStatus _status = PlaybackStatus.stopped;
  ScrollMode _mode = ScrollMode.timed;
  int _revision = 0;

  // ───────────────────────── Estado público ─────────────────────────

  double get offset => _offset;
  double get velocity => _velocity;
  double get wpm => _wpm;
  PlaybackStatus get status => _status;
  ScrollMode get mode => _mode;
  ScriptLayout? get layout => _layout;
  bool get isPlaying => _status == PlaybackStatus.playing || _status == PlaybackStatus.autoPaused;
  Duration? get autoPauseLeft => _autoPauseLeft;

  /// Contador monotónico de cambios discretos (play, seek, wpm…). El
  /// servidor lo usa como `rev` para que los clientes descarten estados viejos.
  int get revision => _revision;

  /// Posición en palabras (unidad del protocolo).
  double get wordPosition => _layout?.wordAt(_offset) ?? 0;

  double get progress {
    final l = _layout;
    if (l == null || l.maxOffset <= l.minOffset) return 0;
    return ((_offset - l.minOffset) / (l.maxOffset - l.minOffset)).clamp(0.0, 1.0);
  }

  double get _nominalSpeed => (_layout?.pxPerWord ?? 0) * _wpm / 60.0;

  /// Tiempo restante en tiempo real: distancia / velocidad nominal +
  /// pausas automáticas pendientes + la pausa en curso.
  Duration get remaining {
    final l = _layout;
    if (l == null || _wpm <= 0) return Duration.zero;
    final words = math.max(0.0, (l.wordCount - 1) - wordPosition);
    var ms = words / _wpm * 60000;
    for (var i = _nextMarker; i < l.markers.length; i++) {
      final m = l.markers[i];
      if (m.kind == MarkerKind.pause) ms += m.duration?.inMilliseconds ?? 0;
    }
    ms += _autoPauseLeft?.inMilliseconds ?? 0;
    return Duration(milliseconds: ms.round());
  }

  // ───────────────────────── Comandos ─────────────────────────

  /// Instala una nueva maquetación conservando la palabra en foco.
  /// [notify] = false cuando se llama durante `build` (cambio de tamaño):
  /// el pintor leerá la nueva maquetación en la fase de paint del mismo frame.
  void setLayout(ScriptLayout layout, {bool keepPosition = true, bool notify = true}) {
    final word = keepPosition && _layout != null ? wordPosition : 0.0;
    final old = _layout;
    _layout = layout;
    if (!identical(old, layout)) old?.dispose();
    _offset = layout.offsetForWord(word);
    _pendingSeek = 0;
    _followTarget = null;
    _syncNextMarker();
    _revision++;
    if (notify) _bump();
  }

  void play() {
    if (_layout == null) return;
    if (_status == PlaybackStatus.finished) _offset = _layout!.minOffset;
    _status = PlaybackStatus.playing;
    _syncNextMarker(inclusive: false);
    _bump();
  }

  void pause() {
    if (_status == PlaybackStatus.stopped) return;
    _status = PlaybackStatus.stopped;
    _autoPauseLeft = null;
    _bump();
  }

  /// En `holding` (pausa manual del guion) el toggle reanuda.
  void toggle() => isPlaying ? pause() : play();

  void setWpm(double wpm) {
    _wpm = wpm.clamp(40, 400).toDouble();
    _bump();
  }

  void nudgeWpm(double delta) => setWpm(_wpm + delta);

  /// Rewind/Forward en segundos de lectura a la velocidad actual.
  void seekSeconds(double seconds) => seekWords(seconds * _wpm / 60.0);

  void seekWords(double words) {
    final l = _layout;
    if (l == null) return;
    seekToOffset(l.offsetForWord(wordPosition + words));
  }

  void jumpToMarker(String id) {
    final y = _layout?.offsetForMarker(id);
    if (y != null) seekToOffset(y);
  }

  /// Salto animado (no instantáneo) a una posición absoluta.
  void seekToOffset(double target, {bool animate = true}) {
    final l = _layout;
    if (l == null) return;
    final clamped = target.clamp(l.minOffset, l.maxOffset).toDouble();
    if (animate) {
      _pendingSeek = clamped - _offset;
    } else {
      _offset = clamped;
      _pendingSeek = 0;
    }
    _autoPauseLeft = null;
    if (_status == PlaybackStatus.autoPaused || _status == PlaybackStatus.holding) {
      _status = PlaybackStatus.playing;
    }
    if (_status == PlaybackStatus.finished) _status = PlaybackStatus.stopped;
    _syncNextMarker(from: clamped);
    _bump();
  }

  void setMode(ScrollMode mode) {
    _mode = mode;
    _followTarget = null;
    _followRate = 0;
    _lastFollowAt = null;
    _bump();
  }

  /// Entrada del sincronizador de voz: palabra que el usuario está diciendo.
  void followWord(double word) {
    final l = _layout;
    if (l == null || _mode != ScrollMode.voiceFollow) return;
    final target = l.offsetForWord(word);
    // Feed-forward: velocidad del habla estimada entre reconocimientos (EMA).
    // Sin ella, un control solo proporcional va siempre por detrás (v/K s).
    final now = _now;
    final prev = _followTarget, at = _lastFollowAt;
    if (prev != null && at != null && now - at > 0.05) {
      // Los saltos grandes (correcciones del alineador) no son velocidad real.
      final cap = math.max(_nominalSpeed, 40) * 3;
      final rate = ((target - prev) / (now - at)).clamp(0.0, cap);
      _followRate += (rate - _followRate) * 0.35;
    }
    _followTarget = target;
    _lastFollowAt = now;
    _ensureTicking();
  }

  // ───────────────────────── Bucle de animación ─────────────────────────

  void _onTick(Duration elapsed) {
    var dt = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (dt > maxFrameDelta) dt = maxFrameDelta;
    if (dt <= Duration.zero) return;
    advance(dt);
    if (_isIdle) _stopTicker();
  }

  /// Un paso de integración. Público para tests deterministas.
  @visibleForTesting
  void advance(Duration delta) {
    final l = _layout;
    if (l == null) return;
    final dt = delta.inMicroseconds / 1e6;

    // 1. Pausa automática en curso: consume tiempo, velocidad objetivo 0.
    if (_status == PlaybackStatus.autoPaused) {
      final left = _autoPauseLeft! - delta;
      if (left <= Duration.zero) {
        _autoPauseLeft = null;
        _status = PlaybackStatus.playing;
        _revision++;
      } else {
        _autoPauseLeft = left;
      }
    }

    // 2. Velocidad objetivo según el modo.
    double target;
    if (_mode == ScrollMode.voiceFollow && _followTarget != null) {
      final since = _lastFollowAt == null ? 0.0 : _now - _lastFollowAt!;
      if (since > followStale) _followRate = 0;
      // Objetivo proyectado: el último reconocimiento + lo que el orador ha
      // dicho desde entonces (velocidad estimada × tiempo, incluida la latencia).
      final projected = _followTarget! + _followRate * math.min(since + followLatency, followMaxProjection);
      final err = projected - _offset;
      // Sin feed-forward hacia atrás: si el orador retrocede solo corrige el error.
      final ff = err > -1 ? _followRate : 0.0;
      target = (ff + err * followGain).clamp(-followMaxSpeed, followMaxSpeed).toDouble();
      // Zona muerta: un adelanto pequeño no hace retroceder el texto (se ve
      // como temblor); solo un retroceso real del orador (> 1 línea) lo hace.
      final deadZone = (_layout?.pxPerWord ?? 10) * 8;
      if (err < 0 && err > -deadZone) target = 0;
    } else {
      target = _status == PlaybackStatus.playing ? _nominalSpeed : 0;
    }

    // 3. Suavizado exponencial independiente del frame-rate.
    final tau = _mode == ScrollMode.voiceFollow ? followVelocityTau : velocityTau;
    _velocity += (target - _velocity) * (1 - math.exp(-dt / tau));
    if (target == 0 && _velocity.abs() < 0.5) _velocity = 0;

    // 4. Salto animado pendiente.
    var seekStep = 0.0;
    if (_pendingSeek != 0) {
      seekStep = _pendingSeek * (1 - math.exp(-dt / seekTau));
      if ((_pendingSeek - seekStep).abs() < 0.5) seekStep = _pendingSeek;
      _pendingSeek -= seekStep;
    }

    final from = _offset;
    var to = (_offset + _velocity * dt + seekStep).clamp(l.minOffset, l.maxOffset).toDouble();

    // 5. Cruce de marcas (solo avanzando por reproducción, no por saltos).
    if (_pendingSeek == 0 && seekStep == 0 && to > from) {
      while (_nextMarker < l.markers.length && l.markers[_nextMarker].y <= to) {
        final m = l.markers[_nextMarker++];
        if (m.y <= from) continue;
        onMarker?.call(m);
        if (m.kind == MarkerKind.pause && _mode == ScrollMode.timed) {
          to = m.y; // se detiene exactamente sobre la pausa
          _velocity = 0;
          if (m.duration == null) {
            _status = PlaybackStatus.holding;
          } else {
            _status = PlaybackStatus.autoPaused;
            _autoPauseLeft = m.duration;
          }
          _revision++;
          break;
        }
      }
    }

    // 6. Fin del guion.
    if (to >= l.maxOffset && _status == PlaybackStatus.playing && _mode == ScrollMode.timed) {
      _status = PlaybackStatus.finished;
      _velocity = 0;
      _revision++;
    }

    _offset = to;
    notifyListeners();
  }

  bool get _isIdle =>
      !isPlaying &&
      _velocity == 0 &&
      _pendingSeek == 0 &&
      _followRate == 0 &&
      (_followTarget == null || (_followTarget! - _offset).abs() < 0.5);

  void _syncNextMarker({double? from, bool inclusive = true}) {
    final l = _layout;
    if (l == null) return;
    final y = from ?? _offset;
    var i = 0;
    while (i < l.markers.length &&
        (inclusive ? l.markers[i].y < y : l.markers[i].y <= y)) {
      i++;
    }
    _nextMarker = i;
  }

  void _bump() {
    _revision++;
    _ensureTicking();
    notifyListeners();
  }

  void _ensureTicking() {
    final t = _ticker;
    if (t == null || t.isActive || _isIdle) return;
    _lastElapsed = Duration.zero;
    t.start();
  }

  void _stopTicker() {
    _ticker?.stop();
    _lastElapsed = Duration.zero;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _layout?.dispose();
    super.dispose();
  }
}

extension on Stopwatch {
  Duration Function() get elapsedFn => () => elapsed;
}
