# PromptFlow

Teleprompter para Linux y Android: scroll suave a la frecuencia de la pantalla, espejo H/V, pausas y cues en el guion, control remoto por LAN (WebSocket), pedales Bluetooth y seguimiento por voz local (Vosk).

```bash
flutter pub get
flutter run -d linux          # prompter + servidor de control
flutter run -d <android-id>   # prompter o mando remoto
flutter test                  # motor, parser, protocolo (sockets reales) y voz
```

* Arquitectura y justificación del stack: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
* Protocolo WebSocket/UDP: [`docs/PROTOCOL.md`](docs/PROTOCOL.md)
* Motor de scroll: [`lib/engine/scroll_engine.dart`](lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](lib/engine/prompter_painter.dart)

## Atajos (teclado y pedal)

| Tecla | Acción |
|---|---|
| Espacio / Enter / Play-Pause | Reproducir / pausar |
| Re Pág / ← | Atrás 5 s |
| Av Pág / → | Adelante 5 s |
| ↑ / ↓ | ±10 WPM |
| H / V | Espejo horizontal / vertical |
| + / − | Tamaño de letra |
| Inicio | Volver al principio |
| S | Ajustes |
| Esc | Salir |

Gestos en la pantalla táctil: doble toque para reproducir o pausar, arrastre vertical para desplazarte por el guion y toque simple para mostrar el HUD.
