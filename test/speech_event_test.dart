import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/voice/speech_recognizer.dart';

void main() {
  test('parsea parciales y finales tal como los emite Vosk', () {
    final p = VoskSpeechRecognizer.parseEvent({'raw': '{\n  "partial" : "hola a todos"\n}', 'final': false});
    expect(p.text, 'hola a todos');
    expect(p.isFinal, isFalse);

    final f = VoskSpeechRecognizer.parseEvent({'raw': '{\n  "text" : "bienvenidos"\n}', 'final': true});
    expect(f.text, 'bienvenidos');
    expect(f.isFinal, isTrue);

    expect(VoskSpeechRecognizer.parseEvent({'raw': '{"partial" : ""}', 'final': false}).text, isEmpty);
  });
}
