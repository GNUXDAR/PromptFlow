import 'dart:async';

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
  Future<bool> get isAvailable;

  /// Carga el modelo (p. ej. `vosk-model-small-es-0.42`, ~40 MB) y abre el micro.
  Future<void> start({required String modelPath, String? grammarHint});
  Future<void> stop();
  Stream<RecognizedSpeech> get results;
}

/// Puente a Vosk vía platform channels.
///
/// * **Android**: plugin Kotlin con `org.vosk.android.SpeechService`
///   (AudioRecord 16 kHz mono, VAD interno de Kaldi).
/// * **Linux**: plugin C++ que enlaza `libvosk.so` y captura con PipeWire/Pulse.
///
/// Ambos publican `{"text": "...", "final": bool}` en el EventChannel.
/// El lado nativo está especificado en `docs/ARCHITECTURE.md §5` y **no está
/// incluido en este esqueleto**: sin él, [isAvailable] devuelve `false` y la
/// UI oculta el modo voz.
class VoskSpeechRecognizer implements SpeechRecognizer {
  static const _method = MethodChannel('promptflow/stt');
  static const _events = EventChannel('promptflow/stt/events');

  Stream<RecognizedSpeech>? _stream;

  @override
  Future<bool> get isAvailable async {
    try {
      return await _method.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> start({required String modelPath, String? grammarHint}) =>
      _method.invokeMethod('start', {'modelPath': modelPath, 'grammar': grammarHint});

  @override
  Future<void> stop() => _method.invokeMethod('stop');

  @override
  Stream<RecognizedSpeech> get results => _stream ??= _events.receiveBroadcastStream().map((e) {
        final m = (e as Map).cast<String, Object?>();
        return RecognizedSpeech(m['text'] as String? ?? '', isFinal: m['final'] == true);
      });
}
