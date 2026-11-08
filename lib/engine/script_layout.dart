import 'dart:typed_data';

import 'package:flutter/painting.dart';

import '../domain/entities/prompter_settings.dart';
import '../domain/entities/script.dart';

enum MarkerKind { pause, cue, section }

/// Posición vertical (en px de contenido) de un elemento del guion.
final class LayoutMarker {
  const LayoutMarker({required this.kind, required this.y, this.duration, this.id});
  final MarkerKind kind;

  /// Coordenada Y del centro de la línea que contiene la marca.
  final double y;

  /// Solo pausas: `null` = pausa manual.
  final Duration? duration;

  /// Secciones y cues: id de destino de salto.
  final String? id;
}

final class LaidOutBlock {
  LaidOutBlock(this.painter, this.top);
  final TextPainter painter;
  final double top;
  double get bottom => top + painter.height;
}

/// Maquetación del guion para un ancho y unos ajustes concretos.
///
/// Se calcula **una sola vez** por cambio de tamaño/fuente; en cada frame el
/// pintor solo traslada el canvas y dibuja los párrafos visibles, sin volver
/// a maquetar texto. Además produce el mapa palabra ↔ píxel que usan el
/// protocolo (posición en palabras, independiente del dispositivo) y la
/// sincronización por voz.
final class ScriptLayout {
  ScriptLayout._(
    this.blocks,
    this.markers,
    this.wordOffsets,
    this.contentHeight,
    this.width,
    this._wordBlock,
    this._wordStart,
    this._wordEnd,
    this._wordLine,
  );

  // Ubicación de cada palabra leíble (índice global) para resaltarla:
  // bloque, rango de caracteres dentro de su TextPainter y centro de línea.
  final Int32List _wordBlock;
  final Int32List _wordStart;
  final Int32List _wordEnd;
  final Float64List _wordLine;
  final _boxCache = <int, List<Rect>>{};

  /// Rectángulos (en coordenadas de contenido, sin el margen lateral) que
  /// ocupa la palabra [index]. Más de uno si la palabra se parte en dos líneas.
  List<Rect> wordRects(int index) {
    if (index < 0 || index >= _wordBlock.length) return const [];
    return _boxCache.putIfAbsent(index, () {
      final b = blocks[_wordBlock[index]];
      return [
        for (final box in b.painter.getBoxesForSelection(
          TextSelection(baseOffset: _wordStart[index], extentOffset: _wordEnd[index]),
        ))
          Rect.fromLTRB(box.left, box.top + b.top, box.right, box.bottom + b.top),
      ];
    });
  }

  /// Primera palabra de la línea en la que está [index].
  int lineStartOf(int index) {
    if (index < 0 || index >= _wordLine.length) return index;
    var i = index;
    while (i > 0 && _wordLine[i - 1] == _wordLine[index]) {
      i--;
    }
    return i;
  }

  final List<LaidOutBlock> blocks;

  /// Ordenados por `y` ascendente.
  final List<LayoutMarker> markers;

  /// Desplazamiento que pone cada palabra leíble (índice global) en la línea
  /// de enfoque. **Estrictamente creciente**: dentro de una línea las palabras
  /// se reparten entre el centro de su línea y el de la siguiente, así el
  /// texto avanza de forma continua palabra a palabra y no a saltos de línea
  /// (clave para el seguimiento por voz y para el scrubbing).
  final Float64List wordOffsets;
  final double contentHeight;
  final double width;

  int get wordCount => wordOffsets.length;

  /// Desplazamiento inicial: la primera línea centrada en la línea de enfoque.
  double get minOffset => wordOffsets.isEmpty ? 0 : wordOffsets.first;

  /// Desplazamiento final: la última línea en la línea de enfoque.
  double get maxOffset => wordOffsets.isEmpty ? contentHeight : wordOffsets.last;

  /// Píxeles de contenido por palabra (promedio). Convierte WPM ↔ px/s.
  double get pxPerWord =>
      wordCount < 2 ? 1 : (maxOffset - minOffset) / (wordCount - 1);

