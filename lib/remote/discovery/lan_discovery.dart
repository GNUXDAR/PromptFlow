import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../protocol/messages.dart';

final class DiscoveredServer {
  const DiscoveredServer({required this.name, required this.host, required this.port});
  final String name;
  final String host;
  final int port;

  @override
  bool operator ==(Object other) => other is DiscoveredServer && other.host == host && other.port == port;
  @override
  int get hashCode => Object.hash(host, port);
}

/// Descubrimiento por broadcast UDP: el mando envía una sonda a
/// `255.255.255.255:47821` y cada prompter responde por unicast con su
/// nombre y puerto WebSocket. Si la red bloquea broadcast, la UI ofrece
/// conexión manual por IP.
abstract final class LanDiscovery {
  static Future<List<DiscoveredServer>> scan({Duration window = const Duration(milliseconds: 1500)}) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final found = <DiscoveredServer>{};
    final sub = socket.listen((e) {
      if (e != RawSocketEvent.read) return;
      final dg = socket.receive();
      if (dg == null) return;
      try {
        final m = PfMessage.decode(utf8.decode(dg.data));
        if (m.type != 'discover.reply') return;
        found.add(DiscoveredServer(
          name: m.payload['name'] as String? ?? dg.address.address,
          host: dg.address.address,
          port: (m.payload['port'] as num?)?.toInt() ?? PfProtocol.defaultWsPort,
        ));
      } on FormatException {
        // Ignora tráfico ajeno.
      }
    });
    final probe = utf8.encode(PfProtocol.discoveryProbe);
    // Tres sondas espaciadas: UDP no garantiza entrega.
    for (var i = 0; i < 3; i++) {
      socket.send(probe, InternetAddress('255.255.255.255'), PfProtocol.discoveryPort);
      await Future<void>.delayed(window ~/ 3);
    }
    await sub.cancel();
    socket.close();
    return found.toList();
  }
}
