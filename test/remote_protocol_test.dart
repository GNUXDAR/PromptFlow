import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/remote/client/remote_client.dart';
import 'package:promptflow/remote/protocol/messages.dart';
import 'package:promptflow/remote/server/remote_server.dart';

class FakeHost implements RemoteHost {
  final commands = <PrompterCommand>[];
  int rev = 0;
  bool playing = false;

  @override
  Map<String, Object?> catalog() => {
        'scripts': [
          {'id': 'a.md', 'title': 'A'},
        ],
        'sections': [
          {'id': 'intro', 'title': 'Intro'},
        ],
      };

  @override
  void execute(PrompterCommand c) {
    commands.add(c);
    if (c is ToggleCommand) playing = !playing;
    rev++;
  }

  @override
  PrompterSnapshot snapshot() => PrompterSnapshot(
        rev: rev,
        status: playing ? 'playing' : 'stopped',
        word: 10,
        wordCount: 100,
        wpm: 150,
        remainingMs: 36000,
        progress: 0.1,
        scriptId: 'a.md',
        scriptTitle: 'A',
        sectionId: 'intro',
        mirrorH: false,
        mirrorV: false,
        voice: false,
        ts: DateTime.now().millisecondsSinceEpoch,
      );
}

Future<void> until(bool Function() cond, {Duration timeout = const Duration(seconds: 3)}) async {
  final end = DateTime.now().add(timeout);
  while (!cond()) {
    if (DateTime.now().isAfter(end)) throw TimeoutException('condición no cumplida');
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  test('round-trip de todos los comandos por JSON', () {
    const cmds = <PrompterCommand>[
      PlayCommand(),
      PauseCommand(),
      ToggleCommand(),
      SeekCommand(-5),
      SetSpeedCommand(160),
      NudgeSpeedCommand(10),
      JumpCommand('apertura'),
      GotoWordCommand(42),
      MirrorCommand(horizontal: true),
      ToggleMirrorCommand(MirrorAxis.vertical),
      FontNudgeCommand(4),
      LoadScriptCommand('a.md'),
      VoiceSyncCommand(true),
    ];
    for (final c in cmds) {
      final back = PrompterCommand.fromMessage(PfMessage.decode(c.toMessage().encode()));
      expect(back?.type, c.type);
      expect(back?.payload, c.payload);
    }
    expect(() => PfMessage.decode('{"v":2,"type":"cmd.play"}'), throwsFormatException);
    expect(PrompterCommand.fromMessage(PfMessage('cmd.seek', payload: {'seconds': 'x'})), isNull);
  });

  test('servidor y cliente reales: PIN, welcome, comando, ack y snapshot', () async {
    final host = FakeHost();
    final server = RemoteServer(host: host, pin: '1234');
    await server.start(port: 0);
    addTearDown(server.stop);

    final bad = RemoteClient(deviceName: 'test-bad');
    expect(await bad.connect('127.0.0.1', port: server.port!, pin: '9999'), isFalse);
    await until(() => bad.status == ConnectionStatus.failed);
    expect(bad.lastError, 'bad_pin');
    bad.dispose();

    final client = RemoteClient(deviceName: 'test');
    addTearDown(client.dispose);
    expect(await client.connect('127.0.0.1', port: server.port!, pin: '1234'), isTrue);
    expect(client.sections.single['id'], 'intro');
    expect(client.snapshot?.wpm, 150);

    client.send(const ToggleCommand());
    await until(() => host.commands.isNotEmpty);
    expect(host.commands.single, isA<ToggleCommand>());
    await until(() => client.snapshot?.playing == true);

    // Extrapolación: a 150 WPM avanza 2.5 palabras/s.
    final s = client.snapshot!;
    final later = DateTime.fromMillisecondsSinceEpoch(s.ts + 2000);
    expect(s.wordAt(later), closeTo(s.word + 5, 0.01));
  });
}
