import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/data/parsing/script_parser.dart';
import 'package:promptflow/domain/entities/prompter_settings.dart';
import 'package:promptflow/engine/script_layout.dart';
import 'package:promptflow/engine/scroll_engine.dart';

String words(int n, [String w = 'palabra']) => List.filled(n, w).join(' ');

ScrollEngine engineFor(String source, {double wpm = 120}) {
  final script = ScriptParser.parse(source, id: 't');
  final layout = ScriptLayout.build(script, const PrompterSettings(fontSize: 32), 800);
  return ScrollEngine.manual()
    ..setLayout(layout)
    ..setWpm(wpm);
}

/// Avanza [seconds] con frames de [fps] (con jitter opcional).
void run(ScrollEngine e, double seconds, {double fps = 60, bool jitter = false}) {
  final frame = 1 / fps;
  var t = 0.0, i = 0;
  while (t < seconds - 1e-9) {
    var dt = jitter ? frame * ((i++).isEven ? 0.5 : 1.5) : frame;
    if (t + dt > seconds) dt = seconds - t;
    e.advance(Duration(microseconds: (dt * 1e6).round()));
    t += dt;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('avanza a los WPM objetivo una vez pasada la rampa', () {
    final e = engineFor(words(2000), wpm: 120)..play();
    run(e, 2); // rampa (tau = 0.22 s)
    final w0 = e.wordPosition;
    run(e, 10);
    // 120 WPM = 2 palabras/s → 20 palabras en 10 s (±5 % por la media px/palabra).
    expect(e.wordPosition - w0, closeTo(20, 1));
  });

  test('independiente del frame-rate: 30 Hz, 60 Hz, 120 Hz y jitter coinciden', () {
    double offsetAt(double fps, {bool jitter = false}) {
      final e = engineFor(words(2000))..play();
      run(e, 3, fps: fps, jitter: jitter);
      return e.offset;
    }

    final ref = offsetAt(60);
    expect(offsetAt(30), closeTo(ref, 0.5));
    expect(offsetAt(120), closeTo(ref, 0.5));
    expect(offsetAt(60, jitter: true), closeTo(ref, 0.5));
  });

  test('un frame enorme (app suspendida) se acota a maxFrameDelta', () {
    final e = engineFor(words(2000))..play();
    run(e, 2);
    final before = e.offset;
    final vMax = e.velocity;
    // advance() no acota (lo hace _onTick); simulamos el acotado del ticker:
    e.advance(ScrollEngine.maxFrameDelta);
    expect(e.offset - before, lessThanOrEqualTo(vMax * 0.25 + 1));
  });

  test('pausa automática: se detiene sobre la marca y reanuda sola', () {
    final e = engineFor('${words(20)} [PAUSE 1s] ${words(200)}', wpm: 300)..play();
    run(e, 10);
    // Con 300 WPM las 20 primeras palabras tardan ~4 s; la pausa ya pasó.
    expect(e.status, PlaybackStatus.playing);

    final e2 = engineFor('${words(20)} [PAUSE 1s] ${words(200)}', wpm: 300)..play();
    var paused = false;
    for (var i = 0; i < 60 * 8 && !paused; i++) {
      e2.advance(const Duration(microseconds: 16667));
      paused = e2.status == PlaybackStatus.autoPaused;
    }
    expect(paused, isTrue);
    final at = e2.offset;
    run(e2, 0.9);
    expect(e2.offset, at, reason: 'quieto durante la pausa');
    run(e2, 0.3);
    expect(e2.status, PlaybackStatus.playing);
  });

  test('pausa manual [PAUSE]: queda en holding hasta play()', () {
    final e = engineFor('${words(10)} [PAUSE] ${words(100)}', wpm: 300)..play();
    run(e, 6);
    expect(e.status, PlaybackStatus.holding);
    final at = e.offset;
    run(e, 2);
    expect(e.offset, at);
    e.toggle();
    run(e, 2);
    expect(e.offset, greaterThan(at));
  });

  test('rewind 5 s se anima y converge al objetivo', () {
    final e = engineFor(words(2000), wpm: 120)..play();
    run(e, 12);
    e.pause();
    run(e, 2); // frena
    final w = e.wordPosition;
    e.seekSeconds(-5); // 10 palabras atrás
    e.advance(const Duration(milliseconds: 16));
    expect(e.wordPosition, greaterThan(w - 10), reason: 'no salta de golpe');
    run(e, 1.5);
    expect(e.wordPosition, closeTo(w - 10, 1.0));
  });

  test('tiempo restante decrece y llega a 0 al final', () {
    final e = engineFor(words(60), wpm: 600)..play();
    final r0 = e.remaining;
    run(e, 1);
    expect(e.remaining, lessThan(r0));
    run(e, 30);
    expect(e.status, PlaybackStatus.finished);
    expect(e.remaining, Duration.zero);
  });

  test('cambio de maquetación conserva la palabra en foco', () {
    final script = ScriptParser.parse(words(1000), id: 't');
    final e = ScrollEngine.manual()
      ..setLayout(ScriptLayout.build(script, const PrompterSettings(fontSize: 32), 800))
      ..setWpm(200)
      ..play();
    run(e, 20);
    final w = e.wordPosition;
    e.setLayout(ScriptLayout.build(script, const PrompterSettings(fontSize: 64), 800));
    expect(e.wordPosition, closeTo(w, 8), reason: 'misma línea aproximada');
  });

  test('modo voz: lectura continua sin retrocesos y con poco retardo', () {
    final e = engineFor(words(1000))..setMode(ScrollMode.voiceFollow);
    // El orador dice ~2.5 palabras/s; el STT entrega parciales cada 0.4 s.
    var word = 0.0, prev = e.offset;
    for (var step = 0; step < 40; step++) {
      word += 1;
      e.followWord(word);
      for (var f = 0; f < 24; f++) {
        e.advance(const Duration(microseconds: 16667));
        expect(e.offset, greaterThanOrEqualTo(prev - 0.01), reason: 'nunca retrocede');
        prev = e.offset;
      }
    }
    final lagWords = word - e.wordPosition;
    expect(lagWords, lessThan(2.5), reason: 'feed-forward: retardo < 1 s de habla');
  });

  test('modo voz persigue la palabra objetivo sin saltos', () {
    final e = engineFor(words(1000))..setMode(ScrollMode.voiceFollow);
    final target = e.layout!.offsetForWord(100);
    e.followWord(100);
    e.advance(const Duration(milliseconds: 16));
    expect(e.offset, lessThan(target));
    run(e, 6);
    expect(e.offset, closeTo(target, 2));
  });
}
