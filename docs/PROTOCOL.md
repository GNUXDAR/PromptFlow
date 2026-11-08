# Protocolo de control PromptFlow v1

Transporte: **WebSocket** (`ws://<ip>:47820/pf/v1`) sobre la LAN, más **UDP broadcast** (puerto `47821`) solo para descubrimiento. Frames de texto UTF‑8 con JSON; tamaño máximo 512 KiB.

Implementación de referencia: `lib/remote/protocol/messages.dart`, `lib/remote/server/remote_server.dart`, `lib/remote/client/remote_client.dart`.

## 1. Sobre común

```json
{ "v": 1, "type": "cmd.seek", "id": "m42", "ts": 1762600000123, "payload": { "seconds": -5 } }
```

| Campo | Tipo | Descripción |
|---|---|---|
| `v` | int | Versión del protocolo. Un `v` distinto se rechaza con `error/bad_request`. |
| `type` | string | `hello`, `welcome`, `cmd.*`, `state.snapshot`, `script.changed`, `ack`, `error`, `ping`, `pong`, `discover.reply`. |
| `id` | string | Id de correlación del emisor. Las respuestas lo repiten en `payload.re`. |
| `ts` | int | Epoch ms del emisor. Solo informativo: el cliente **no** depende de relojes sincronizados (usa su hora de recepción). |
| `payload` | object | Datos del evento. |

## 2. Unidad de posición: palabras, no píxeles

Cada dispositivo tiene un tamaño de letra y un ancho distintos, así que la posición viaja como **índice de palabra leíble** (`word`, decimal) y la velocidad en **WPM**. Cada extremo la proyecta sobre su propia maquetación (`ScriptLayout.offsetForWord` / `wordAt`). Así un Android puede seguir a un Linux con letra distinta sin perder la sincronía.

## 3. Ciclo de vida

```
Mando (Android)                          Prompter (Linux)
     │  UDP "PROMPTFLOW_DISCOVER_V1" ──▶ 255.255.255.255:47821
     │ ◀── discover.reply {name, port, path} (unicast)
     │
     │  WS connect /pf/v1
     │  hello {pin, deviceName, role, platform} ──▶
     │ ◀── welcome {serverName, protocol, scripts[], sections[], snapshot}
     │        (o error{code:"bad_pin"} + cierre 4401)
     │
     │  cmd.toggle ──▶                      execute()
     │ ◀── ack {re}
     │ ◀── state.snapshot (inmediato, rev+1)
     │ ◀── state.snapshot cada 250 ms en reproducción / 2 s en reposo
     │  ping ──▶  ◀── pong {re, clientTs}   (RTT cada 2 s)
```

* El cliente tiene **5 s** para enviar `hello` o se cierra con `4408`.
* El servidor hace ping de WebSocket cada 5 s para detectar mandos caídos.
* El cliente reconecta con backoff 0.5 → 8 s, salvo con PIN incorrecto.

## 4. Mensajes

### Handshake

```json
{"type":"hello","payload":{"pin":"4821","deviceName":"Pixel 8","role":"remote","platform":"android"}}
{"type":"welcome","payload":{"re":"m1","serverName":"studio-pc","protocol":1,
  "scripts":[{"id":"noticias.md","title":"Noticias 20h"}],
  "sections":[{"id":"apertura","title":"Apertura"},{"id":"cue-entrevista","title":"▸ Entrevista"}],
  "snapshot":{ … ver state.snapshot … }}}
```

`role`: `remote` (mando). Reservado: `follower` (pantalla espejo que reproduce la posición del servidor).

### Comandos (cliente → servidor)

| `type` | `payload` | Efecto |
|---|---|---|
| `cmd.play` | — | Reproducir (reanuda también una pausa manual `[PAUSE]`). |
| `cmd.pause` | — | Detener. |
| `cmd.toggle` | — | Play/Pause. |
| `cmd.seek` | `{"seconds": -5}` | Rewind (−) / Forward (+) en segundos **de lectura** a los WPM actuales. Animado. |
| `cmd.speed.set` | `{"wpm": 160}` | Velocidad absoluta (40–400). |
| `cmd.speed.nudge` | `{"delta": 10}` | Acelerar/desacelerar. |
| `cmd.jump` | `{"target": "apertura"}` | Saltar a sección (`## …`) o cue (`[CUE …]`). |
| `cmd.goto` | `{"word": 312.5}` | Posición absoluta (scrubbing). |
| `cmd.mirror` | `{"horizontal": true, "vertical": false}` | Fijar espejo (campos opcionales). |
| `cmd.mirror.toggle` | `{"axis": "horizontal"}` | Alternar espejo. |
| `cmd.font.nudge` | `{"delta": 4}` | Tamaño de letra ±. |
| `cmd.script.load` | `{"scriptId": "noticias.md"}` | Cambiar de guion (id de `welcome.scripts`). |
| `cmd.voice` | `{"enabled": true}` | Activar/desactivar el seguimiento por voz. |

Respuesta: `ack {"re": id}` o `error {"re": id, "code": "unknown_command" | "unknown_type" | "unauthorized" | "bad_request"}`.

### Estado (servidor → clientes)

```json
{"type":"state.snapshot","payload":{
  "rev": 128, "status": "playing", "word": 312.4, "wordCount": 1840,
  "wpm": 150, "remainingMs": 612000, "progress": 0.1698,
  "scriptId": "noticias.md", "scriptTitle": "Noticias 20h", "sectionId": "apertura",
  "mirror": {"horizontal": true, "vertical": false}, "voice": false }}
```

* `status`: `stopped | playing | autoPaused | holding | finished`.
* `rev`: monotónico; el cliente descarta snapshots con `rev` menor (salvo cambio de guion).
* **Dead reckoning**: entre snapshots el mando estima `word + wpm/60000 · (ahora − recepción)` si `status == "playing"`; el siguiente snapshot corrige. Esto da un progreso fluido a 10 Hz de UI con solo 4 mensajes/s.

`script.changed` → `{scripts[], sections[]}` cuando se carga otro guion.

### Descubrimiento (UDP)

* Sonda: texto ASCII `PROMPTFLOW_DISCOVER_V1` a `255.255.255.255:47821` (3 envíos en 1.5 s).
* Respuesta unicast: sobre JSON `discover.reply {name, port, path}`.
* Redes que bloquean broadcast (Wi‑Fi de invitados, aislamiento de AP): la UI ofrece IP manual.

## 5. Seguridad y latencia

* Solo LAN; sin nube. PIN de 4 dígitos generado con `Random.secure()` por sesión y mostrado en el HUD del prompter. Tras un PIN erróneo se cierra la conexión (`4401`).
* Para redes no confiables: envolver con TLS (`wss://`, `HttpServer.bindSecure`) y un PIN más largo; el sobre no cambia.
* Latencia medida extremo a extremo = RTT/2 + 1 frame. En Wi‑Fi doméstica el RTT típico es 3–15 ms; el comando se aplica en el siguiente VSync del prompter.
* Por qué WebSocket y no UDP para comandos: los comandos deben llegar **una vez y en orden** (un `toggle` duplicado o perdido es visible). TCP+WS da eso y el overhead es despreciable a esta cadencia. UDP queda para el descubrimiento.
