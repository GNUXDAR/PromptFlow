/// Modelo de dominio de un guion ya parseado.
///
/// El guion es una lista de bloques (encabezados de sección y párrafos);
/// cada bloque es una lista de spans tipados. Ningún tipo aquí depende de
/// Flutter: la maquetación vive en `engine/script_layout.dart`.
library;

enum ScriptFormat { plainText, markdown }

/// Fragmento mínimo de un bloque.
sealed class ScriptSpan {
  const ScriptSpan();
}

/// Texto leíble. [emphasis] = `**negrita**`, [highlight] = `==resaltado==`.
final class TextRun extends ScriptSpan {
  const TextRun(this.text, {this.emphasis = false, this.highlight = false});
  final String text;
  final bool emphasis;
  final bool highlight;

  int get wordCount => countWords(text);
}

/// Indicación de cámara: `[CAM 1]`, `[CAM 2]`… No se lee en voz alta.
final class CameraTag extends ScriptSpan {
  const CameraTag(this.label);
  final String label;
}

/// Pausa: `[PAUSE]` (detiene hasta reanudar) o `[PAUSE 3s]` (automática).
final class PauseMark extends ScriptSpan {
  const PauseMark(this.duration);

  /// `null` = pausa manual (hold hasta que el operador reanude).
  final Duration? duration;
}

/// Marca de entrada: `[CUE nombre]`. Se puede saltar a ella desde el mando.
final class CueMark extends ScriptSpan {
  const CueMark(this.id, this.label);
  final String id;
  final String label;
}

enum BlockKind { heading, paragraph }

final class ScriptBlock {
  const ScriptBlock({
    required this.kind,
    required this.spans,
    this.sectionId,
    this.level = 0,
  });

  final BlockKind kind;
  final List<ScriptSpan> spans;

  /// Id de la sección si el bloque es un encabezado (`#`, `##`).
  final String? sectionId;
  final int level;

  /// Los encabezados son navegación, no se leen: no cuentan como palabras.
  int get wordCount =>
      kind == BlockKind.heading ? 0 : spans.whereType<TextRun>().fold(0, (a, r) => a + r.wordCount);

  String get plainText => spans.whereType<TextRun>().map((r) => r.text).join();
}

/// Sección navegable (destino de `cmd.jump`).
final class ScriptSection {
  const ScriptSection({required this.id, required this.title, required this.blockIndex});
  final String id;
  final String title;
  final int blockIndex;

  Map<String, Object?> toJson() => {'id': id, 'title': title};
}

final class Script {
  Script({
    required this.id,
    required this.title,
    required this.source,
    required this.format,
    required this.blocks,
  }) : sections = [
          for (var i = 0; i < blocks.length; i++)
            if (blocks[i].sectionId != null)
              ScriptSection(id: blocks[i].sectionId!, title: blocks[i].plainText.trim(), blockIndex: i),
          for (var i = 0; i < blocks.length; i++)
            for (final cue in blocks[i].spans.whereType<CueMark>())
              ScriptSection(id: cue.id, title: '▸ ${cue.label}', blockIndex: i),
        ]..sort((a, b) => a.blockIndex.compareTo(b.blockIndex));

  final String id;
  final String title;

  /// Texto original (para el editor y para `script.push` por la red).
  final String source;
  final ScriptFormat format;
  final List<ScriptBlock> blocks;
  final List<ScriptSection> sections;

  late final int wordCount = blocks.fold(0, (a, b) => a + b.wordCount);

  /// Palabras leíbles en orden; el índice coincide con `ScriptLayout.wordOffsets`.
  late final List<String> readableWords = [
    for (final b in blocks)
      if (b.kind != BlockKind.heading)
        for (final r in b.spans.whereType<TextRun>()) ...tokenizeWords(r.text),
  ];

  /// Suma de pausas automáticas programadas.
  late final Duration scheduledPauses = blocks
      .expand((b) => b.spans)
      .whereType<PauseMark>()
      .fold(Duration.zero, (a, p) => a + (p.duration ?? Duration.zero));
}

/// Definición única de "palabra" (conteo WPM, maquetación y alineado de voz
/// usan la misma, así los índices coinciden en todos los módulos).
final wordPattern = RegExp(r"[\p{L}\p{N}]+(?:['’\-][\p{L}\p{N}]+)*", unicode: true);

int countWords(String text) => wordPattern.allMatches(text).length;

Iterable<String> tokenizeWords(String text) =>
    wordPattern.allMatches(text).map((m) => m.group(0)!);
