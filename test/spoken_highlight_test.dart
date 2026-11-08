import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/data/parsing/script_parser.dart';
import 'package:promptflow/domain/entities/prompter_settings.dart';
import 'package:promptflow/engine/prompter_painter.dart';
import 'package:promptflow/engine/script_layout.dart';
import 'package:promptflow/engine/scroll_engine.dart';

/// Resaltado de la palabra dicha (modo voz). Con PROMPTFLOW_RENDER_DIR
/// además guarda un PNG con fuente real para revisarlo a ojo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const text = 'Hoy vamos a hablar de cómo funciona el teleprompter con la voz. '
      'Cuando lees, el texto avanza solo y nadie tiene que tocar la pantalla.';

  setUpAll(() async {
    // Fuente real (en los tests Flutter usa una fuente de cajas).
    final dir = '${Platform.environment['HOME']}/fvm/default/bin/cache/artifacts/material_fonts';
    for (final file in ['Roboto-Medium.ttf', 'Roboto-Black.ttf']) {
      final f = File('$dir/$file');
      if (f.existsSync()) {
        await (FontLoader('Roboto')..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())))).load();
      }
    }
  });

  ScrollEngine engineAt(int spoken, PrompterSettings s) {
    final layout = ScriptLayout.build(ScriptParser.parse(text, id: 't'), s, 900);
    return ScrollEngine.manual()
      ..setLayout(layout)
      ..setMode(ScrollMode.voiceFollow)
      ..followWord(spoken.toDouble());
  }

  test('expone la palabra dicha solo en modo voz', () {
    const s = PrompterSettings(fontSize: 56);
    final e = engineAt(6, s);
    expect(e.spokenWord, 6);
    e.setMode(ScrollMode.timed);
    expect(e.spokenWord, isNull);
  });

  test('cada palabra tiene su rectángulo y su inicio de línea', () {
    const s = PrompterSettings(fontSize: 56);
    final l = ScriptLayout.build(ScriptParser.parse(text, id: 't'), s, 900);
    for (var i = 0; i < l.wordCount; i++) {
      expect(l.wordRects(i), isNotEmpty, reason: 'palabra $i');
      expect(l.lineStartOf(i), lessThanOrEqualTo(i));
    }
    expect(l.lineStartOf(0), 0);
  });

  for (final mirror in [false, true]) {
    test('pinta el resaltado sin errores${mirror ? ' (espejo horizontal)' : ''}', () async {
      final s = PrompterSettings(fontSize: 56, mirrorHorizontal: mirror, fontFamily: 'Roboto');
      final engine = engineAt(8, s); // «teleprompter», a mitad de línea
      for (var i = 0; i < 180; i++) {
        engine.advance(const Duration(milliseconds: 16)); // el texto llega a la palabra
      }
      const size = Size(900, 700);
      final recorder = ui.PictureRecorder();
      PrompterPainter(engine: engine, settings: s, devicePixelRatio: 1)
          .paint(ui.Canvas(recorder), size);
      final image = await recorder.endRecording().toImage(900, 700);
      final out = Platform.environment['PROMPTFLOW_RENDER_DIR'];
      if (out != null) {
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$out/spoken_${mirror ? 'mirror' : 'normal'}.png').writeAsBytesSync(png!.buffer.asUint8List());
      }
    });
  }
}
