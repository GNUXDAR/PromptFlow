import 'dart:convert';

/// Protocolo PromptFlow v1 (ver `docs/PROTOCOL.md`).
///
/// Sobre: `{"v":1,"type":"cmd.play","id":"c-12","ts":1731060000123,"payload":{…}}`
/// * `type`  — espacio de nombres: `hello|welcome|cmd.*|state.*|script.*|ack|error|ping|pong`.
/// * `id`    — id de correlación; las respuestas `ack`/`error` lo repiten en `re`.
/// * `ts`    — epoch ms del emisor (cálculo de RTT y extrapolación).
abstract final class PfProtocol {
  static const version = 1;
  static const defaultWsPort = 47820;
  static const discoveryPort = 47821;
  static const wsPath = '/pf/v1';
  static const discoveryProbe = 'PROMPTFLOW_DISCOVER_V1';
}

final class PfMessage {
  PfMessage(this.type, {Map<String, Object?>? payload, String? id, int? ts})
      : payload = payload ?? const {},
        id = id ?? _nextId(),
        ts = ts ?? DateTime.now().millisecondsSinceEpoch;

  final String type;
  final String id;
  final int ts;
  final Map<String, Object?> payload;

  static int _seq = 0;
  static String _nextId() => 'm${++_seq}';

  String encode() => jsonEncode({'v': PfProtocol.version, 'type': type, 'id': id, 'ts': ts, 'payload': payload});

  /// Lanza [FormatException] si el mensaje es inválido o de otra versión.
  static PfMessage decode(Object? raw) {
    if (raw is! String || raw.length > 512 * 1024) throw const FormatException('frame inválido');
    final j = jsonDecode(raw);
    if (j is! Map<String, Object?>) throw const FormatException('se esperaba un objeto');
    if (j['v'] != PfProtocol.version) throw FormatException('versión no soportada: ${j['v']}');
    final type = j['type'];
    if (type is! String) throw const FormatException('falta type');
    final payload = j['payload'];
    return PfMessage(
      type,
      id: j['id'] is String ? j['id'] as String : null,
      ts: j['ts'] is int ? j['ts'] as int : null,
      payload: payload is Map<String, Object?> ? payload : const {},
    );
  }
}

/// Comandos de control. Son la misma unidad para teclado, pedal, mando
/// remoto y voz: todas las entradas acaban en `PrompterController.execute`.
sealed class PrompterCommand {
  const PrompterCommand();

  String get type;
  Map<String, Object?> get payload => const {};

  PfMessage toMessage() => PfMessage(type, payload: payload);

  /// `null` si [m] no es un comando conocido o su payload es inválido.
  static PrompterCommand? fromMessage(PfMessage m) {
    final p = m.payload;
    double? number(String k) => p[k] is num ? (p[k] as num).toDouble() : null;
    String? str(String k) => p[k] is String ? p[k] as String : null;
    bool? boolean(String k) => p[k] is bool ? p[k] as bool : null;

    return switch (m.type) {
      'cmd.play' => const PlayCommand(),
      'cmd.pause' => const PauseCommand(),
      'cmd.toggle' => const ToggleCommand(),
      'cmd.seek' => number('seconds') == null ? null : SeekCommand(number('seconds')!),
      'cmd.speed.set' => number('wpm') == null ? null : SetSpeedCommand(number('wpm')!),
      'cmd.speed.nudge' => number('delta') == null ? null : NudgeSpeedCommand(number('delta')!),
      'cmd.jump' => str('target') == null ? null : JumpCommand(str('target')!),
      'cmd.goto' => number('word') == null ? null : GotoWordCommand(number('word')!),
      'cmd.mirror' => MirrorCommand(horizontal: boolean('horizontal'), vertical: boolean('vertical')),
      'cmd.mirror.toggle' => switch (str('axis')) {
          'horizontal' => const ToggleMirrorCommand(MirrorAxis.horizontal),
          'vertical' => const ToggleMirrorCommand(MirrorAxis.vertical),
          _ => null,
        },
      'cmd.font.nudge' => number('delta') == null ? null : FontNudgeCommand(number('delta')!),
      'cmd.script.load' => str('scriptId') == null ? null : LoadScriptCommand(str('scriptId')!),
      'cmd.voice' => boolean('enabled') == null ? null : VoiceSyncCommand(boolean('enabled')!),
      _ => null,
    };
  }
}

final class PlayCommand extends PrompterCommand {
  const PlayCommand();
  @override
  String get type => 'cmd.play';
}

final class PauseCommand extends PrompterCommand {
  const PauseCommand();
  @override
  String get type => 'cmd.pause';
}

final class ToggleCommand extends PrompterCommand {
  const ToggleCommand();
  @override
  String get type => 'cmd.toggle';
}

/// Rewind (negativo) / Forward (positivo) en segundos de lectura.
final class SeekCommand extends PrompterCommand {
  const SeekCommand(this.seconds);
  final double seconds;
  @override
  String get type => 'cmd.seek';
  @override
  Map<String, Object?> get payload => {'seconds': seconds};
}

final class SetSpeedCommand extends PrompterCommand {
  const SetSpeedCommand(this.wpm);
  final double wpm;
  @override
  String get type => 'cmd.speed.set';
  @override
  Map<String, Object?> get payload => {'wpm': wpm};
}

