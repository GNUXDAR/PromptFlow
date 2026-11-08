import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../protocol/messages.dart';

/// Proveedor de datos que el servidor necesita del prompter.
abstract interface class RemoteHost {
  PrompterSnapshot snapshot();

  /// `{scripts:[{id,title}], sections:[{id,title}]}`
  Map<String, Object?> catalog();
  void execute(PrompterCommand command);
}

/// Servidor WebSocket de control en la LAN (Módulo C).
///
/// * Emparejamiento por PIN de 4 dígitos (mostrado en el HUD del prompter).
/// * Difunde `state.snapshot`: inmediatamente si cambia `rev`, cada 250 ms
///   en reproducción (corrección del dead reckoning) y cada 2 s en reposo
///   (heartbeat). El mando extrapola entre snapshots.
/// * Responde a `ping` con `pong` para medir RTT.
class RemoteServer extends ChangeNotifier {
  RemoteServer({required this.host, this.name = 'PromptFlow', String? pin})
      : pin = pin ?? (Random.secure().nextInt(9000) + 1000).toString();

  final RemoteHost host;
  final String name;
  final String pin;

  HttpServer? _http;
  RawDatagramSocket? _discovery;
  Timer? _pump;
  final _clients = <_Client>{};
  int _lastRev = -1;
  DateTime _lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  bool get running => _http != null;
  int? get port => _http?.port;
  int get clientCount => _clients.where((c) => c.authed).length;

  Future<void> start({int port = PfProtocol.defaultWsPort}) async {
    if (running) return;
    _http = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _http!.listen(_onRequest, onError: (Object e) => debugPrint('PF server: $e'));
    try {
      _discovery = await RawDatagramSocket.bind(InternetAddress.anyIPv4, PfProtocol.discoveryPort);
      _discovery!.listen(_onDiscovery);
    } on SocketException catch (e) {
      debugPrint('PF discovery no disponible: $e'); // el mando puede usar IP manual
    }
    _pump = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
    notifyListeners();
  }

  Future<void> stop() async {
    _pump?.cancel();
    _discovery?.close();
    for (final c in _clients.toList()) {
      await c.socket.close(WebSocketStatus.goingAway);
    }
    _clients.clear();
    await _http?.close(force: true);
    _http = null;
    _discovery = null;
    notifyListeners();
  }

  /// Direcciones IPv4 de la LAN para mostrar en pantalla.
  static Future<List<String>> lanAddresses() async {
    final ifs = await NetworkInterface.list(type: InternetAddressType.IPv4);
    return [
      for (final i in ifs)
        for (final a in i.addresses)
          if (!a.isLoopback) a.address,
    ];
  }

  /// Fuerza el envío del catálogo (cambio de guion o de secciones).
  void publishCatalog() {
    final msg = PfMessage('script.changed', payload: host.catalog()).encode();
    for (final c in _clients) {
      if (c.authed) c.socket.add(msg);
    }
  }

  void _tick() {
    if (clientCount == 0) return;
    final snap = host.snapshot();
    final now = DateTime.now();
    final since = now.difference(_lastSent);
    final due = snap.rev != _lastRev ||
        (snap.playing && since >= const Duration(milliseconds: 250)) ||
        since >= const Duration(seconds: 2);
    if (!due) return;
    _lastRev = snap.rev;
    _lastSent = now;
    final msg = PfMessage('state.snapshot', payload: snap.toJson()).encode();
    for (final c in _clients) {
      if (c.authed) c.socket.add(msg);
    }
  }

  Future<void> _onRequest(HttpRequest req) async {
    if (req.uri.path != PfProtocol.wsPath || !WebSocketTransformer.isUpgradeRequest(req)) {
      req.response.statusCode = HttpStatus.notFound;
      await req.response.close();
      return;
    }
    final ws = await WebSocketTransformer.upgrade(req);
    ws.pingInterval = const Duration(seconds: 5); // detecta clientes caídos
    final client = _Client(ws, req.connectionInfo?.remoteAddress.address ?? '?');
    _clients.add(client);

    // El cliente tiene 5 s para autenticarse con `hello`.
    final authTimeout = Timer(const Duration(seconds: 5), () {
      if (!client.authed) ws.close(4408, 'hello timeout');
    });

    ws.listen(
      (raw) => _onMessage(client, raw),
      onDone: () {
        authTimeout.cancel();
        _clients.remove(client);
        notifyListeners();
      },
      onError: (_) => _clients.remove(client),
      cancelOnError: true,
    );
  }

  void _onMessage(_Client c, Object? raw) {
    final PfMessage m;
    try {
      m = PfMessage.decode(raw);
    } on FormatException catch (e) {
      c.send(PfMessage('error', payload: {'code': 'bad_request', 'message': e.message}));
      return;
    }

    if (!c.authed) {
      if (m.type != 'hello') {
        c.send(PfMessage('error', payload: {'re': m.id, 'code': 'unauthorized'}));
        return;
      }
      if (m.payload['pin'] != pin) {
        c.send(PfMessage('error', payload: {'re': m.id, 'code': 'bad_pin'}));
        c.socket.close(4401, 'bad pin');
        return;
      }
      c.authed = true;
      c.deviceName = m.payload['deviceName'] as String? ?? c.address;
      c.send(PfMessage('welcome', payload: {
        're': m.id,
        'serverName': name,
        'protocol': PfProtocol.version,
        ...host.catalog(),
        'snapshot': host.snapshot().toJson(),
      }));
      notifyListeners();
      return;
    }

    switch (m.type) {
      case 'ping':
        c.send(PfMessage('pong', payload: {'re': m.id, 'clientTs': m.ts}));
      case _ when m.type.startsWith('cmd.'):
        final cmd = PrompterCommand.fromMessage(m);
        if (cmd == null) {
          c.send(PfMessage('error', payload: {'re': m.id, 'code': 'unknown_command'}));
          return;
        }
        host.execute(cmd);
        c.send(PfMessage('ack', payload: {'re': m.id}));
        _tick(); // feedback inmediato al mando
      default:
        c.send(PfMessage('error', payload: {'re': m.id, 'code': 'unknown_type'}));
    }
  }

  void _onDiscovery(RawSocketEvent e) {
    if (e != RawSocketEvent.read) return;
    final dg = _discovery?.receive();
    if (dg == null) return;
    if (String.fromCharCodes(dg.data).trim() != PfProtocol.discoveryProbe) return;
    final reply = PfMessage('discover.reply', payload: {
      'name': name,
      'port': port,
      'path': PfProtocol.wsPath,
    }).encode();
    _discovery?.send(utf8.encode(reply), dg.address, dg.port);
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

class _Client {
  _Client(this.socket, this.address);
  final WebSocket socket;
  final String address;
  bool authed = false;
  String? deviceName;

  void send(PfMessage m) {
    if (socket.readyState == WebSocket.open) socket.add(m.encode());
  }
}
