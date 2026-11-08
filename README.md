# PromptFlow

Teleprompter para Linux y Android: scroll suave a la frecuencia de la pantalla, espejo H/V, pausas y cues en el guion, control remoto por LAN (WebSocket), pedales Bluetooth y seguimiento por voz local (Vosk).

```bash
flutter pub get
flutter run -d linux          # prompter + servidor de control
flutter run -d <android-id>   # prompter o mando remoto
flutter test                  # motor, parser, protocolo (sockets reales) y voz
```

### Seguimiento por voz en Linux (opcional)

```bash
tool/setup_vosk_linux.sh      # descarga libvosk y el modelo español (~40 MB)
flutter run -d linux          # aparece el botón de micrófono en el HUD
```

Se usa el micrófono predeterminado de PulseAudio/PipeWire y todo funciona sin conexión.

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

## Contribuir

¡Las contribuciones son bienvenidas! Código, pruebas en hardware real, documentación, traducciones o ideas: todo suma.

**Lee primero la [guía de contribución](CONTRIBUTING.md).** Lo esencial:

1. Crea una rama nueva desde `develop` con el formato `tipo/descripcion` (`feat/…`, `fix/…`, `docs/…`, `i18n/…`).
2. Abre el pull request **contra `develop`**. `main` solo recibe versiones publicadas.
3. Antes de enviarlo: `flutter analyze` sin avisos y `flutter test` en verde.

### Por dónde empezar

- **Plugin nativo de Vosk para Android** (Kotlin). El de Linux, en `linux/runner/vosk_stt_plugin.cc`, sirve de referencia, y el contrato del canal `promptflow/stt` está en [`docs/ARCHITECTURE.md §5`](docs/ARCHITECTURE.md).
- **Rol `follower`**: un segundo dispositivo que muestre el guion siguiendo al prompter principal.
- **Pantalla siempre encendida** durante la lectura (`wakelock_plus`).
- **Empaquetado**: Flatpak o AppImage para Linux y builds de Android.
- **Pruebas en dispositivos reales**: pedales Bluetooth, tablets, Raspberry Pi (ARM64) y redes Wi‑Fi con aislamiento.

¿Encontraste un bug o tienes una idea? Abre un [issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose).

## Licencia

[MIT](LICENSE) © 2026 Arturo Cabrera. Al contribuir aceptas que tu aporte se publique bajo esta misma licencia.
