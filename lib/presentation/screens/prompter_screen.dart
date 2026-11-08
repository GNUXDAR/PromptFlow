import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../data/repositories/script_repository.dart';
import '../../domain/entities/prompter_settings.dart';
import '../../domain/entities/script.dart';
import '../../domain/services/wpm_estimator.dart';
import '../../engine/prompter_painter.dart';
import '../../engine/scroll_engine.dart';
import '../../input/pedal_shortcuts.dart';
import '../../remote/protocol/messages.dart';
import '../../remote/server/remote_server.dart';
import '../../voice/voice_models.dart';
import '../controllers/prompter_controller.dart';
import '../l10n.dart';

/// Texto traducido de un problema de voz.
String voiceIssueText(AppLocalizations l10n, VoiceIssue i) => switch (i.kind) {
      VoiceIssueKind.noModel => l10n.voiceErrorNoModel,
      VoiceIssueKind.noEngine => l10n.voiceErrorNoEngine,
      VoiceIssueKind.permissionDenied => l10n.voiceErrorPermission,
      VoiceIssueKind.downloadFailed => l10n.voiceErrorDownload(i.detail ?? ''),
      VoiceIssueKind.engineError => l10n.voiceErrorEngine(i.detail ?? ''),
    };

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
  // Idioma de voz por defecto: el del sistema si hay modelo; si no, español.
  late final PrompterController _c = PrompterController(
    vsync: this,
    repository: widget.repository,
    script: widget.script,
    settings: PrompterSettings(
      voiceLanguage: VoiceModels.defaultFor(WidgetsBinding.instance.platformDispatcher.locale.languageCode),
    ),
  );
  late final Future<List<String>> _ips = RemoteServer.lanAddresses();
  bool _hud = true;
  Timer? _hudTimer;

  @override
  void initState() {
    super.initState();
    _c.startServer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // La pantalla no se apaga ni se bloquea mientras el prompter está abierto
    // (Android: FLAG_KEEP_SCREEN_ON; Linux: inhibe el salvapantallas).
    _keepAwake(true);
    _pokeHud();
  }

  @override
  void dispose() {
    _hudTimer?.cancel();
    _keepAwake(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _c.dispose();
    super.dispose();
  }

  static Future<void> _keepAwake(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } on Object catch (e) {
      debugPrint('PF: no se pudo mantener la pantalla encendida: $e');
    }
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

  /// Micrófono: activa/desactiva la voz o, si falta el modelo, ofrece
  /// descargarlo y activa la voz en cuanto termina.
  Future<void> _onVoicePressed() async {
    final c = widget.controller;
    final l10n = context.l10n;
    if (c.voiceModelProgress != null) return; // ya descargando
    if (c.voiceAvailable) {
      widget.onCommand(VoiceSyncCommand(!c.voiceActive));
      return;
    }
    if (c.voiceModelInstalled) {
      // Hay modelo pero falta el motor (Linux sin libvosk).
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.voiceErrorNoEngine)));
      return;
    }
    final model = VoiceModels.byCode(c.settings.voiceLanguage);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.mic),
        title: Text(l10n.voiceTitle),
        content: Text(l10n.voiceDownloadPrompt(model.name, model.sizeMb)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.download),
            label: Text(l10n.voiceDownload(model.sizeMb)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await c.installVoiceModel();
    if (c.voiceAvailable && !c.voiceActive) widget.onCommand(const VoiceSyncCommand(true));
  }

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
    final l10n = context.l10n;
    final status = switch (e.status) {
      PlaybackStatus.playing => l10n.statusPlaying,
      PlaybackStatus.autoPaused =>
        l10n.statusAutoPaused(((e.autoPauseLeft?.inMilliseconds ?? 0) / 1000).toStringAsFixed(1)),
      PlaybackStatus.holding => l10n.statusHolding,
      PlaybackStatus.finished => l10n.statusFinished,
      PlaybackStatus.stopped => l10n.statusStopped,
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
                tooltip: l10n.prompterExit,
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
                  final text = c.voiceError != null
                      ? voiceIssueText(l10n, c.voiceError!)
                      : c.serverError != null
                          ? l10n.prompterServerPortError(PfProtocol.defaultWsPort, c.serverError!)
                          : server.running
                              ? l10n.prompterServerInfo(
                                  (snap.data ?? const []).take(1).join(), server.port!, server.pin, server.clientCount)
                              : l10n.prompterServerStopped;
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
                  tooltip: l10n.prompterBack5,
                  onPressed: () => widget.onCommand(const SeekCommand(-5)),
                  icon: const Icon(Icons.replay_5),
                ),
                IconButton.filled(
                  tooltip: e.isPlaying ? l10n.prompterPause : l10n.prompterPlay,
                  iconSize: 36,
                  onPressed: () => widget.onCommand(const ToggleCommand()),
                  icon: Icon(e.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  tooltip: l10n.prompterForward5,
                  onPressed: () => widget.onCommand(const SeekCommand(5)),
                  icon: const Icon(Icons.forward_5),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: l10n.prompterSlower,
                  onPressed: () => widget.onCommand(const NudgeSpeedCommand(-10)),
                  icon: const Icon(Icons.remove),
                ),
                Text(l10n.prompterWpm(e.wpm.round()), style: t.titleMedium),
                IconButton(
                  tooltip: l10n.prompterFaster,
                  onPressed: () => widget.onCommand(const NudgeSpeedCommand(10)),
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 12),
                Text(l10n.prompterStatusLine(status, formatDuration(e.remaining)), style: t.bodyMedium),
                // Siempre visible: si falta el modelo, tocarlo ofrece descargarlo.
                IconButton(
                  tooltip: c.voiceActive ? l10n.prompterVoiceOff : l10n.prompterVoiceOn,
                  isSelected: c.voiceActive,
                  onPressed: _onVoicePressed,
                  icon: c.voiceModelProgress != null
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            value: c.voiceModelProgress! < 0 ? null : c.voiceModelProgress,
                          ),
                        )
                      : Icon(c.voiceAvailable ? Icons.mic_none : Icons.mic_off_outlined),
                  selectedIcon: const Icon(Icons.mic),
                ),
                PopupMenuButton<String>(
                  tooltip: l10n.prompterGoToSection,
                  icon: const Icon(Icons.bookmarks_outlined),
                  onSelected: (id) => widget.onCommand(JumpCommand(id)),
                  itemBuilder: (_) => [
                    for (final s in c.script.sections) PopupMenuItem(value: s.id, child: Text(s.title)),
                  ],
                ),
                IconButton(tooltip: l10n.prompterSettings, onPressed: widget.onSettings, icon: const Icon(Icons.tune)),
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
        final l10n = context.l10n;
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
              slider(l10n.settingsFontSize, s.fontSize, 24, 160, s.fontSize.round().toString(),
                  (p, v) => p.copyWith(fontSize: v)),
              slider(l10n.settingsLineHeight, s.lineHeight, 1.0, 2.2, s.lineHeight.toStringAsFixed(2),
                  (p, v) => p.copyWith(lineHeight: v)),
              slider(l10n.settingsMargin, s.horizontalMargin, 0, 0.3, '${(s.horizontalMargin * 100).round()} %',
                  (p, v) => p.copyWith(horizontalMargin: v)),
              slider(l10n.settingsFocusLine, s.focusLine, 0.1, 0.9, '${(s.focusLine * 100).round()} %',
                  (p, v) => p.copyWith(focusLine: v)),
              slider(l10n.settingsSpeed, s.wpm, PrompterSettings.minWpm, PrompterSettings.maxWpm, '${s.wpm.round()}',
                  (p, v) => p.copyWith(wpm: v)),
              Row(children: [
                SizedBox(width: 150, child: Text(l10n.settingsTextColor)),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: Text(l10n.settingsWhite)),
                    ButtonSegment(value: 1, label: Text(l10n.settingsYellow)),
                  ],
                  selected: {s.textColor == PrompterPalette.yellow ? 1 : 0},
                  onSelectionChanged: (v) => set((p) => p.copyWith(
                      textColor: v.first == 1 ? PrompterPalette.yellow : PrompterPalette.white)),
                ),
              ]),
              SwitchListTile(
                title: Text(l10n.settingsMirrorH),
                value: s.mirrorHorizontal,
                onChanged: (v) => set((p) => p.copyWith(mirrorHorizontal: v)),
              ),
              SwitchListTile(
                title: Text(l10n.settingsMirrorV),
                value: s.mirrorVertical,
                onChanged: (v) => set((p) => p.copyWith(mirrorVertical: v)),
              ),
              SwitchListTile(
                title: Text(l10n.settingsFocusGuide),
                value: s.showFocusGuide,
                onChanged: (v) => set((p) => p.copyWith(showFocusGuide: v)),
              ),
              SwitchListTile(
                title: Text(l10n.settingsHighlightSpoken),
                secondary: const Icon(Icons.border_color_outlined, color: PrompterPalette.spoken),
                value: s.highlightSpoken,
                onChanged: (v) => set((p) => p.copyWith(highlightSpoken: v)),
              ),
              const Divider(height: 32),
              _VoiceSection(controller: controller),
            ]),
          ),
        );
      },
    );
  }
}

