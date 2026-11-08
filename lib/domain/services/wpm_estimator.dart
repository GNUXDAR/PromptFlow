import '../entities/script.dart';

/// Cálculo de duración y WPM para el editor (Módulo B).
abstract final class WpmEstimator {
  /// Duración estimada de lectura a [wpm] más las pausas programadas.
  static Duration estimate(Script script, double wpm) {
    if (wpm <= 0) return Duration.zero;
    final readingMs = script.wordCount / wpm * 60000;
    return Duration(milliseconds: readingMs.round()) + script.scheduledPauses;
  }

  /// WPM necesarios para que el guion dure exactamente [target].
  /// Devuelve `null` si las pausas ya superan el objetivo.
  static double? wpmForDuration(Script script, Duration target) {
    final reading = target - script.scheduledPauses;
    if (reading <= Duration.zero || script.wordCount == 0) return null;
    return script.wordCount / (reading.inMilliseconds / 60000);
  }

  /// WPM reales medidos durante una lectura (p. ej. con voz):
  /// palabras avanzadas / tiempo hablado.
  static double measured(int wordsAdvanced, Duration spoken) =>
      spoken.inMilliseconds <= 0 ? 0 : wordsAdvanced / (spoken.inMilliseconds / 60000);
}

String formatDuration(Duration d) {
  final neg = d.isNegative;
  final s = d.abs().inSeconds;
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  final body = h > 0
      ? '$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}'
      : '$m:${sec.toString().padLeft(2, '0')}';
  return neg ? '-$body' : body;
}
