import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/data/parsing/script_parser.dart';
import 'package:promptflow/domain/entities/script.dart';
import 'package:promptflow/domain/services/wpm_estimator.dart';

void main() {
  const src = '''# Mi programa
<!-- nota interna -->
## Apertura
[CAM 1] Hola a **todos**, esto es ==importante==. [PAUSE 2s]
Segunda línea del mismo párrafo.

## Apertura
[CUE Entrevista] Pregunta uno. [PAUSE]
''';

  test('bloques, secciones con id único, marcas y conteo de palabras', () {
    final s = ScriptParser.parse(src, id: 'x');
    expect(s.title, 'Mi programa');
    expect(s.blocks.where((b) => b.kind == BlockKind.heading), hasLength(3));
    expect(s.sections.map((x) => x.id), ['mi-programa', 'apertura', 'apertura-2', 'cue-entrevista']);

    final p1 = s.blocks[2];
    expect(p1.spans.first, isA<CameraTag>());
    expect(p1.spans.whereType<TextRun>().where((r) => r.emphasis).single.text, 'todos');
    expect(p1.spans.whereType<TextRun>().where((r) => r.highlight).single.text, 'importante');
    expect((p1.spans.whereType<PauseMark>().single).duration, const Duration(seconds: 2));
    expect(s.blocks.last.spans.whereType<PauseMark>().single.duration, isNull);

    // Encabezados, etiquetas y comentarios no cuentan.
    expect(s.wordCount, 'Hola a todos esto es importante Segunda línea del mismo párrafo Pregunta uno'.split(' ').length);
    expect(s.readableWords, hasLength(s.wordCount));
    expect(s.scheduledPauses, const Duration(seconds: 2));
  });

  test('.txt solo interpreta etiquetas, no Markdown', () {
    final s = ScriptParser.parse('# no es título **ni negrita** [PAUSE 1,5]', id: 't', format: ScriptFormat.plainText);
    expect(s.sections, isEmpty);
    expect(s.blocks.single.spans.whereType<TextRun>().any((r) => r.emphasis), isFalse);
    expect(s.blocks.single.spans.whereType<PauseMark>().single.duration, const Duration(milliseconds: 1500));
  });

  test('estimación de duración y WPM necesarios', () {
    final s = ScriptParser.parse(List.filled(300, 'hola').join(' '), id: 'w');
    expect(WpmEstimator.estimate(s, 150), const Duration(minutes: 2));
    expect(WpmEstimator.wpmForDuration(s, const Duration(minutes: 3)), closeTo(100, 0.01));
    expect(formatDuration(const Duration(seconds: 3725)), '1:02:05');
  });
}
