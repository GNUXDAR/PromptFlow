# PromptFlow

🌐 **Español** · [English](docs/i18n/en/README.md) · [Português](docs/i18n/pt/README.md) · [Français](docs/i18n/fr/README.md) · [Deutsch](docs/i18n/de/README.md) · [Italiano](docs/i18n/it/README.md) · [Русский](docs/i18n/ru/README.md) · [中文](docs/i18n/zh/README.md) · [日本語](docs/i18n/ja/README.md) · [한국어](docs/i18n/ko/README.md) · [हिन्दी](docs/i18n/hi/README.md) · [العربية](docs/i18n/ar/README.md)

Teleprompter para Linux y Android: scroll suave a la frecuencia de la pantalla, espejo H/V, pausas y cues en el guion, control remoto por LAN (WebSocket), pedales Bluetooth y seguimiento por voz local (Vosk).

```bash
flutter pub get
flutter run -d linux          # prompter + servidor de control
flutter run -d <android-id>   # prompter o mando remoto
flutter test                  # motor, parser, protocolo (sockets reales) y voz
```

### Seguimiento por voz (opcional, sin conexión)

El texto avanza al ritmo de tu voz gracias a [Vosk](https://alphacephei.com/vosk/), un reconocimiento de voz local. Hay modelos para 11 idiomas: es, en, pt, fr, de, it, ru, zh, ja, ko e hi.

- **Android:** abre un guion y ve a **Ajustes → Voz**. Elige el idioma, pulsa *Descargar modelo* y luego el micrófono del HUD. La primera vez la app pide permiso de micrófono.
- **Linux:** instala el motor una vez y descarga el modelo desde la app o con el script:
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + modelo español
  flutter run -d linux
  ```
  Se usa el micrófono predeterminado de PulseAudio/PipeWire.

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

- **Afinar el seguimiento por voz** con grabaciones reales en distintos idiomas (ganancia, zona muerta, ventana del alineador).
- **Modelo de voz en árabe** apto para móvil, si aparece uno pequeño.
- **Rol `follower`**: un segundo dispositivo que muestre el guion siguiendo al prompter principal.
- **Pantalla siempre encendida** durante la lectura (`wakelock_plus`).
- **Empaquetado**: Flatpak o AppImage para Linux y builds de Android.
- **Pruebas en dispositivos reales**: pedales Bluetooth, tablets, Raspberry Pi (ARM64) y redes Wi‑Fi con aislamiento.

¿Encontraste un bug o tienes una idea? Abre un [issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose).

## Licencia

[MIT](LICENSE) © 2026 Arturo Cabrera. Al contribuir aceptas que tu aporte se publique bajo esta misma licencia.
