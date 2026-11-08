import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/script_repository.dart';
import '../../domain/entities/prompter_settings.dart';
import '../../domain/entities/script.dart';
import '../../domain/services/wpm_estimator.dart';
import '../../engine/prompter_painter.dart';
import '../../engine/scroll_engine.dart';
import '../../input/pedal_shortcuts.dart';
import '../../remote/protocol/messages.dart';
import '../../remote/server/remote_server.dart';
import '../controllers/prompter_controller.dart';

/// Vista de lectura a pantalla completa. Hospeda el servidor de control
/// remoto mientras está abierta (Linux o Android en modo prompter).
class PrompterScreen extends StatefulWidget {
  const PrompterScreen({super.key, required this.repository, required this.script});
  final ScriptRepository repository;
  final Script script;

  @override
  State<PrompterScreen> createState() => _PrompterScreenState();
}

class _PrompterScreenState extends State<PrompterScreen> with SingleTickerProviderStateMixin {
  late final PrompterController _c =
      PrompterController(vsync: this, repository: widget.repository, script: widget.script);
  late final Future<List<String>> _ips = RemoteServer.lanAddresses();
  bool _hud = true;
  Timer? _hudTimer;

  @override
  void initState() {
    super.initState();
    _c.startServer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _pokeHud();
  }

  @override
  void dispose() {
    _hudTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _c.dispose();
    super.dispose();
  }

  /// Muestra el HUD y lo oculta tras 3 s si se está reproduciendo.
  void _pokeHud() {
    _hudTimer?.cancel();
    if (!_hud) setState(() => _hud = true);
    _hudTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _c.engine.isPlaying) setState(() => _hud = false);
    });
  }

  void _command(PrompterCommand cmd) {
    _c.execute(cmd);
    _pokeHud();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final scaler = MediaQuery.textScalerOf(context);

    return PrompterShortcuts(
      onCommand: _command,
      extra: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).maybePop(),
        const SingleActivator(LogicalKeyboardKey.keyS): _openSettings,
      },
      child: Scaffold(
        backgroundColor: PrompterPalette.background,
        body: MouseRegion(
          onHover: (_) => _pokeHud(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              LayoutBuilder(builder: (context, box) {
                return ListenableBuilder(
                  listenable: _c,
                  builder: (context, _) {
                    _c.ensureLayout(box.biggest, scaler);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pokeHud,
                      onDoubleTap: () => _command(const ToggleCommand()),
                      onVerticalDragUpdate: (d) {
                        final sign = _c.settings.mirrorVertical ? 1 : -1;
                        _c.engine.seekToOffset(_c.engine.offset + d.delta.dy * sign, animate: false);
                      },
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: box.biggest,
                          isComplex: true,
                          painter: PrompterPainter(engine: _c.engine, settings: _c.settings, devicePixelRatio: dpr),
                        ),
                      ),
                    );
                  },
                );
              }),
              IgnorePointer(
                ignoring: !_hud,
                child: AnimatedOpacity(
                  opacity: _hud ? 1 : 0,
                  duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 250),
                  child: _Hud(controller: _c, ips: _ips, onCommand: _command, onSettings: _openSettings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSettings() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xF2111111),
        builder: (_) => _SettingsSheet(controller: _c),
      );
}

class _Hud extends StatefulWidget {
  const _Hud({required this.controller, required this.ips, required this.onCommand, required this.onSettings});
  final PrompterController controller;
  final Future<List<String>> ips;
  final void Function(PrompterCommand) onCommand;
  final VoidCallback onSettings;

  @override
  State<_Hud> createState() => _HudState();
}

