# PromptFlow

> Translated from the [Spanish original](../../../README.md). If they differ, the original prevails.

Teleprompter for Linux and Android: smooth scrolling at the display's refresh rate, H/V mirroring, pauses and cues in the script, LAN remote control (WebSocket), Bluetooth pedals and local voice tracking (Vosk).

```bash
flutter pub get
flutter run -d linux          # prompter + control server
flutter run -d <android-id>   # prompter or remote control
flutter test                  # engine, parser, protocol (real sockets) and voice
```

### Voice tracking (optional, offline)

The text advances at the pace of your voice thanks to [Vosk](https://alphacephei.com/vosk/), a local speech recognizer. Models are available for 11 languages: es, en, pt, fr, de, it, ru, zh, ja, ko and hi.

- **Android:** open a script and go to **Settings → Voice**. Pick the language, tap *Download model* and then the microphone in the HUD. The first time, the app asks for microphone permission.
- **Linux:** install the engine once and download the model from the app or with the script:
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + Spanish model
  flutter run -d linux
  ```
  The default PulseAudio/PipeWire microphone is used.

* Architecture and rationale for the stack: [`docs/ARCHITECTURE.md`](ARCHITECTURE.md)
* WebSocket/UDP protocol: [`docs/PROTOCOL.md`](PROTOCOL.md)
* Scroll engine: [`lib/engine/scroll_engine.dart`](../../../lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](../../../lib/engine/prompter_painter.dart)

## Shortcuts (keyboard and pedal)

| Key | Action |
|---|---|
| Space / Enter / Play-Pause | Play / pause |
| Page Up / ← | Back 5 s |
| Page Down / → | Forward 5 s |
| ↑ / ↓ | ±10 WPM |
| H / V | Horizontal / vertical mirror |
| + / − | Font size |
| Home | Back to the start |
| S | Settings |
| Esc | Exit |

Touchscreen gestures: double-tap to play or pause, vertical drag to move through the script, and single tap to show the HUD.

## Contributing

Contributions are welcome! Code, testing on real hardware, documentation, translations or ideas: it all helps.

**Read the [contribution guide](CONTRIBUTING.md) first.** The essentials:

1. Create a new branch from `develop` using the `type/description` format (`feat/…`, `fix/…`, `docs/…`, `i18n/…`).
2. Open the pull request **against `develop`**. `main` only receives published releases.
3. Before submitting: `flutter analyze` with no warnings and `flutter test` green.

### Where to start

- **Tune voice tracking** with real recordings in different languages (gain, dead zone, aligner window).
- **Arabic voice model** suitable for mobile, if a small one becomes available.
- **`follower` role**: a second device that shows the script following the main prompter.
- **Keep the screen on** while reading (`wakelock_plus`).
- **Packaging**: Flatpak or AppImage for Linux, and Android builds.
- **Testing on real devices**: Bluetooth pedals, tablets, Raspberry Pi (ARM64) and Wi‑Fi networks with client isolation.

Found a bug or have an idea? Open an [issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose).

## License

[MIT](../../../LICENSE) © 2026 Arturo Cabrera. By contributing, you agree that your contribution is published under this same license.