final class NudgeSpeedCommand extends PrompterCommand {
  const NudgeSpeedCommand(this.delta);
  final double delta;
  @override
  String get type => 'cmd.speed.nudge';
  @override
  Map<String, Object?> get payload => {'delta': delta};
}

/// Salta a una sección o cue por id.
final class JumpCommand extends PrompterCommand {
  const JumpCommand(this.target);
  final String target;
  @override
  String get type => 'cmd.jump';
  @override
  Map<String, Object?> get payload => {'target': target};
}

/// Posiciona en un índice de palabra absoluto (scrubbing desde el mando).
final class GotoWordCommand extends PrompterCommand {
  const GotoWordCommand(this.word);
  final double word;
  @override
  String get type => 'cmd.goto';
  @override
  Map<String, Object?> get payload => {'word': word};
}

final class MirrorCommand extends PrompterCommand {
  const MirrorCommand({this.horizontal, this.vertical});
  final bool? horizontal;
  final bool? vertical;
  @override
  String get type => 'cmd.mirror';
  @override
  Map<String, Object?> get payload => {
        if (horizontal != null) 'horizontal': horizontal,
        if (vertical != null) 'vertical': vertical,
      };
}

enum MirrorAxis { horizontal, vertical }

final class ToggleMirrorCommand extends PrompterCommand {
  const ToggleMirrorCommand(this.axis);
  final MirrorAxis axis;
  @override
  String get type => 'cmd.mirror.toggle';
  @override
  Map<String, Object?> get payload => {'axis': axis.name};
}

final class FontNudgeCommand extends PrompterCommand {
  const FontNudgeCommand(this.delta);
  final double delta;
  @override
  String get type => 'cmd.font.nudge';
  @override
  Map<String, Object?> get payload => {'delta': delta};
}

final class LoadScriptCommand extends PrompterCommand {
  const LoadScriptCommand(this.scriptId);
  final String scriptId;
  @override
  String get type => 'cmd.script.load';
  @override
  Map<String, Object?> get payload => {'scriptId': scriptId};
}

final class VoiceSyncCommand extends PrompterCommand {
  const VoiceSyncCommand(this.enabled);
  final bool enabled;
  @override
  String get type => 'cmd.voice';
  @override
  Map<String, Object?> get payload => {'enabled': enabled};
}

/// Estado publicado por el servidor (`state.snapshot`, ~10 Hz en reproducción).
/// La posición viaja en **palabras**, no en píxeles: cada dispositivo la
/// proyecta sobre su propia maquetación.
final class PrompterSnapshot {
  const PrompterSnapshot({
    required this.rev,
    required this.status,
    required this.word,
    required this.wordCount,
    required this.wpm,
    required this.remainingMs,
    required this.progress,
    required this.scriptId,
    required this.scriptTitle,
    required this.sectionId,
    required this.mirrorH,
    required this.mirrorV,
    required this.voice,
    required this.ts,
  });

  final int rev;
  final String status;
  final double word;
  final int wordCount;
  final double wpm;
  final int remainingMs;
  final double progress;
  final String? scriptId;
  final String? scriptTitle;
  final String? sectionId;
  final bool mirrorH;
  final bool mirrorV;
  final bool voice;
  final int ts;

  bool get playing => status == 'playing' || status == 'autoPaused';

  /// Extrapolación (dead reckoning) para que el mando muestre un progreso
  /// fluido entre snapshots sin inundar la red.
  double wordAt(DateTime now) =>
      status == 'playing' ? word + wpm / 60000 * (now.millisecondsSinceEpoch - ts) : word;

  Map<String, Object?> toJson() => {
        'rev': rev,
        'status': status,
        'word': double.parse(word.toStringAsFixed(2)),
        'wordCount': wordCount,
        'wpm': wpm,
        'remainingMs': remainingMs,
        'progress': double.parse(progress.toStringAsFixed(4)),
        'scriptId': scriptId,
        'scriptTitle': scriptTitle,
        'sectionId': sectionId,
        'mirror': {'horizontal': mirrorH, 'vertical': mirrorV},
        'voice': voice,
      };

  /// [receivedAt] (reloj local) sustituye al `ts` del servidor para que la
  /// extrapolación no dependa de que ambos relojes estén sincronizados.
  static PrompterSnapshot fromMessage(PfMessage m, {DateTime? receivedAt}) {
    final p = m.payload;
    final mirror = p['mirror'] is Map ? p['mirror'] as Map : const {};
    double d(String k) => (p[k] as num?)?.toDouble() ?? 0;
    return PrompterSnapshot(
      rev: (p['rev'] as num?)?.toInt() ?? 0,
      status: p['status'] as String? ?? 'stopped',
      word: d('word'),
      wordCount: (p['wordCount'] as num?)?.toInt() ?? 0,
      wpm: d('wpm'),
      remainingMs: (p['remainingMs'] as num?)?.toInt() ?? 0,
      progress: d('progress'),
      scriptId: p['scriptId'] as String?,
      scriptTitle: p['scriptTitle'] as String?,
      sectionId: p['sectionId'] as String?,
      mirrorH: mirror['horizontal'] == true,
      mirrorV: mirror['vertical'] == true,
      voice: p['voice'] == true,
      ts: receivedAt?.millisecondsSinceEpoch ?? m.ts,
    );
  }
}
