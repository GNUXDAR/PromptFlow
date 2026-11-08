import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/domain/entities/script.dart';
import 'package:promptflow/voice/voice_aligner.dart';

void main() {
  final words = tokenizeWords(
    'Hola a todos y bienvenidos al programa de hoy. '
    'Hoy hablaremos de teleprompters y de cómo la voz controla el texto. '
    'Empezamos con una pregunta sencilla: ¿qué es la latencia? '
    'La latencia es el tiempo entre que hablas y el texto se mueve. '
    'Y al final del programa repetimos: bienvenidos al programa de hoy.',
  ).toList();

  test('sigue la lectura con parciales crecientes', () {
    final a = VoiceAligner(words);
    expect(a.feed('hola a todos'), 2);
    expect(a.feed('hola a todos y bienvenidos al programa'), 6);
    expect(a.feed('hoy hablaremos de teleprompters'), words.indexOf('teleprompters'));
  });

  test('tolera tildes y errores del reconocedor', () {
    final a = VoiceAligner(words)..reset(words.indexOf('controla'));
    // "como" sin tilde, "boz" mal reconocido.
    final idx = a.feed('de como la boz controla');
    expect(idx, words.indexOf('controla'));
  });

  test('una frase repetida lejos no provoca saltos', () {
    final a = VoiceAligner(words)..reset(4);
    final idx = a.feed('bienvenidos al programa de hoy');
    expect(idx, lessThan(20), reason: 'elige la aparición cercana, no la del final');
  });

  test('ruido o palabras sueltas ambiguas no mueven la posición', () {
    final a = VoiceAligner(words)..reset(10);
    expect(a.feed('eh'), isNull);
    expect(a.feed('xyz qwerty asdf'), isNull);
    expect(a.position, 10);
  });

  test('normalización y similitud', () {
    expect(VoiceAligner.normalize('Cómo'), 'como');
    expect(VoiceAligner.similarity('latencia', 'latensia'), greaterThan(0.85));
    expect(VoiceAligner.similarity('hola', 'texto'), lessThan(0.3));
  });
}
