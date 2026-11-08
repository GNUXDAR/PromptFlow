import 'package:flutter/rendering.dart';

import '../domain/entities/prompter_settings.dart';
import 'script_layout.dart';
import 'scroll_engine.dart';

/// Pinta la capa de texto. Se registra con `repaint: engine`, por lo que en
/// cada tick solo se repinta esta capa (dentro de un `RepaintBoundary`):
/// no hay `build()` ni re-maquetación por frame.
class PrompterPainter extends CustomPainter {
  PrompterPainter({
    required this.engine,
    required this.settings,
    required this.devicePixelRatio,
  }) : super(repaint: engine);

  final ScrollEngine engine;
  final PrompterSettings settings;
  final double devicePixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = PrompterPalette.background);
    final layout = engine.layout;
    if (layout == null) return;

    canvas.save();

    // Mirroring: una transformación afín del canvas. Coste por frame nulo y
    // el texto se rasteriza ya invertido (sin texturas intermedias).
    if (settings.mirrorHorizontal) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    if (settings.mirrorVertical) {
      canvas
        ..translate(0, size.height)
        ..scale(1, -1);
    }

    final focusY = size.height * settings.focusLine;
    // Ajuste a píxel físico: evita el "shimmer" del texto al desplazarse
    // con offsets subpíxel distintos en cada frame.
    final dpr = devicePixelRatio <= 0 ? 1.0 : devicePixelRatio;
    final snapped = (engine.offset * dpr).roundToDouble() / dpr;
    final dy = focusY - snapped;
    final left = (size.width - layout.width) / 2;

    final spoken = settings.highlightSpoken ? engine.spokenWord : null;
    final origin = Offset(left, dy);
    if (spoken != null) _paintSpokenBackground(canvas, layout, spoken, origin);

    // Solo los bloques visibles (culling): O(visibles), no O(guion).
    final viewTop = -dy, viewBottom = size.height - dy;
    for (final b in layout.blocks) {
      if (b.bottom < viewTop) continue;
      if (b.top > viewBottom) break;
      b.painter.paint(canvas, Offset(left, b.top + dy));
    }

    if (spoken != null) _paintSpokenUnderline(canvas, layout, spoken, origin);

    if (settings.showFocusGuide) {
      final lineH = settings.fontSize * settings.lineHeight;
      // Atenúa lo ya leído para guiar la vista hacia la línea de enfoque.
      final fadeRect = Rect.fromLTRB(0, 0, size.width, focusY - lineH / 2);
      if (fadeRect.height > 0) {
        canvas.drawRect(
          fadeRect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xE6000000), const Color(0x66000000)],
            ).createShader(fadeRect),
        );
      }
      final guide = Paint()..color = PrompterPalette.focusGuide;
      canvas.drawRect(Rect.fromLTWH(0, focusY - lineH / 2, size.width, 2), guide);
      canvas.drawRect(Rect.fromLTWH(0, focusY + lineH / 2, size.width, 2), guide);
      final arrow = Paint()..color = PrompterPalette.yellow;
      canvas.drawPath(
        Path()
          ..moveTo(4, focusY - 14)
          ..lineTo(26, focusY)
          ..lineTo(4, focusY + 14)
          ..close(),
        arrow,
      );
    }

    canvas.restore();
  }

  /// Fondo translúcido bajo la palabra que se acaba de decir.
  void _paintSpokenBackground(Canvas canvas, ScriptLayout layout, int word, Offset origin) {
    final f = settings.fontSize;
    final paint = Paint()..color = PrompterPalette.spoken.withValues(alpha: 0.20);
    for (final r in layout.wordRects(word)) {
      final rect = _glyphBand(r.shift(origin)).inflate(f * 0.08);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(f * 0.16)), paint);
    }
  }

  /// Subrayado con brillo de lo leído en la línea actual, hasta la palabra dicha.
  void _paintSpokenUnderline(Canvas canvas, ScriptLayout layout, int word, Offset origin) {
    final f = settings.fontSize;
    // Une los rectángulos por línea: un trazo continuo por renglón.
    final spans = <double, (double, double)>{};
    for (var i = layout.lineStartOf(word); i <= word; i++) {
      for (final raw in layout.wordRects(i)) {
        final r = raw.shift(origin);
        final y = _glyphBand(r).bottom + f * 0.06;
        final cur = spans[y];
        spans[y] = cur == null ? (r.left, r.right) : (cur.$1 < r.left ? cur.$1 : r.left, cur.$2 > r.right ? cur.$2 : r.right);
      }
    }
    final glow = Paint()
      ..color = PrompterPalette.spoken.withValues(alpha: 0.65)
      ..strokeWidth = f * 0.10
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, f * 0.12);
    final line = Paint()
      ..color = PrompterPalette.spoken
      ..strokeWidth = f * 0.06
      ..strokeCap = StrokeCap.round;
    for (final MapEntry(key: y, value: (x0, x1)) in spans.entries) {
      canvas.drawLine(Offset(x0, y), Offset(x1, y), glow);
      canvas.drawLine(Offset(x0, y), Offset(x1, y), line);
    }
  }

  /// Banda vertical que ocupan los glifos dentro de la caja de línea (la caja
  /// incluye el interlineado; los glifos van centrados en ella).
  Rect _glyphBand(Rect lineBox) {
    final f = settings.fontSize;
    final c = lineBox.center.dy;
    return Rect.fromLTRB(lineBox.left, c - f * 0.58, lineBox.right, c + f * 0.52);
  }

  @override
  bool shouldRepaint(PrompterPainter old) =>
      old.settings != settings || old.engine != engine || old.devicePixelRatio != devicePixelRatio;
}
