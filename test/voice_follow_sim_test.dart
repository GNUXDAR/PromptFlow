import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/data/parsing/script_parser.dart';
import 'package:promptflow/domain/entities/prompter_settings.dart';
import 'package:promptflow/engine/script_layout.dart';
import 'package:promptflow/engine/scroll_engine.dart';
import 'package:promptflow/voice/voice_aligner.dart';

/// Simulación de lectura en voz alta de punta a punta (sin audio):
/// orador → reconocedor con latencia, palabras perdidas y confundidas →
/// VoiceAligner → ScrollEngine. Mide lo que nota el usuario:
/// * retraso del texto respecto a la voz (en palabras),
/// * tirones: tiempo que el texto pasa quieto mientras el orador habla,
/// * retrocesos visibles.
final class FollowMetrics {
  FollowMetrics(this.meanLag, this.p95Lag, this.stillWhileTalking, this.maxBackstep);
  final double meanLag;
  final double p95Lag;

  /// Fracción de frames en los que el texto no se mueve aunque el orador habla.
  final double stillWhileTalking;
  final double maxBackstep;

  @override
  String toString() => 'retraso medio ${meanLag.toStringAsFixed(2)} pal · p95 ${p95Lag.toStringAsFixed(2)} pal · '
      'quieto mientras habla ${(stillWhileTalking * 100).toStringAsFixed(0)} % · '
      'retroceso máx ${maxBackstep.toStringAsFixed(1)} px';
}

const _vocab = [
  'hoy', 'vamos', 'a', 'hablar', 'de', 'cómo', 'funciona', 'el', 'teleprompter', 'con', 'la', 'voz',
  'cuando', 'lees', 'texto', 'avanza', 'solo', 'sin', 'que', 'nadie', 'toque', 'nada', 'en', 'pantalla',
  'esto', 'permite', 'grabar', 'más', 'rápido', 'y', 'mirar', 'siempre', 'a', 'cámara', 'mientras', 'hablas',
];

FollowMetrics simulate({
  int words = 400,
  double wpm = 150,
  double latency = 0.4,
  double partialEvery = 0.2,
  double dropRate = 0.15,
  double subRate = 0.10,
  int seed = 7,
}) {
  final rnd = math.Random(seed);
  final text = StringBuffer();
  for (var i = 0; i < words; i++) {
    text.write(_vocab[rnd.nextInt(_vocab.length)]);
    text.write(i % 40 == 39 ? '.\n\n' : ' ');
  }
  final script = ScriptParser.parse(text.toString(), id: 'sim');
  final layout = ScriptLayout.build(script, const PrompterSettings(fontSize: 56), 900);
  var now = Duration.zero;
  final engine = ScrollEngine.manual(clock: () => now)
    ..setLayout(layout)
    ..setWpm(wpm)
    ..setMode(ScrollMode.voiceFollow);
  final aligner = VoiceAligner(script.readableWords);

  // Lo que "oye" el reconocedor de cada palabra dicha.
  final heard = <String?>[
    for (final w in script.readableWords)
      rnd.nextDouble() < dropRate
          ? null
          : rnd.nextDouble() < subRate
              ? '${w}s'
              : w,
  ];

  const frame = Duration(microseconds: 16667);
  final wordsPerSec = wpm / 60;
  var nextPartial = 0.0;
  var utteranceStart = 0;
  final lags = <double>[];
  var still = 0, talking = 0;
  var maxBack = 0.0;
  var prevOffset = engine.offset;

  for (var t = 0.0; t < words / wordsPerSec + 2; t += frame.inMicroseconds / 1e6) {
    now += frame;
    final spoken = (t * wordsPerSec).floor().clamp(0, words); // palabras ya dichas
    if (t >= nextPartial) {
      nextPartial += partialEvery;
      // El parcial refleja el audio de hace `latency` segundos.
      final recognized = ((t - latency) * wordsPerSec).floor().clamp(0, words);
      if (recognized - utteranceStart > 12) utteranceStart = recognized - 4; // Vosk cierra frases
      final hyp = heard.sublist(utteranceStart, recognized).whereType<String>().join(' ');
      final idx = aligner.feed(hyp);
      if (idx != null) engine.followWord(idx.toDouble());
    }
    engine.advance(frame);

    if (t > 3 && spoken < words - 5) {
      lags.add(spoken - engine.wordPosition);
      talking++;
      if ((engine.offset - prevOffset).abs() < 0.01) still++;
    }
    maxBack = math.max(maxBack, prevOffset - engine.offset);
    prevOffset = engine.offset;
  }
  lags.sort();
  final mean = lags.reduce((a, b) => a + b) / lags.length;
  return FollowMetrics(mean, lags[(lags.length * 0.95).floor()], still / talking, maxBack);
}

void main() {
  test('seguimiento por voz realista: poco retraso, sin tirones ni retrocesos', () {
    final m = simulate();
    // ignore: avoid_print
    print('Simulación 150 WPM, latencia 0,4 s, 15 % perdidas, 10 % confundidas → $m');
    expect(m.meanLag, lessThan(2.0), reason: 'el texto va con la voz');
    expect(m.p95Lag, lessThan(4.0));
    expect(m.stillWhileTalking, lessThan(0.10), reason: 'movimiento continuo, no a saltos de línea');
    expect(m.maxBackstep, lessThan(1.0), reason: 'nunca retrocede mientras se lee');
  });

  test('robusto a otra velocidad y más errores del reconocedor', () {
    final m = simulate(wpm: 190, dropRate: 0.25, subRate: 0.15, seed: 21);
    // ignore: avoid_print
    print('Simulación 190 WPM, 25 % perdidas, 15 % confundidas → $m');
    expect(m.meanLag, lessThan(3.0));
    expect(m.stillWhileTalking, lessThan(0.15));
  });
}
