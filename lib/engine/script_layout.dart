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
  ScriptLayout._(this.blocks, this.markers, this.wordCenters, this.contentHeight, this.width);

  final List<LaidOutBlock> blocks;

  /// Ordenados por `y` ascendente.
  final List<LayoutMarker> markers;

  /// Centro vertical de la línea de cada palabra leíble (índice global).
  final Float64List wordCenters;
  final double contentHeight;
  final double width;

  int get wordCount => wordCenters.length;

  /// Desplazamiento inicial: la primera línea centrada en la línea de enfoque.
  double get minOffset => wordCenters.isEmpty ? 0 : wordCenters.first;

  /// Desplazamiento final: la última línea en la línea de enfoque.
  double get maxOffset => wordCenters.isEmpty ? contentHeight : wordCenters.last;

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
    final centers = <double>[];
    var y = 0.0;

    for (final block in script.blocks) {
      final heading = block.kind == BlockKind.heading;
      final base = TextStyle(
        color: heading ? PrompterPalette.dim : s.textColor,
        fontSize: heading ? s.fontSize * 0.6 : s.fontSize,
        height: s.lineHeight,
        fontWeight: heading ? FontWeight.w700 : FontWeight.w500,
        letterSpacing: heading ? 2 : 0,
      );

      // Construye el TextSpan y anota offsets de carácter de palabras y marcas.
      final children = <InlineSpan>[];
      final wordOffsets = <int>[];
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
            push(' [PAUSA$secs] ',
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

      double centerAt(int offset) {
        final caret = painter.getOffsetForCaret(TextPosition(offset: offset), Rect.zero);
        final h = painter.getFullHeightForCaret(TextPosition(offset: offset), Rect.zero);
        return y + caret.dy + h / 2;
      }

      for (final o in wordOffsets) {
        centers.add(centerAt(o));
      }
      for (final (offset, make) in pending) {
        markers.add(make(centerAt(offset)));
      }

      blocks.add(LaidOutBlock(painter, y));
      y += painter.height + (heading ? lineH * 0.4 : lineH * 0.6);
    }

    markers.sort((a, b) => a.y.compareTo(b.y));
    return ScriptLayout._(blocks, markers, Float64List.fromList(centers), y, width);
  }

  /// Índice de palabra (fraccional) en la línea de enfoque para [offset].
  /// Es la unidad de posición del protocolo de red.
  double wordAt(double offset) {
    final c = wordCenters;
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
    // Palabras de la misma línea comparten centro: avanza hasta la última
    // con ese centro e interpola hacia la siguiente línea.
    final next = lo + 1;
    if (next >= c.length || c[next] == c[lo]) return lo.toDouble();
    return lo + (offset - c[lo]) / (c[next] - c[lo]);
  }

  /// Desplazamiento que pone la palabra [word] (puede ser fraccional) en foco.
  double offsetForWord(double word) {
    final c = wordCenters;
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
