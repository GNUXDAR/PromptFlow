import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/services/wpm_estimator.dart';
import '../../input/pedal_shortcuts.dart';
import '../../remote/client/remote_client.dart';
import '../../remote/discovery/lan_discovery.dart';
import '../../remote/protocol/messages.dart';
import '../l10n.dart';

/// Mando remoto táctil (Android → prompter Linux, o entre dos dispositivos).
class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final _client = RemoteClient(deviceName: Platform.localHostname);
  final _host = TextEditingController();
  final _pin = TextEditingController();
  List<DiscoveredServer> _found = const [];
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  @override
  void dispose() {
    _client.dispose();
    _host.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    try {
      final found = await LanDiscovery.scan();
      if (mounted) setState(() => _found = found);
    } on SocketException {
      // Sin broadcast disponible: queda la conexión manual.
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _connect(String host, int port) async {
    if (_pin.text.length != 4) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.remotePinRequired)));
      return;
    }
    await _client.connect(host, port: port, pin: _pin.text);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _client,
      builder: (context, _) {
        final connected = _client.status == ConnectionStatus.connected ||
            (_client.status == ConnectionStatus.reconnecting && _client.snapshot != null);
        return Scaffold(
          appBar: AppBar(
            title: Text(connected ? (_client.serverName ?? context.l10n.remoteTitle) : context.l10n.remoteConnectTitle),
            actions: [
              if (connected) ...[
                Center(
                  child: Text(
                    _client.status == ConnectionStatus.reconnecting
                        ? context.l10n.remoteReconnecting
                        : context.l10n.remoteRtt('${_client.rtt?.inMilliseconds ?? '–'}'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.remoteDisconnect,
                  onPressed: _client.disconnect,
                  icon: const Icon(Icons.link_off),
                ),
              ],
            ],
          ),
          body: connected ? _ControlPad(client: _client) : _connectForm(context),
        );
      },
    );
  }

  Widget _connectForm(BuildContext context) {
    final l10n = context.l10n;
    final error = switch (_client.lastError) {
      'bad_pin' => l10n.remoteBadPin,
      null => null,
      final e => l10n.remoteConnectFailed(e),
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _pin,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l10n.remotePinLabel, border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Text(l10n.remoteOnLan, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          TextButton.icon(
            onPressed: _scanning ? null : _scan,
            icon: _scanning
                ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            label: Text(l10n.remoteSearch),
          ),
        ]),
        if (_found.isEmpty && !_scanning)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.remoteNoneFound),
          ),
        for (final s in _found)
          ListTile(
            leading: const Icon(Icons.desktop_windows),
            title: Text(s.name),
            subtitle: Text('${s.host}:${s.port}'),
            onTap: () => _connect(s.host, s.port),
          ),
        const Divider(height: 32),
        TextField(
          controller: _host,
          decoration: InputDecoration(labelText: l10n.remoteManualIp, border: const OutlineInputBorder()),
          onSubmitted: (_) => _connect(_host.text.trim(), PfProtocol.defaultWsPort),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _client.status == ConnectionStatus.connecting
              ? null
              : () => _connect(_host.text.trim(), PfProtocol.defaultWsPort),
          child: Text(l10n.remoteConnect),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ],
    );
  }
}

class _ControlPad extends StatefulWidget {
  const _ControlPad({required this.client});
  final RemoteClient client;

  @override
  State<_ControlPad> createState() => _ControlPadState();
}

class _ControlPadState extends State<_ControlPad> {
  Timer? _tick;
  double? _scrub; // posición mientras el usuario arrastra la barra