class _HudState extends State<_Hud> {
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // El HUD se refresca a 4 Hz, no por frame: el scroll no reconstruye widgets.
    _clock = Timer.periodic(const Duration(milliseconds: 250), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final e = c.engine;
    final t = Theme.of(context).textTheme;
    final status = switch (e.status) {
      PlaybackStatus.playing => 'Reproduciendo',
      PlaybackStatus.autoPaused => 'Pausa ${((e.autoPauseLeft?.inMilliseconds ?? 0) / 1000).toStringAsFixed(1)} s',
      PlaybackStatus.holding => 'Pausa — pulsa Play',
      PlaybackStatus.finished => 'Fin',
      PlaybackStatus.stopped => 'Detenido',
    };

    return Column(
      children: [
        Container(
          color: const Color(0xCC000000),
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: SafeArea(
            bottom: false,
            child: Row(children: [
              IconButton(
                tooltip: 'Salir (Esc)',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(c.script.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleMedium),
              ),
              FutureBuilder<List<String>>(
                future: widget.ips,
                builder: (context, snap) {
                  final server = c.server;
                  final text = c.serverError ??
                      (server.running
                          ? '${(snap.data ?? const []).take(1).join()}:${server.port}  PIN ${server.pin}  '
                              '· ${server.clientCount} mando(s)'
                          : 'Servidor detenido');
                  return Text(text, style: t.bodySmall?.copyWith(color: PrompterPalette.dim));
                },
              ),
            ]),
          ),
        ),
        LinearProgressIndicator(value: e.progress, minHeight: 3, color: PrompterPalette.yellow),
        const Spacer(),
        Container(
          color: const Color(0xCC000000),
          padding: const EdgeInsets.all(8),
          child: SafeArea(
            top: false,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                IconButton(
                  tooltip: 'Atrás 5 s (Re Pág)',
                  onPressed: () => widget.onCommand(const SeekCommand(-5)),
                  icon: const Icon(Icons.replay_5),
                ),
                IconButton.filled(
                  tooltip: e.isPlaying ? 'Pausa (Espacio)' : 'Reproducir (Espacio)',
                  iconSize: 36,
                  onPressed: () => widget.onCommand(const ToggleCommand()),
                  icon: Icon(e.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  tooltip: 'Adelante 5 s (Av Pág)',
                  onPressed: () => widget.onCommand(const SeekCommand(5)),
                  icon: const Icon(Icons.forward_5),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Más lento (↓)',
                  onPressed: () => widget.onCommand(const NudgeSpeedCommand(-10)),
                  icon: const Icon(Icons.remove),
                ),
                Text('${e.wpm.round()} WPM', style: t.titleMedium),
                IconButton(
                  tooltip: 'Más rápido (↑)',
                  onPressed: () => widget.onCommand(const NudgeSpeedCommand(10)),
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 12),
                Text('$status · quedan ${formatDuration(e.remaining)}', style: t.bodyMedium),
                if (c.voiceAvailable)
                  IconButton(
                    tooltip: c.voiceActive ? 'Desactivar seguimiento por voz' : 'Seguir mi voz',
                    isSelected: c.voiceActive,
                    onPressed: () => widget.onCommand(VoiceSyncCommand(!c.voiceActive)),
                    icon: const Icon(Icons.mic_none),
                    selectedIcon: const Icon(Icons.mic),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Ir a sección',
                  icon: const Icon(Icons.bookmarks_outlined),
                  onSelected: (id) => widget.onCommand(JumpCommand(id)),
                  itemBuilder: (_) => [
                    for (final s in c.script.sections) PopupMenuItem(value: s.id, child: Text(s.title)),
                  ],
                ),
                IconButton(tooltip: 'Ajustes (S)', onPressed: widget.onSettings, icon: const Icon(Icons.tune)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.controller});
  final PrompterController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final s = controller.settings;
        void set(PrompterSettings Function(PrompterSettings) f) => controller.updateSettings(f);
        Widget slider(String label, double value, double min, double max, String shown,
                PrompterSettings Function(PrompterSettings, double) apply) =>
            Row(children: [
              SizedBox(width: 150, child: Text(label)),
              Expanded(
                child: Slider(value: value, min: min, max: max, label: shown, onChanged: (v) => set((p) => apply(p, v))),
              ),
              SizedBox(width: 56, child: Text(shown, textAlign: TextAlign.end)),
            ]);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              slider('Tamaño de letra', s.fontSize, 24, 160, s.fontSize.round().toString(),
                  (p, v) => p.copyWith(fontSize: v)),
              slider('Interlineado', s.lineHeight, 1.0, 2.2, s.lineHeight.toStringAsFixed(2),
                  (p, v) => p.copyWith(lineHeight: v)),
              slider('Margen lateral', s.horizontalMargin, 0, 0.3, '${(s.horizontalMargin * 100).round()} %',
                  (p, v) => p.copyWith(horizontalMargin: v)),
              slider('Línea de enfoque', s.focusLine, 0.1, 0.9, '${(s.focusLine * 100).round()} %',
                  (p, v) => p.copyWith(focusLine: v)),
              slider('Velocidad', s.wpm, PrompterSettings.minWpm, PrompterSettings.maxWpm, '${s.wpm.round()}',
                  (p, v) => p.copyWith(wpm: v)),
              Row(children: [
                const SizedBox(width: 150, child: Text('Color del texto')),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Blanco')),
                    ButtonSegment(value: 1, label: Text('Amarillo')),
                  ],
                  selected: {s.textColor == PrompterPalette.yellow ? 1 : 0},
                  onSelectionChanged: (v) => set((p) => p.copyWith(
                      textColor: v.first == 1 ? PrompterPalette.yellow : PrompterPalette.white)),
                ),
              ]),
              SwitchListTile(
                title: const Text('Espejo horizontal (H)'),
                value: s.mirrorHorizontal,
                onChanged: (v) => set((p) => p.copyWith(mirrorHorizontal: v)),
              ),
              SwitchListTile(
                title: const Text('Espejo vertical (V)'),
                value: s.mirrorVertical,
                onChanged: (v) => set((p) => p.copyWith(mirrorVertical: v)),
              ),
              SwitchListTile(
                title: const Text('Guía de la línea de enfoque'),
                value: s.showFocusGuide,
                onChanged: (v) => set((p) => p.copyWith(showFocusGuide: v)),
              ),
            ]),
          ),
        );
      },
    );
  }
}
