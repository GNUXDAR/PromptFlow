import 'dart:math' as math;

import '../domain/entities/script.dart';

/// Alinea lo que el STT reconoce con las palabras del guion (Módulo D).
///
/// Algoritmo:
/// 1. Toma las últimas [tail] palabras de la hipótesis (parcial o final).
/// 2. Para cada posible palabra final del guion en una ventana alrededor de
///    la posición actual (poco hacia atrás, bastante hacia delante) calcula
///    un **alineamiento con huecos** (programación dinámica tipo
///    Needleman-Wunsch anclada al final): tolera palabras que el reconocedor
///    perdió, palabras de más (muletillas, `[unk]`) y errores de una letra
///    (similitud de Levenshtein, sin tildes).
/// 3. Penaliza la distancia a la posición actual para no saltar a frases
///    repetidas. Retroceder exige una coincidencia casi perfecta.
/// 4. **Saltos grandes con confirmación**: un salto de más de
///    [jumpConfirmWords] palabras solo se acepta si dos hipótesis seguidas lo
///    respaldan. Así un falso positivo aislado no arrastra el texto.
///
/// Devuelve el índice de la palabra que el orador **acaba de decir**.
class VoiceAligner {
  VoiceAligner(
    List<String> scriptWords, {
    this.tail = 6,
    this.lookBehind = 12,
    this.lookAhead = 40,
    this.jumpConfirmWords = 12,
  }) : _words = scriptWords.map(normalize).toList(growable: false);

  final List<String> _words;
  final int tail;
  final int lookBehind;
  final int lookAhead;
  final int jumpConfirmWords;
  int _position = 0;
  int? _pendingJump;

  static const _gap = 0.45; // coste de una palabra perdida o sobrante
  static const _minSimilarity = 0.7; // por debajo, la pareja cuenta como fallo
  static const _mismatch = -0.6;
  static const _distancePenalty = 0.004; // por palabra de distancia

  int get position => _position;

  void reset([int position = 0]) {
    _position = position.clamp(0, math.max(0, _words.length - 1));
    _pendingJump = null;
  }

  /// Procesa una hipótesis del reconocedor. `null` si no hay alineación fiable.
  int? feed(String hypothesis) {
    final heard = tokenizeWords(hypothesis).map(normalize).where((w) => w.isNotEmpty).toList();
    if (heard.isEmpty || _words.isEmpty) return null;
    final probe = heard.sublist(math.max(0, heard.length - tail));

    final start = math.max(0, _position - lookBehind);
    final end = math.min(_words.length - 1, _position + lookAhead);
    final sim = <(int, int), double>{};
    double pair(int k, int j) => sim.putIfAbsent((k, j), () => similarity(probe[k], _words[j]));

    double best = double.negativeInfinity;
    int? bestEnd;
    for (var e = start; e <= end; e++) {
      // La última palabra oída debe parecerse a la palabra final candidata
      // (o haber como mucho una palabra sobrante tras ella).
      final lastOk = pair(probe.length - 1, e) >= _minSimilarity ||
          (probe.length > 1 && pair(probe.length - 2, e) >= _minSimilarity);
      if (!lastOk) continue;
      final raw = _alignEndingAt(probe, e, pair) / probe.length;
      final backwards = e < _position;
      if (backwards && raw < 0.9) continue;
      final score = raw - (e - _position).abs() * _distancePenalty;
      if (score > best) {
        best = score;
        bestEnd = e;
      }
    }

    // Con una sola palabra oída exige coincidencia exacta (ambigüedad alta).
    final threshold = probe.length == 1 ? 0.99 : 0.5;
    if (bestEnd == null || best < threshold) return null;

    if ((bestEnd - _position).abs() > jumpConfirmWords) {
      final confirmed = _pendingJump != null && (bestEnd - _pendingJump!).abs() <= 3;
      _pendingJump = bestEnd;
      if (!confirmed) return null;
    }
    _pendingJump = null;
    _position = bestEnd;
    return bestEnd;
  }

  /// Puntuación del mejor alineamiento de [probe] contra el guion terminando
  /// exactamente en la palabra [e]; el inicio en el guion es libre.
  double _alignEndingAt(List<String> probe, int e, double Function(int, int) pair) {
    final p = probe.length;
    final segStart = math.max(0, e - p - 3);
    final l = e - segStart + 1;
    // dp[i][j]: probe[0..i) alineado con guion[segStart .. segStart+j)
    var prev = List<double>.filled(l + 1, 0); // fila i = 0: inicio libre
    for (var i = 1; i <= p; i++) {
      final cur = List<double>.filled(l + 1, 0)..[0] = -_gap * i;
      for (var j = 1; j <= l; j++) {
        final s = pair(i - 1, segStart + j - 1);
        final match = prev[j - 1] + (s >= _minSimilarity ? s : _mismatch);
        cur[j] = math.max(match, math.max(prev[j] - _gap, cur[j - 1] - _gap));
      }
      prev = cur;
    }
    return prev[l];
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
