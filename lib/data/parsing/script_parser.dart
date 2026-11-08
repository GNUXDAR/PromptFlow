import '../../domain/entities/script.dart';

/// Parser del formato de guion de PromptFlow: subconjunto de Markdown más
/// etiquetas entre corchetes. En `.txt` solo se interpretan las etiquetas.
///
/// ```text
/// # Título / ## Sección      → encabezado y destino de salto
/// **énfasis**                → negrita amarilla
/// ==resaltado==              → fondo resaltado
/// [CAM 1]                    → indicación de cámara (no se lee)
/// [PAUSE] | [PAUSE 2.5s]     → pausa manual | automática
/// [CUE Entrevista]           → marca de entrada (destino de salto)
/// <!-- nota -->              → comentario, no se muestra
/// ```
abstract final class ScriptParser {
  static final _tag = RegExp(
    r'\[(CAM|CAMERA|PAUSE|PAUSA|CUE)(?:\s+([^\]]*))?\]',
    caseSensitive: false,
  );
  static final _inline = RegExp(r'\*\*(.+?)\*\*|==(.+?)==');
  static final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
  static final _comment = RegExp(r'<!--.*?-->', dotAll: true);
  static final _seconds = RegExp(r'^(\d+(?:[.,]\d+)?)\s*s?$', caseSensitive: false);

  static Script parse(String source, {required String id, String? title, ScriptFormat? format}) {
    final fmt = format ?? ScriptFormat.markdown;
    final md = fmt == ScriptFormat.markdown;
    final text = source.replaceAll('\r\n', '\n').replaceAll(_comment, '');

    final blocks = <ScriptBlock>[];
    final usedIds = <String>{};
    final paragraph = <String>[];
    String? firstHeading;

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      final spans = _parseInline(paragraph.join(' '), md, usedIds);
      paragraph.clear();
      if (spans.isNotEmpty) blocks.add(ScriptBlock(kind: BlockKind.paragraph, spans: spans));
    }

    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        flushParagraph();
        continue;
      }
      final h = md ? _heading.firstMatch(line) : null;
      if (h != null) {
        flushParagraph();
        final headingText = h.group(2)!.trim();
        firstHeading ??= headingText;
        blocks.add(ScriptBlock(
          kind: BlockKind.heading,
          level: h.group(1)!.length,
          sectionId: _uniqueId(_slug(headingText), usedIds),
          spans: _parseInline(headingText, md, usedIds),
        ));
        continue;
      }
      paragraph.add(line);
    }
    flushParagraph();

    return Script(
      id: id,
      title: title ?? firstHeading ?? 'Sin título',
      source: source,
      format: fmt,
      blocks: blocks,
    );
  }

  static List<ScriptSpan> _parseInline(String line, bool md, Set<String> usedIds) {
    final out = <ScriptSpan>[];
    var cursor = 0;
    for (final m in _tag.allMatches(line)) {
      _addText(out, line.substring(cursor, m.start), md);
      cursor = m.end;
      final kind = m.group(1)!.toUpperCase();
      final arg = (m.group(2) ?? '').trim();
      switch (kind) {
        case 'CAM' || 'CAMERA':
          out.add(CameraTag('CAM ${arg.isEmpty ? '?' : arg}'));
        case 'PAUSE' || 'PAUSA':
          final s = _seconds.firstMatch(arg);
          out.add(PauseMark(s == null
              ? null
              : Duration(milliseconds: (double.parse(s.group(1)!.replaceAll(',', '.')) * 1000).round())));
        case 'CUE':
          final label = arg.isEmpty ? 'Cue' : arg;
          out.add(CueMark(_uniqueId('cue-${_slug(label)}', usedIds), label));
      }
    }
    _addText(out, line.substring(cursor), md);
    return out;
  }

  static void _addText(List<ScriptSpan> out, String text, bool md) {
    if (text.isEmpty) return;
    if (!md) {
      out.add(TextRun(text));
      return;
    }
    var cursor = 0;
    for (final m in _inline.allMatches(text)) {
      if (m.start > cursor) out.add(TextRun(text.substring(cursor, m.start)));
      if (m.group(1) != null) {
        out.add(TextRun(m.group(1)!, emphasis: true));
      } else {
        out.add(TextRun(m.group(2)!, highlight: true));
      }
      cursor = m.end;
    }
    if (cursor < text.length) out.add(TextRun(text.substring(cursor)));
  }

  static String _slug(String s) {
    final slug = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'section' : slug;
  }

  static String _uniqueId(String base, Set<String> used) {
    var id = base;
    for (var n = 2; !used.add(id); n++) {
      id = '$base-$n';
    }
    return id;
  }
}
