import 'dart:math' as math;

import '../domain/entities/script.dart';

/// Alinea lo que el STT reconoce con las palabras del guion (Módulo D).
///
/// Algoritmo (O(ventana × n), sin dependencias):
/// 1. Toma las últimas [tail] palabras de la hipótesis (parcial o final).
/// 2. Busca en una ventana alrededor de la posición actual — poco hacia atrás,
///    bastante hacia delante — la posición donde esas palabras encajan mejor
///    *en orden*, con similitud difusa (Levenshtein normalizado, sin tildes).
/// 3. Puntúa con un sesgo de cercanía para no saltar a frases repetidas
///    lejanas. Retroceder exige una coincidencia casi perfecta.
///
/// Devuelve el índice de la palabra que el orador **acaba de decir**; el
/// motor la persigue con su controlador suavizado (`ScrollEngine.followWord`).
class VoiceAligner {
  VoiceAligner(List<String> scriptWords, {this.tail = 4, this.lookBehind = 12, this.lookAhead = 60})
      : _words = scriptWords.map(normalize).toList(growable: false);

  final List<String> _words;
  final int tail;
  final int lookBehind;
  final int lookAhead;
  int _position = 0;

  int get position => _position;

  void reset([int position = 0]) => _position = position.clamp(0, math.max(0, _words.length - 1));

  /// Procesa una hipótesis del reconocedor. `null` si no hay alineación fiable.
  int? feed(String hypothesis) {
    final heard = tokenizeWords(hypothesis).map(normalize).where((w) => w.isNotEmpty).toList();
    if (heard.isEmpty || _words.isEmpty) return null;
    final probe = heard.sublist(math.max(0, heard.length - tail));

    final start = math.max(0, _position - lookBehind);
    final end = math.min(_words.length - 1, _position + lookAhead);
    double bestScore = 0;
    int? best;

    for (var endIdx = start; endIdx <= end; endIdx++) {
      // Compara probe (alineado al final) con las palabras que terminan en endIdx.
      var score = 0.0;
      for (var k = 0; k < probe.length; k++) {
        final si = endIdx - (probe.length - 1 - k);
        if (si < 0) continue;
        score += similarity(probe[k], _words[si]);
      }
      score /= probe.length;
      final distance = (endIdx - _position).abs();
      final biased = score - distance * 0.002;
      final backwards = endIdx < _position;
      if (backwards && score < 0.95) continue;
      if (biased > bestScore) {
        bestScore = biased;
        best = endIdx;
      }
    }

    // Umbral: con una sola palabra oída exige coincidencia exacta.
    final threshold = probe.length == 1 ? 0.99 : 0.6;
    if (best == null || bestScore < threshold) return null;
    _position = best;
    return best;
  }

  static const _accents = {
    'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a',
    'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
    'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
    'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o',
    'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
    'ñ': 'n', 'ç': 'c',
  };

  static String normalize(String w) {
    final lower = w.toLowerCase();
    final b = StringBuffer();
    for (final ch in lower.split('')) {
      b.write(_accents[ch] ?? ch);
    }
    return b.toString().replaceAll(RegExp(r"['’\-]"), '');
  }

  /// 1 − distancia de Levenshtein normalizada.
  static double similarity(String a, String b) {
    if (a == b) return 1;
    if (a.isEmpty || b.isEmpty) return 0;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        cur[j] = math.min(math.min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      prev = cur;
    }
    return 1 - prev[b.length] / math.max(a.length, b.length);
  }
}
