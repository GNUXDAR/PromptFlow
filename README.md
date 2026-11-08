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

## Contribuir

¡Las contribuciones son bienvenidas! PromptFlow es un proyecto abierto y cualquier ayuda suma: código, pruebas en hardware real, documentación o ideas.

### Por dónde empezar

Estas son las piezas pendientes con más impacto (detalle en [`docs/ARCHITECTURE.md §7`](docs/ARCHITECTURE.md)):

- **Plugins nativos de Vosk** para el seguimiento por voz: Kotlin (Android) y C++ con `libvosk` (Linux). El contrato del canal `promptflow/stt` está en `ARCHITECTURE.md §5`.
- **Rol `follower`**: un segundo dispositivo que muestre el guion siguiendo al prompter principal.
- **Pantalla siempre encendida** durante la lectura (`wakelock_plus`).
- **Empaquetado**: Flatpak / AppImage para Linux y builds de Android.
- **Pruebas en dispositivos reales**: pedales Bluetooth, tablets, Raspberry Pi (ARM64) y redes Wi‑Fi con aislamiento.

¿Encontraste un bug o tienes una idea? Abre un [issue](https://github.com/GNUXDAR/PromptFlow/issues).

### Flujo de trabajo

1. Haz un fork y crea una rama desde `main` (`feat/…`, `fix/…`, `docs/…`).
2. Antes de abrir el PR, verifica que todo pase:
   ```bash
   flutter analyze   # sin avisos
   flutter test      # todos los tests en verde
   ```
3. Añade tests para la lógica nueva (motor, parser, protocolo o voz).
4. Abre un Pull Request explicando qué cambia y por qué; si toca la interfaz, incluye una captura.

### Convenciones

- Respeta las capas de [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): `domain/` no depende de Flutter widgets, sockets ni ficheros.
- Toda acción de control es un `PrompterCommand` y pasa por `PrompterController.execute`.
- Si cambias el protocolo, actualiza [`docs/PROTOCOL.md`](docs/PROTOCOL.md) y sube `v` si rompe compatibilidad.
- Nada en el bucle de animación debe reconstruir widgets por frame.

## Licencia

[MIT](LICENSE) © 2026 Arturo Cabrera. Al contribuir aceptas que tu aporte se publique bajo esta misma licencia.
