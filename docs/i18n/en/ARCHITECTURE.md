# PromptFlow — Architecture

> Translated from the [Spanish original](../../ARCHITECTURE.md). If they differ, the original prevails.

Cross-platform teleprompter (Linux x86_64/ARM64 + Android API 26+) with LAN remote control and optional local voice synchronization.

## 1. Tech stack

**Chosen: Flutter 3.4x (Dart 3) — a single codebase for Linux and Android, with no cloud dependencies.**

| Criterion | Flutter | Qt6/QML (C++) | Rust + Tauri | Electron |
|---|---|---|---|---|
| Text rendering at 60/120 fps | Own engine (Impeller on Android, Skia/GL over GTK on Linux); paints directly to the surface, native VSync | Excellent (GL/Vulkan scene graph) | WebView: WebKitGTK on Linux has jerky scrolling and no reliable acceleration | Chromium: smooth, but heavy |
| Idle RAM (order of magnitude) | ~80–150 MB | ~50–90 MB | ~60–120 MB (WebView) | 250 MB or more |
| One codebase for Linux + Android | Yes | Yes, but deploying to Android (JNI, NDK, licensing) is more costly | Tauri Mobile exists, but the Android WebView varies by manufacturer | No Android |
| Built-in WS/UDP server | `dart:io` (no dependencies) | QtWebSockets | tokio | Node |
| Native STT integration | FFI / platform channels | Native | Native (excellent) | native addon |

Qt6 wins narrowly on RAM, but Flutter wins on **total cost**: one UI, one engine, one protocol, shared tests, and a render pipeline that doesn't depend on a WebView. The scroll engine doesn't rebuild widgets per frame (see §3), so Flutter's performance here is equivalent to painting on a native canvas.

Runtime dependencies: only `path_provider` and `file_picker`. Networking, JSON and animation use the SDK.

## 2. Layers (Clean Architecture + MVVM)

```
lib/
├── main.dart, app.dart               # composition and high-contrast dark theme
├── domain/                           # Pure Dart (only dart:ui Color). No I/O.
│   ├── entities/script.dart          #   Script, ScriptBlock, spans (TextRun, CameraTag, PauseMark, CueMark)
│   ├── entities/prompter_settings.dart  # immutable settings + palette
│   └── services/wpm_estimator.dart   #   duration, required WPM
├── data/
│   ├── parsing/script_parser.dart    # .md/.txt → Script ([CAM]/[PAUSE]/[CUE] tags)
│   └── repositories/script_repository.dart  # local files (app documents)
├── engine/                           # Module A — performance
│   ├── script_layout.dart            #   single layout pass + word↔px map
│   ├── scroll_engine.dart            #   animation loop (Ticker, delta time)
│   └── prompter_painter.dart         #   CustomPainter with mirroring and culling
├── remote/                           # Module C
│   ├── protocol/messages.dart        #   JSON envelope, commands, snapshot
│   ├── server/remote_server.dart     #   WebSocket + PIN + UDP reply
│   ├── client/remote_client.dart     #   remote: reconnection, RTT, dead reckoning
│   └── discovery/lan_discovery.dart  #   UDP broadcast probe
├── input/pedal_shortcuts.dart        # keyboard and BT pedals (HID) → commands
├── voice/                            # Module D
│   ├── speech_recognizer.dart        #   interface + Vosk bridge (platform channel)
│   └── voice_aligner.dart            #   fuzzy hypothesis↔script alignment
└── presentation/
    ├── controllers/prompter_controller.dart  # ViewModel; single entry point execute(cmd)
    └── screens/ home · editor · prompter · remote
```

Dependency rule: `presentation → engine/remote/voice → domain ← data`. The domain knows nothing about Flutter widgets, sockets or files.

**Unified command pattern**: keyboard, pedal, gestures, remote control and voice all produce the same `PrompterCommand` (sealed class), which also travels over the network. `PrompterController.execute` is the only place that mutates state, so every input behaves the same way.

## 3. Render pipeline (Module A)

