// Prueba de integración del plugin nativo de Vosk en Linux (canales reales,
// libvosk real, modelo real). Sin micrófono: el plugin lee un WAV.
//
//   PROMPTFLOW_STT_WAV=/ruta/test.wav PROMPTFLOW_TEST_MODEL=/ruta/modelo \
//   PROMPTFLOW_TEST_EXPECT="one zero zero zero one" \
//     flutter test -d linux integration_test/vosk_linux_test.dart
//
// Sin PROMPTFLOW_STT_WAV se prueba el micrófono real con PROMPTFLOW_TEST_MODEL.
//
// El WAV de ejemplo de Vosk y su modelo inglés pequeño sirven para validar
// la tubería; con un modelo español y un WAV en español se valida el idioma.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promptflow/voice/speech_recognizer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final env = Platform.environment;
  final model = env['PROMPTFLOW_TEST_MODEL'];
  final expected = env['PROMPTFLOW_TEST_EXPECT'];
  final skip = model == null || env['PROMPTFLOW_STT_WAV'] == null
      ? 'Define PROMPTFLOW_STT_WAV y PROMPTFLOW_TEST_MODEL'
      : null;

  testWidgets('Vosk: parciales en streaming y resultado final', (tester) async {
    final stt = VoskSpeechRecognizer();
    expect(await stt.isAvailable(modelPath: model!), isTrue);
    expect(await stt.isAvailable(modelPath: '/no/existe'), isFalse);

    final partials = <String>[];
    final finals = <String>[];
    final firstPartialAt = Completer<Duration>();
    final clock = Stopwatch();
    final sub = stt.results.listen((r) {
      if (r.isFinal) {
        finals.add(r.text);
      } else {
        partials.add(r.text);
        if (!firstPartialAt.isCompleted) firstPartialAt.complete(clock.elapsed);
      }
    });

    await tester.runAsync(() async {
      clock.start();
      await stt.start(modelPath: model); // resuelve con el audio ya abierto
      // El WAV (~8.3 s) se lee a ritmo real; al acabar llega el último final.
      await Future<void>.delayed(const Duration(seconds: 10));
      await stt.stop();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await sub.cancel();

    final heard = finals.join(' ');
    // ignore: avoid_print
    print('Primer parcial a ${(await firstPartialAt.future).inMilliseconds} ms · '
        '${partials.length} parciales · final: "$heard"');
    expect(partials, isNotEmpty, reason: 'streaming: debe haber parciales antes del final');
    if (expected != null) expect(heard, contains(expected));

    // Arranque con gramática restringida (lista JSON de palabras).
    await tester.runAsync(() async {
      await stt.start(modelPath: model, grammar: '["one", "zero", "two", "[unk]"]');
      await stt.stop();
    });
  }, skip: skip != null);

  testWidgets('start con modelo inexistente lanza PlatformException', (tester) async {
    final stt = VoskSpeechRecognizer();
    await tester.runAsync(() async {
      await expectLater(stt.start(modelPath: '/no/existe'), throwsA(isA<Exception>()));
    });
  }, skip: skip != null);

  testWidgets('micrófono real (PipeWire/Pulse): abre, escucha y cierra', (tester) async {
    final stt = VoskSpeechRecognizer();
    expect(await stt.isAvailable(modelPath: model!), isTrue);
    await tester.runAsync(() async {
      final sw = Stopwatch()..start();
      await stt.start(modelPath: model, grammar: '["hola", "a", "todos", "[unk]"]');
      // ignore: avoid_print
      print('Micrófono abierto y modelo cargado en ${sw.elapsedMilliseconds} ms');
      await Future<void>.delayed(const Duration(seconds: 2));
      sw.reset();
      await stt.stop();
      // ignore: avoid_print
      print('stop() en ${sw.elapsedMilliseconds} ms');
    });
  }, skip: model == null || env['PROMPTFLOW_STT_WAV'] != null);
}