  @override
  void initState() {
    super.initState();
    // Progreso extrapolado localmente entre snapshots (dead reckoning).
    _tick = Timer.periodic(const Duration(milliseconds: 100), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _send(PrompterCommand c) {
    HapticFeedback.selectionClick();
    widget.client.send(c);
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    final s = client.snapshot;
    final t = Theme.of(context).textTheme;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final word = s.wordAt(DateTime.now()).clamp(0, s.wordCount.toDouble());
    final progress = s.wordCount <= 1 ? 0.0 : (word / (s.wordCount - 1)).clamp(0.0, 1.0);
    final l10n = context.l10n;

    // Un pedal BT emparejado con el teléfono también controla el prompter.
    return PrompterShortcuts(
      onCommand: _send,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.scriptTitle ?? '', style: t.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Semantics(
            label: l10n.remotePosition,
            child: Slider(
              value: _scrub ?? progress.toDouble(),
              onChanged: (v) => setState(() => _scrub = v),
              onChangeEnd: (v) {
                _send(GotoWordCommand(v * (s.wordCount - 1)));
                setState(() => _scrub = null);
              },
            ),
          ),
          Row(children: [
            Text(_statusLabel(l10n, s.status)),
            const Spacer(),
            Text(l10n.remoteRemaining(formatDuration(Duration(milliseconds: s.remainingMs)))),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _BigButton(icon: Icons.replay_5, label: l10n.remoteBack5, onTap: () => _send(const SeekCommand(-5))),
            _BigButton(
              icon: s.playing ? Icons.pause : Icons.play_arrow,
              label: s.playing ? l10n.remotePause : l10n.remotePlay,
              primary: true,
              onTap: () => _send(const ToggleCommand()),
            ),
            _BigButton(icon: Icons.forward_5, label: l10n.remoteForward5, onTap: () => _send(const SeekCommand(5))),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton.outlined(
              tooltip: l10n.remoteSlower,
              iconSize: 32,
              onPressed: () => _send(const NudgeSpeedCommand(-10)),
              icon: const Icon(Icons.remove),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(l10n.prompterWpm(s.wpm.round()), style: t.headlineSmall),
            ),
            IconButton.outlined(
              tooltip: l10n.remoteFaster,
              iconSize: 32,
              onPressed: () => _send(const NudgeSpeedCommand(10)),
              icon: const Icon(Icons.add),
            ),
          ]),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            FilterChip(
              label: Text(l10n.remoteMirrorH),
              selected: s.mirrorH,
              onSelected: (v) => _send(MirrorCommand(horizontal: v)),
            ),
            FilterChip(
              label: Text(l10n.remoteMirrorV),
              selected: s.mirrorV,
              onSelected: (v) => _send(MirrorCommand(vertical: v)),
            ),
            FilterChip(
              label: Text(l10n.remoteFollowVoice),
              selected: s.voice,
              onSelected: (v) => _send(VoiceSyncCommand(v)),
            ),
            ActionChip(label: Text(l10n.remoteStart), onPressed: () => _send(const GotoWordCommand(0))),
          ]),
          if (client.sections.isNotEmpty) ...[
            const Divider(height: 32),
            Text(l10n.remoteSections, style: t.titleMedium),
            for (final sec in client.sections)
              ListTile(
                dense: true,
                selected: sec['id'] == s.sectionId,
                title: Text('${sec['title']}'),
                onTap: () => _send(JumpCommand('${sec['id']}')),
              ),
          ],
          if (client.scripts.length > 1) ...[
            const Divider(height: 32),
            Text(l10n.remoteChangeScript, style: t.titleMedium),
            for (final sc in client.scripts)
              ListTile(
                dense: true,
                selected: sc['id'] == s.scriptId,
                leading: const Icon(Icons.description_outlined),
                title: Text('${sc['title']}'),
                onTap: () => _send(LoadScriptCommand('${sc['id']}')),
              ),
          ],
        ],
      ),
    );
  }

  static String _statusLabel(AppLocalizations l10n, String s) => switch (s) {
        'playing' => l10n.statusPlaying,
        'autoPaused' => l10n.statusAutoPausedShort,
        'holding' => l10n.statusHoldingShort,
        'finished' => l10n.statusFinished,
        _ => l10n.statusStopped,
      };
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.icon, required this.label, required this.onTap, this.primary = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final size = primary ? 96.0 : 72.0;
    final style = primary
        ? FilledButton.styleFrom(shape: const CircleBorder(), fixedSize: Size.square(size))
        : OutlinedButton.styleFrom(shape: const CircleBorder(), fixedSize: Size.square(size));
    final child = Icon(icon, size: size * 0.45, semanticLabel: label);
    return primary
        ? FilledButton(style: style, onPressed: onTap, child: child)
        : OutlinedButton(style: style, onPressed: onTap, child: child);
  }
}