1. **Layout once**: `ScriptLayout.build` creates one `TextPainter` per block whenever size, font, line spacing or margin change; in the same pass it records the Y of every word, pause, cue and section.
2. **Loop**: `ScrollEngine` uses a `Ticker` (compositor VSync, 60/90/120 Hz). Each tick integrates `offset += v·dt`, with the real `dt` clamped to 250 ms. Velocity follows the target through an exponential filter (τ = 0.22 s), so play/pause have inertia and don't jump. Jumps (±5 s, sections) decay exponentially (τ = 0.12 s). The Ticker stops when idle (0 % CPU).
3. **Painting**: `CustomPaint(painter: PrompterPainter(repaint: engine))` inside a `RepaintBoundary`. The tick only marks that layer as dirty, with no `build()` and no re-layout. The painter translates the canvas, draws only the visible blocks (culling) and snaps the offset to the physical pixel to avoid text *shimmer*.
4. **Mirroring**: `canvas.scale(-1, 1)` / `(1, -1)`. It's an affine transform with no intermediate textures and no per-frame cost.
5. **HUD**: refreshed at 4 Hz by its own timer, not per frame.

No tearing: Flutter presents on the compositor's VSync (Wayland/X11 via GTK on Linux; SurfaceFlinger on Android).

Typical per-frame budget: engine advance < 0.05 ms and painting 2–4 visible blocks < 1 ms on the raster thread.

### Pauses, cues and remaining time
* `[PAUSE 2s]`: the engine stops **exactly** on the marker, counts down the time and resumes on its own (`autoPaused`).
* `[PAUSE]`: holds (`holding`) until Play.
* Remaining time = remaining words / WPM + pending automatic pauses + current pause.

## 4. Multi-device synchronization (Module C)

See `docs/PROTOCOL.md`. Summary: the prompter (Linux, or Android in prompter mode) hosts the WS server while the view is open. The Android remote discovers it over UDP, pairs via PIN and sends commands. It receives snapshots in **words** and extrapolates between them.

Bluetooth pedals: they show up as an HID keyboard (PgUp/PgDn/Space/arrows/media keys) and are mapped in `input/pedal_shortcuts.dart`. They work whether connected to the Linux machine or to the phone acting as the remote, because `PrompterShortcuts` wraps both views.

## 5. Local voice (Module D)

```
Mic 16 kHz ─▶ VAD (Kaldi in Vosk) ─▶ streaming STT (partials ~150 ms)
      ─▶ VoiceAligner (Levenshtein, window −12/+60 words, proximity bias)
      ─▶ ScrollEngine.followWord(i) ─▶ speech-rate feed-forward + P (K = 2.5)
```

* **Chosen engine: Vosk** (Apache 2.0, offline, streaming with partials, small models of about 40–50 MB per language, with Android and C bindings). Whisper.cpp is more accurate, but it processes windows of several seconds, and its latency or CPU cost is too high for word-by-word tracking on ARM. It can be added as an alternative `SpeechRecognizer`.
* **Control**: the engine estimates the speech rate (EMA between recognitions) and adds it as feed-forward, so the text doesn't constantly lag behind. The error is corrected with critical damping (4·τ·K = 1), without overshoot. A dead zone keeps the text from moving back because of fluctuations; only a real backtrack by the speaker (more than one line) makes it go back. If there is no recognition for 1.5 s, the feed-forward is zeroed and the text stops along with the speaker.
* **Restricted grammar**: on start, Vosk receives the JSON list of the script's words plus `[unk]`. The small model only chooses among those words, with better accuracy and lower latency.

### Channel contract

| Channel | Message | Response |
|---|---|---|
| `MethodChannel("promptflow/stt")` | `isAvailable {modelPath}` | `bool`: library, audio and model present |
| | `start {modelPath, grammar?}` | `null` once the mic is open; error `stt_unavailable`, `stt_no_model` or `stt_start_failed` |
| | `stop` | `null` |
| `EventChannel("promptflow/stt/events")` | `{"raw": "<Vosk json>", "final": bool}` | Stream errors with code `stt_error` (e.g. the mic gets disconnected) |