  static ScriptLayout build(
    Script script,
    PrompterSettings s,
    double viewportWidth, {
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    final margin = viewportWidth * s.horizontalMargin;
    final width = (viewportWidth - margin * 2).clamp(80.0, double.infinity);
    final lineH = s.fontSize * s.lineHeight;

    final blocks = <LaidOutBlock>[];
    final markers = <LayoutMarker>[];
    final centers = <double>[]; // centro de la línea de cada palabra
    final lineHeights = <double>[];
    final wordBlock = <int>[], wordStart = <int>[], wordEnd = <int>[];
    // Marcas resueltas al final, cuando ya se conocen todas las posiciones:
    // (índice de la primera palabra tras la marca, constructor).
    final pendingMarkers = <(int, LayoutMarker Function(double))>[];
    var y = 0.0;

    for (final block in script.blocks) {
      final heading = block.kind == BlockKind.heading;
      final base = TextStyle(
        fontFamily: s.fontFamily,
        color: heading ? PrompterPalette.dim : s.textColor,
        fontSize: heading ? s.fontSize * 0.6 : s.fontSize,
        height: s.lineHeight,
        fontWeight: heading ? FontWeight.w700 : FontWeight.w500,
        letterSpacing: heading ? 2 : 0,
      );

      // Construye el TextSpan y anota offsets de carácter de palabras y marcas.
      final children = <InlineSpan>[];
      final wordOffsets = <int>[];
      final wordEnds = <int>[];
      final pending = <(int, LayoutMarker Function(double))>[];
      var charPos = 0;

      void push(String text, TextStyle style) {
        children.add(TextSpan(text: text, style: style));
        charPos += text.length;
      }

      if (heading) {
        pending.add((0, (yy) => LayoutMarker(kind: MarkerKind.section, y: yy, id: block.sectionId)));
      }
      for (final span in block.spans) {
        switch (span) {
          case TextRun():
            if (!heading) {
              for (final m in wordPattern.allMatches(span.text)) {
                wordOffsets.add(charPos + m.start);
                wordEnds.add(charPos + m.end);
              }
            }
            push(
              heading ? span.text.toUpperCase() : span.text,
              base.copyWith(
                fontWeight: span.emphasis ? FontWeight.w900 : null,
                color: span.emphasis ? PrompterPalette.emphasis : null,
                backgroundColor: span.highlight ? PrompterPalette.highlightBg : null,
              ),
            );
          case CameraTag(:final label):
            push(' [$label] ',
                base.copyWith(color: PrompterPalette.camera, fontSize: s.fontSize * 0.5, fontWeight: FontWeight.w800));
          case PauseMark(:final duration):
            final at = charPos;
            final secs = duration == null ? '' : ' ${(duration.inMilliseconds / 1000).toStringAsFixed(1)}s';
            push(' [PAUSE$secs] ',
                base.copyWith(color: PrompterPalette.pause, fontSize: s.fontSize * 0.5, fontWeight: FontWeight.w800));
            pending.add((at, (yy) => LayoutMarker(kind: MarkerKind.pause, y: yy, duration: duration)));
          case CueMark(:final id, :final label):
            final at = charPos;
            push(' ▸ $label ',
                base.copyWith(color: PrompterPalette.cue, fontSize: s.fontSize * 0.5, fontWeight: FontWeight.w800));
            pending.add((at, (yy) => LayoutMarker(kind: MarkerKind.cue, y: yy, id: id)));
        }
      }

      final painter = TextPainter(
        text: TextSpan(style: base, children: children),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: width);

      final firstWord = centers.length;
      for (var k = 0; k < wordOffsets.length; k++) {
        wordBlock.add(blocks.length);
        wordStart.add(wordOffsets[k]);
        wordEnd.add(wordEnds[k]);
      }
      for (final o in wordOffsets) {
        final caret = painter.getOffsetForCaret(TextPosition(offset: o), Rect.zero);
        final h = painter.getFullHeightForCaret(TextPosition(offset: o), Rect.zero);
        centers.add(y + caret.dy + h / 2);
        lineHeights.add(h);
      }
      // Una marca se activa al llegar a la primera palabra que la sigue:
      // p. ej. una pausa salta justo después de leer la palabra anterior.
      for (final (charOffset, make) in pending) {
        final before = wordOffsets.where((o) => o < charOffset).length;
        pendingMarkers.add((firstWord + before, make));
      }

      blocks.add(LaidOutBlock(painter, y));
      y += painter.height + (heading ? lineH * 0.4 : lineH * 0.6);
    }

    final offsets = _continuousOffsets(centers, lineHeights);
    for (final (index, make) in pendingMarkers) {
      markers.add(make(offsets.isEmpty ? 0 : offsets[index.clamp(0, offsets.length - 1)]));
    }
    markers.sort((a, b) => a.y.compareTo(b.y));
    return ScriptLayout._(
      blocks,
      markers,
      offsets,
      y,
      width,
      Int32List.fromList(wordBlock),
      Int32List.fromList(wordStart),
      Int32List.fromList(wordEnd),
      Float64List.fromList(centers),
    );
  }

  /// Reparte las palabras de cada línea entre el centro de su línea y el de
  /// la siguiente (o una línea más abajo si es la última).
  static Float64List _continuousOffsets(List<double> centers, List<double> lineHeights) {
    final out = Float64List(centers.length);
    var a = 0;
    while (a < centers.length) {
      var b = a;
      while (b + 1 < centers.length && centers[b + 1] == centers[a]) {
        b++;
      }
      final n = b - a + 1;
      final next = b + 1 < centers.length ? centers[b + 1] : centers[a] + lineHeights[a];
      for (var i = a; i <= b; i++) {
        out[i] = centers[a] + (next - centers[a]) * (i - a) / n;
      }
      a = b + 1;
    }
    return out;
  }

  /// Índice de palabra (fraccional) en la línea de enfoque para [offset].
  /// Es la unidad de posición del protocolo de red.
  double wordAt(double offset) {
    final c = wordOffsets;
    if (c.isEmpty) return 0;
    if (offset <= c.first) return 0;
    if (offset >= c.last) return (c.length - 1).toDouble();
    var lo = 0, hi = c.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (c[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    final next = lo + 1;
    if (next >= c.length) return lo.toDouble();
    return lo + (offset - c[lo]) / (c[next] - c[lo]);
  }

  /// Desplazamiento que pone la palabra [word] (puede ser fraccional) en foco.
  double offsetForWord(double word) {
    final c = wordOffsets;
    if (c.isEmpty) return 0;
    final w = word.clamp(0, c.length - 1).toDouble();
    final i = w.floor();
    if (i >= c.length - 1) return c.last;
    return c[i] + (c[i + 1] - c[i]) * (w - i);
  }

  double? offsetForMarker(String id) {
    for (final m in markers) {
      if (m.id == id) return m.y;
    }
    return null;
  }

  void dispose() {
    for (final b in blocks) {
      b.painter.dispose();
    }
  }
}