/// Ajustes de voz: idioma del modelo, estado y descarga.
class _VoiceSection extends StatelessWidget {
  const _VoiceSection({required this.controller});
  final PrompterController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final t = Theme.of(context).textTheme;
    final model = VoiceModels.byCode(c.settings.voiceLanguage);
    final progress = c.voiceModelProgress;
    final l10n = context.l10n;

    final String status;
    if (progress != null) {
      status = progress < 0 ? l10n.voiceStatusInstalling : l10n.voiceStatusDownloading((progress * 100).round());
    } else if (c.voiceAvailable) {
      status = l10n.voiceStatusReady;
    } else if (c.voiceModelInstalled) {
      status = l10n.voiceStatusNoEngine;
    } else {
      status = l10n.voiceStatusNoModel(model.sizeMb);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.voiceTitle, style: t.titleMedium),
      const SizedBox(height: 8),
      Row(children: [
        SizedBox(width: 150, child: Text(l10n.voiceLanguage)),
        DropdownButton<String>(
          value: model.code,
          onChanged: progress != null ? null : (v) => c.setVoiceLanguage(v!),
          items: [
            for (final m in VoiceModels.all) DropdownMenuItem(value: m.code, child: Text(m.name)),
          ],
        ),
      ]),
      const SizedBox(height: 8),
      Text(status, style: t.bodyMedium),
      if (c.voiceError != null)
        Text(voiceIssueText(l10n, c.voiceError!), style: t.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
      if (progress != null) ...[
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress < 0 ? null : progress),
        TextButton(onPressed: c.cancelVoiceModelInstall, child: Text(l10n.commonCancel)),
      ] else if (!c.voiceModelInstalled)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: FilledButton.icon(
            onPressed: c.installVoiceModel,
            icon: const Icon(Icons.download),
            label: Text(l10n.voiceDownload(model.sizeMb)),
          ),
        ),
    ]);
  }
}