### Linux (implemented): `linux/runner/vosk_stt_plugin.cc`
* `libvosk.so` (bundled in `bundle/lib/`, or the system one) and `libpulse-simple.so.0` are loaded with **dlopen**. The app builds and starts without them: `isAvailable` returns `false` and the voice button is hidden.
* Capture uses the PulseAudio *simple* API, which works on PipeWire via `pipewire-pulse`: 16 kHz, S16LE, mono, in 100 ms chunks (`fragsize` = 3200 B) so partials arrive early.
* A worker thread loads the model (kept across `start`/`stop`), reads audio and calls `accept_waveform`. It only sends partials when they change. Events are handed to the main thread with `g_idle_add`, because GTK and Flutter are not *thread-safe*. `start` replies from the thread once everything is ready, so loading the model doesn't freeze the UI.
* Installation: `tool/setup_vosk_linux.sh` downloads `libvosk` 0.3.45 (x86_64/aarch64) into `linux/third_party/vosk/` (CMake copies it into the bundle) and `vosk-model-small-es-0.42` into `<documents>/PromptFlow/models/vosk-es`.
* Testing without a microphone: with `PROMPTFLOW_STT_WAV=<16 kHz mono wav>` the plugin reads the WAV in real time. `integration_test/vosk_linux_test.dart` uses it.

Measured during development: the microphone opens and the Spanish model loads in ~0.25 s; `stop` takes ~80 ms. The transcription of Vosk's sample WAV matches `libvosk` used directly, word for word.

### Android (implemented): `android/app/src/main/kotlin/.../VoskSttPlugin.kt`
* Dependency `com.alphacephei:vosk-android:0.3.75`: includes `libvosk.so` for arm64-v8a, armeabi-v7a, x86 and x86_64, and JNA as an AAR.
* `SpeechService(recognizer, 16000f)` captures with `AudioRecord` on its own thread and delivers results on the main thread. The plugin only forwards partials that change.
* The model is loaded on an `Executor` (without blocking the UI) and kept between `start` and `stop`.
* `RECORD_AUDIO` runtime permission: `start` requests it and continues once granted; if denied, it replies with the `stt_permission` error.
* Same channel contract as on Linux. Registration happens in `MainActivity.configureFlutterEngine`.

### Per-language models and in-app download (`lib/voice/voice_models.dart`)
* Catalog of 11 small models verified on alphacephei.com (31–83 MB): es, en, pt, fr, de, it, ru, zh, ja, ko, hi. Arabic isn't included because its models weigh 158–318 MB.
* It's chosen in **Settings → Voice**. The model is downloaded once to `<documents>/PromptFlow/models/vosk-<language>`, with progress and a cancel option, and extracted in a separate isolate.
* Both Vosk layouts are accepted: the current one (`am/`, `conf/`) and the old one, with everything at the root (for example `small-pt-0.3`).

## 6. Script format

```markdown
# Show title
## Section (jump target)
[CAM 1] Text with **emphasis** and ==highlight==. [PAUSE 2s]
[CUE Interview] Manual pause until Play: [PAUSE]
<!-- hidden comment -->
```
In `.txt` files only the bracketed tags are interpreted.

## 7. Internationalization

* **UI**: `lib/l10n/app_<language>.arb`, with `flutter gen-l10n` (configured in `l10n.yaml`). There are 12 languages: en (reference), es, pt, fr, de, it, ru, zh, ja, ko, hi and ar. The system language is used; if it isn't translated, English.
* In code, `context.l10n.<key>` (`lib/presentation/l10n.dart`). Layers without a `BuildContext` (such as the controller) don't produce text: they expose typed errors (`VoiceIssue`) that the UI translates.
* The sample script is created in the system language (`homeSampleScript`). Script tags (`[CAM]`, `[PAUSE]`, `[CUE]`) are **not translated**: they are syntax.
* `test/l10n_test.dart` validates every language: loading, intact tags in the sample, ASCII file name, placeholders and plurals.
* **Translated documentation** lives in `docs/i18n/<language>/`. README and CONTRIBUTING are available in 11 languages; architecture and protocol in English. The Spanish original is the reference.
* Known limitation: word counting (WPM) and voice alignment split words on spaces. Chinese and Japanese don't use spaces, so they count phrases instead of words.

## 8. Pending / next steps

* Keep the screen on: `wakelock_plus` in `PrompterScreen`.
* `follower` role: a second device that shows the same script following `state.snapshot` (the protocol already transmits the position in words).
* Packaging: Flatpak/AppImage (Linux) and signed AAB (Android); `flutter build linux --target-platform linux-arm64` for ARM64.
* Persist `PrompterSettings` per device.
