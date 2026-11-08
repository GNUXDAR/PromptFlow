import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../protocol/messages.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting, failed }

/// Cliente del mando remoto (Android → Linux, o entre dos dispositivos).
///
/// Reconexión automática con backoff exponencial (0.5 s → 8 s); mide RTT
/// con `ping`/`pong` cada 2 s; expone el último [snapshot] y el catálogo.
class RemoteClient extends ChangeNotifier {
  RemoteClient({required this.deviceName});

  final String deviceName;

  WebSocket? _ws;
  Timer? _pingTimer;
  Timer? _retryTimer;
  int _attempt = 0;
  bool _wantConnected = false;
  bool _disposed = false;
  final _sentAt = <String, int>{};

  String? host;
  int port = PfProtocol.defaultWsPort;
  String? _pin;

  ConnectionStatus status = ConnectionStatus.disconnected;
  String? lastError;
  String? serverName;
  PrompterSnapshot? snapshot;
  List<Map<String, Object?>> scripts = const [];
  List<Map<String, Object?>> sections = const [];
  Duration? rtt;

  Future<bool> connect(String host, {int port = PfProtocol.defaultWsPort, required String pin}) async {
    this.host = host;
    this.port = port;
    _pin = pin;
    _wantConnected = true;
    _attempt = 0;
    return _open(initial: true);
  }

  Future<void> disconnect() async {
    _wantConnected = false;
    _retryTimer?.cancel();
    _pingTimer?.cancel();
    await _ws?.close(WebSocketStatus.normalClosure);
    _ws = null;
    _set(ConnectionStatus.disconnected);
  }

  void send(PrompterCommand cmd) {
    final ws = _ws;
    if (ws == null || status != ConnectionStatus.connected) return;
    ws.add(cmd.toMessage().encode());
  }

  Future<bool> _open({bool initial = false}) async {
    _set(initial ? ConnectionStatus.connecting : ConnectionStatus.reconnecting);
    try {
      final ws = await WebSocket.connect('ws://$host:$port${PfProtocol.wsPath}')
          .timeout(const Duration(seconds: 4));
      _ws = ws;
      final welcome = Completer<bool>();
      ws.listen(
        (raw) => _onMessage(raw, welcome),
        onDone: () => _onClosed(ws.closeCode, ws.closeReason, welcome),
        onError: (Object e) => _onClosed(null, '$e', welcome),
        cancelOnError: true,
      );
      ws.add(PfMessage('hello', payload: {
        'pin': _pin,
        'deviceName': deviceName,
        'role': 'remote',
        'platform': Platform.operatingSystem,
      }).encode());
      final ok = await welcome.future.timeout(const Duration(seconds: 5), onTimeout: () => false);
      if (!ok) {
        await ws.close();
        return false;
      }
      _attempt = 0;
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 2), (_) => _ping());
      _set(ConnectionStatus.connected);
      return true;
    } on Object catch (e) {
      lastError = '$e';
      _scheduleRetry();
      return false;
    }
  }

  void _onMessage(Object? raw, Completer<bool> welcome) {
    final PfMessage m;
    try {
      m = PfMessage.decode(raw);
    } on FormatException {
      return;
    }
    switch (m.type) {
      case 'welcome':
        serverName = m.payload['serverName'] as String?;
        _readCatalog(m.payload);
        final snap = m.payload['snapshot'];
        if (snap is Map<String, Object?>) {
          snapshot = PrompterSnapshot.fromMessage(PfMessage('state.snapshot', payload: snap),
              receivedAt: DateTime.now());
        }
        if (!welcome.isCompleted) welcome.complete(true);
      case 'state.snapshot':
        final s = PrompterSnapshot.fromMessage(m, receivedAt: DateTime.now());
        if (snapshot == null || s.rev >= snapshot!.rev || s.scriptId != snapshot!.scriptId) {
          snapshot = s;
          notifyListeners();
        }
      case 'script.changed':
        _readCatalog(m.payload);
        notifyListeners();
      case 'pong':
        final sent = _sentAt.remove(m.payload['re']);
        if (sent != null) {
          rtt = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - sent);
          notifyListeners();
        }
      case 'error':
        lastError = m.payload['code'] as String?;
        if (lastError == 'bad_pin') {
          _wantConnected = false; // no reintentar con un PIN incorrecto
          if (!welcome.isCompleted) welcome.complete(false);
          _set(ConnectionStatus.failed);
        }
        notifyListeners();
    }
  }

  void _readCatalog(Map<String, Object?> p) {
    List<Map<String, Object?>> list(Object? v) =>
        v is List ? v.whereType<Map<String, Object?>>().toList() : const [];
    if (p.containsKey('scripts')) scripts = list(p['scripts']);
    if (p.containsKey('sections')) sections = list(p['sections']);
  }

  void _ping() {
    final msg = PfMessage('ping');
    _sentAt[msg.id] = msg.ts;
    if (_sentAt.length > 20) _sentAt.remove(_sentAt.keys.first);
    _ws?.add(msg.encode());
  }

  void _onClosed(int? code, String? reason, Completer<bool> welcome) {
    _pingTimer?.cancel();
    _ws = null;
    if (!welcome.isCompleted) welcome.complete(false);
    if (code == 4401) {
      _wantConnected = false;
      lastError = 'bad_pin';
      _set(ConnectionStatus.failed);
      return;
    }
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_wantConnected) {
      if (status != ConnectionStatus.failed) _set(ConnectionStatus.disconnected);
      return;
    }
    _retryTimer?.cancel();
    final ms = (500 * (1 << _attempt.clamp(0, 4))).clamp(500, 8000);
    _attempt++;
    _set(ConnectionStatus.reconnecting);
    _retryTimer = Timer(Duration(milliseconds: ms), _open);
  }

  void _set(ConnectionStatus s) {
    status = s;
    notifyListeners();
  }

  /// Los callbacks del socket pueden llegar después de `dispose()`.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _wantConnected = false;
    _retryTimer?.cancel();
    _pingTimer?.cancel();
    _ws?.close();
    super.dispose();
  }
}
