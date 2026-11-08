import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

/// Resultado del reconocedor. Vosk emite parciales cada ~100–200 ms; son los
/// que dan baja latencia al seguimiento.
final class RecognizedSpeech {
  const RecognizedSpeech(this.text, {required this.isFinal});
  final String text;
  final bool isFinal;
}

/// Abstracción del motor STT local (Módulo D). El dominio solo conoce esta
/// interfaz; la implementación nativa se elige por plataforma.
abstract interface class SpeechRecognizer {
  /// Librería nativa, audio y modelo presentes.
  Future<bool> isAvailable({required String modelPath});

  /// Carga el modelo (p. ej. `vosk-model-small-es-0.42`, ~40 MB) y abre el
  /// micro. Resuelve cuando ya se está escuchando; lanza si algo falla.
  /// [grammar]: lista JSON de palabras permitidas (`["hola", …, "[unk]"]`).
  Future<void> start({required String modelPath, String? grammar});
  Future<void> stop();
  Stream<RecognizedSpeech> get results;
}

/// Puente a Vosk vía platform channels.
///
/// * **Linux**: `linux/runner/vosk_stt_plugin.cc` (libvosk + PulseAudio/PipeWire
///   cargadas con dlopen). Implementado.
/// * **Android**: plugin Kotlin con `org.vosk.android.SpeechService`. Pendiente.
///
/// El lado nativo publica `{"raw": "<json de Vosk>", "final": bool}`; Vosk
/// devuelve `{"partial": "..."}` en parciales y `{"text": "..."}` en finales.
/// Sin plugin, [isAvailable] devuelve `false` y la UI oculta el modo voz.
class VoskSpeechRecognizer implements SpeechRecognizer {
  static const _method = MethodChannel('promptflow/stt');
  static const _events = EventChannel('promptflow/stt/events');

  Stream<RecognizedSpeech>? _stream;

  @override
  Future<bool> isAvailable({required String modelPath}) async {
    try {
      return await _method.invokeMethod<bool>('isAvailable', {'modelPath': modelPath}) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> start({required String modelPath, String? grammar}) =>
      _method.invokeMethod('start', {'modelPath': modelPath, 'grammar': ?grammar});

  @override
  Future<void> stop() => _method.invokeMethod('stop');

  @override
  Stream<RecognizedSpeech> get results =>
      _stream ??= _events.receiveBroadcastStream().map(parseEvent).where((r) => r.text.isNotEmpty);

  /// Convierte un evento del canal en [RecognizedSpeech].
  static RecognizedSpeech parseEvent(Object? event) {
    final m = (event as Map).cast<String, Object?>();
    final isFinal = m['final'] == true;
    var text = m['text'] as String? ?? '';
    final raw = m['raw'];
    if (raw is String && raw.isNotEmpty) {
      final j = jsonDecode(raw);
      if (j is Map) text = (j['text'] ?? j['partial'] ?? '') as String;
    }
    return RecognizedSpeech(text.trim(), isFinal: isFinal);
  }
}
