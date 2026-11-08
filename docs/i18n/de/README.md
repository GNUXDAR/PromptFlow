# PromptFlow

> Aus dem spanischen Original übersetzt. Bei Abweichungen gilt das [Original](../../../README.md).

Teleprompter für Linux und Android: flüssiges Scrollen mit der Bildwiederholrate des Displays, H/V-Spiegelung, Pausen und Cues im Skript, Fernsteuerung über das LAN (WebSocket), Bluetooth-Pedale und lokale Sprachverfolgung (Vosk).

```bash
flutter pub get
flutter run -d linux          # Prompter + Steuerungsserver
flutter run -d <android-id>   # Prompter oder Fernbedienung
flutter test                  # Engine, Parser, Protokoll (echte Sockets) und Sprache
```

### Sprachverfolgung (optional, offline)

Der Text läuft im Tempo deiner Stimme mit – dank [Vosk](https://alphacephei.com/vosk/), einer lokalen Spracherkennung. Es gibt Modelle für 11 Sprachen: es, en, pt, fr, de, it, ru, zh, ja, ko und hi.

- **Android:** Öffne ein Skript und gehe zu **Einstellungen → Sprache**. Wähle die Sprache, tippe auf *Modell herunterladen* und dann auf das Mikrofon im HUD. Beim ersten Mal fragt die App nach der Mikrofonberechtigung.
- **Linux:** Installiere die Engine einmalig und lade das Modell in der App oder mit dem Skript herunter:
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + spanisches Modell
  flutter run -d linux
  ```
  Verwendet wird das Standardmikrofon von PulseAudio/PipeWire.

* Architektur und Begründung des Stacks: [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)
* WebSocket/UDP-Protokoll: [`docs/PROTOCOL.md`](../en/PROTOCOL.md)
* Scroll-Engine: [`lib/engine/scroll_engine.dart`](../../../lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](../../../lib/engine/prompter_painter.dart)

## Tastenkürzel (Tastatur und Pedal)

| Taste | Aktion |
|---|---|
| Leertaste / Eingabe / Play-Pause | Abspielen / pausieren |
| Bild↑ / ← | 5 s zurück |
| Bild↓ / → | 5 s vor |
| ↑ / ↓ | ±10 WPM |
| H / V | Horizontal / vertikal spiegeln |
| + / − | Schriftgröße |
| Pos1 | Zurück zum Anfang |
| S | Einstellungen |
| Esc | Beenden |

Gesten auf dem Touchscreen: Doppeltippen zum Abspielen oder Pausieren, vertikales Ziehen zum Blättern im Skript und einfaches Tippen zum Einblenden des HUD.

## Mitwirken

Beiträge sind willkommen! Code, Tests auf echter Hardware, Dokumentation, Übersetzungen oder Ideen: Alles hilft.

**Lies zuerst den [Leitfaden für Beiträge](CONTRIBUTING.md).** Das Wichtigste:

1. Erstelle einen neuen Branch von `develop` im Format `typ/beschreibung` (`feat/…`, `fix/…`, `docs/…`, `i18n/…`).
2. Öffne den Pull Request **gegen `develop`**. `main` erhält nur veröffentlichte Versionen.
3. Vor dem Einreichen: `flutter analyze` ohne Warnungen und `flutter test` grün.

### Wo anfangen

- **Sprachverfolgung feinabstimmen** mit echten Aufnahmen in verschiedenen Sprachen (Verstärkung, Totzone, Fenster des Aligners).
- **Arabisches Sprachmodell**, das sich für Mobilgeräte eignet, falls ein kleines erscheint.
- **Rolle `follower`**: ein zweites Gerät, das das Skript synchron zum Haupt-Prompter anzeigt.
- **Bildschirm bleibt an** während des Lesens (`wakelock_plus`).
- **Paketierung**: Flatpak oder AppImage für Linux und Android-Builds.
- **Tests auf echten Geräten**: Bluetooth-Pedale, Tablets, Raspberry Pi (ARM64) und WLAN-Netze mit Client-Isolation.

Einen Bug gefunden oder eine Idee? Eröffne ein [Issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose).

## Lizenz

[MIT](../../../LICENSE) © 2026 Arturo Cabrera. Mit deinem Beitrag erklärst du dich einverstanden, dass er unter derselben Lizenz veröffentlicht wird.
