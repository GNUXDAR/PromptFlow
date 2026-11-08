# PromptFlow control protocol v1

> Translated from the [Spanish original](../../PROTOCOL.md). If they differ, the original prevails.

Transport: **WebSocket** (`ws://<ip>:47820/pf/v1`) over the LAN, plus **UDP broadcast** (port `47821`) for discovery only. UTF‑8 text frames carrying JSON; maximum size 512 KiB.

Reference implementation: `lib/remote/protocol/messages.dart`, `lib/remote/server/remote_server.dart`, `lib/remote/client/remote_client.dart`.

## 1. Common envelope

```json
{ "v": 1, "type": "cmd.seek", "id": "m42", "ts": 1762600000123, "payload": { "seconds": -5 } }
```

| Field | Type | Description |
|---|---|---|
| `v` | int | Protocol version. A different `v` is rejected with `error/bad_request`. |
| `type` | string | `hello`, `welcome`, `cmd.*`, `state.snapshot`, `script.changed`, `ack`, `error`, `ping`, `pong`, `discover.reply`. |
| `id` | string | Sender's correlation id. Responses echo it in `payload.re`. |
| `ts` | int | Sender's epoch ms. Informational only: the client does **not** rely on synchronized clocks (it uses its own receive time). |
| `payload` | object | Event data. |

## 2. Position unit: words, not pixels

Each device has a different font size and width, so position travels as a **readable word index** (`word`, decimal) and speed in **WPM**. Each end projects it onto its own layout (`ScriptLayout.offsetForWord` / `wordAt`). That way an Android device can follow a Linux machine with a different font size without losing sync.

## 3. Lifecycle

```
Remote (Android)                         Prompter (Linux)
     │  UDP "PROMPTFLOW_DISCOVER_V1" ──▶ 255.255.255.255:47821
     │ ◀── discover.reply {name, port, path} (unicast)
     │
     │  WS connect /pf/v1
     │  hello {pin, deviceName, role, platform} ──▶
     │ ◀── welcome {serverName, protocol, scripts[], sections[], snapshot}
     │        (or error{code:"bad_pin"} + close 4401)
     │
     │  cmd.toggle ──▶                      execute()
     │ ◀── ack {re}
     │ ◀── state.snapshot (immediate, rev+1)
     │ ◀── state.snapshot every 250 ms while playing / 2 s when idle
     │  ping ──▶  ◀── pong {re, clientTs}   (RTT every 2 s)
```

* The client has **5 s** to send `hello`, or the connection is closed with `4408`.
* The server sends a WebSocket ping every 5 s to detect dropped remotes.
* The client reconnects with a 0.5 → 8 s backoff, except after a wrong PIN.

## 4. Messages

### Handshake

```json
{"type":"hello","payload":{"pin":"4821","deviceName":"Pixel 8","role":"remote","platform":"android"}}
{"type":"welcome","payload":{"re":"m1","serverName":"studio-pc","protocol":1,
  "scripts":[{"id":"news.md","title":"8 pm News"}],
  "sections":[{"id":"opening","title":"Opening"},{"id":"cue-interview","title":"▸ Interview"}],
  "snapshot":{ … see state.snapshot … }}}
```

`role`: `remote` (remote control). Reserved: `follower` (mirror display that reproduces the server's position).

### Commands (client → server)

| `type` | `payload` | Effect |
|---|---|---|
| `cmd.play` | — | Play (also resumes a manual `[PAUSE]`). |
| `cmd.pause` | — | Stop. |
| `cmd.toggle` | — | Play/Pause. |
| `cmd.seek` | `{"seconds": -5}` | Rewind (−) / Forward (+) by **reading** seconds at the current WPM. Animated. |
| `cmd.speed.set` | `{"wpm": 160}` | Absolute speed (40–400). |
| `cmd.speed.nudge` | `{"delta": 10}` | Speed up/slow down. |
| `cmd.jump` | `{"target": "opening"}` | Jump to a section (`## …`) or cue (`[CUE …]`). |
| `cmd.goto` | `{"word": 312.5}` | Absolute position (scrubbing). |
| `cmd.mirror` | `{"horizontal": true, "vertical": false}` | Set mirroring (optional fields). |
| `cmd.mirror.toggle` | `{"axis": "horizontal"}` | Toggle mirroring. |
| `cmd.font.nudge` | `{"delta": 4}` | Font size ±. |
| `cmd.script.load` | `{"scriptId": "news.md"}` | Switch script (id from `welcome.scripts`). |
| `cmd.voice` | `{"enabled": true}` | Enable/disable voice tracking. |

Response: `ack {"re": id}` or `error {"re": id, "code": "unknown_command" | "unknown_type" | "unauthorized" | "bad_request"}`.

### State (server → clients)

```json
{"type":"state.snapshot","payload":{
  "rev": 128, "status": "playing", "word": 312.4, "wordCount": 1840,
  "wpm": 150, "remainingMs": 612000, "progress": 0.1698,
  "scriptId": "news.md", "scriptTitle": "8 pm News", "sectionId": "opening",
  "mirror": {"horizontal": true, "vertical": false}, "voice": false }}
```

* `status`: `stopped | playing | autoPaused | holding | finished`.
* `rev`: monotonic; the client discards snapshots with a lower `rev` (except on a script change).
* **Dead reckoning**: between snapshots the remote estimates `word + wpm/60000 · (now − received)` if `status == "playing"`; the next snapshot corrects it. This gives smooth progress at a 10 Hz UI rate with only 4 messages/s.

`script.changed` → `{scripts[], sections[]}` when another script is loaded.

### Discovery (UDP)

* Probe: ASCII text `PROMPTFLOW_DISCOVER_V1` to `255.255.255.255:47821` (3 sends over 1.5 s).
* Unicast reply: JSON envelope `discover.reply {name, port, path}`.
* Networks that block broadcast (guest Wi‑Fi, AP isolation): the UI offers manual IP entry.

## 5. Security and latency

* LAN only; no cloud. 4-digit PIN generated per session with `Random.secure()` and shown in the prompter's HUD. After a wrong PIN the connection is closed (`4401`).
* For untrusted networks: wrap it in TLS (`wss://`, `HttpServer.bindSecure`) and use a longer PIN; the envelope doesn't change.
* Measured end-to-end latency = RTT/2 + 1 frame. On home Wi‑Fi the typical RTT is 3–15 ms; the command is applied on the prompter's next VSync.
* Why WebSocket rather than UDP for commands: commands must arrive **exactly once and in order** (a duplicated or lost `toggle` is visible). TCP+WS provides that, and the overhead is negligible at this rate. UDP is kept for discovery.
