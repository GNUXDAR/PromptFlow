# PromptFlow — Arquitectura

Teleprompter multiplataforma (Linux x86_64/ARM64 + Android API 26+) con control remoto por LAN y sincronización opcional por voz local.

## 1. Stack tecnológico

**Elegido: Flutter 3.4x (Dart 3) — una sola base de código para Linux y Android, sin dependencias en la nube.**

| Criterio | Flutter | Qt6/QML (C++) | Rust + Tauri | Electron |
|---|---|---|---|---|
| Render de texto a 60/120 fps | Motor propio (Impeller en Android, Skia/GL sobre GTK en Linux); pinta directo a la superficie, VSync nativo | Excelente (scene graph GL/Vulkan) | WebView: WebKitGTK en Linux tiene scroll irregular y sin aceleración fiable | Chromium: fluido, pero pesado |
| RAM en reposo (orden de magnitud) | ~80–150 MB | ~50–90 MB | ~60–120 MB (WebView) | 250 MB o más |
| Una base de código Linux + Android | Sí | Sí, pero el despliegue en Android (JNI, NDK, licencias) es más costoso | Tauri Mobile existe, pero el WebView de Android cambia según el fabricante | No hay Android |
| Servidor WS/UDP integrado | `dart:io` (sin dependencias) | QtWebSockets | tokio | Node |
| Integración STT nativa | FFI / platform channels | Nativa | Nativa (excelente) | addon nativo |

Qt6 gana por poco en RAM, pero Flutter gana en **coste total**: una UI, un motor, un protocolo, tests compartidos, y un pipeline de render que no depende de un WebView. El motor de scroll no reconstruye widgets por frame (ver §3), así que el rendimiento de Flutter aquí equivale a pintar en un canvas nativo.

Dependencias de runtime: solo `path_provider` y `file_picker`. Red, JSON y animación usan el SDK.

## 2. Capas (Clean Architecture + MVVM)

```
lib/
├── main.dart, app.dart               # composición y tema oscuro de alto contraste
├── domain/                           # Dart puro (solo dart:ui Color). Sin I/O.
│   ├── entities/script.dart          #   Script, ScriptBlock, spans (TextRun, CameraTag, PauseMark, CueMark)
│   ├── entities/prompter_settings.dart  # ajustes inmutables + paleta
│   └── services/wpm_estimator.dart   #   duración, WPM necesarios
├── data/
│   ├── parsing/script_parser.dart    # .md/.txt → Script (etiquetas [CAM]/[PAUSE]/[CUE])
│   └── repositories/script_repository.dart  # ficheros locales (documentos de la app)
├── engine/                           # Módulo A — rendimiento
│   ├── script_layout.dart            #   maquetación única + mapa palabra↔px
│   ├── scroll_engine.dart            #   bucle de animación (Ticker, tiempo delta)
│   └── prompter_painter.dart         #   CustomPainter con mirroring y culling
├── remote/                           # Módulo C
│   ├── protocol/messages.dart        #   sobre JSON, comandos, snapshot
│   ├── server/remote_server.dart     #   WebSocket + PIN + respuesta UDP
│   ├── client/remote_client.dart     #   mando: reconexión, RTT, dead reckoning
│   └── discovery/lan_discovery.dart  #   sondeo UDP broadcast
├── input/pedal_shortcuts.dart        # teclado y pedales BT (HID) → comandos
├── voice/                            # Módulo D
│   ├── speech_recognizer.dart        #   interfaz + puente Vosk (platform channel)
│   └── voice_aligner.dart            #   alineado difuso hipótesis↔guion
└── presentation/
    ├── controllers/prompter_controller.dart  # ViewModel; punto único execute(cmd)
    └── screens/ home · editor · prompter · remote
```

Regla de dependencia: `presentation → engine/remote/voice → domain ← data`. El dominio no conoce Flutter widgets, sockets ni ficheros.

**Patrón de comandos unificado**: teclado, pedal, gestos, mando remoto y voz producen el mismo `PrompterCommand` (sealed class) que viaja también por la red. `PrompterController.execute` es el único punto que muta estado, así que todas las entradas se comportan igual.

## 3. Pipeline de render (Módulo A)

1. **Maquetación una vez**: `ScriptLayout.build` crea un `TextPainter` por bloque al cambiar tamaño, fuente, interlineado o margen; en el mismo paso registra la Y de cada palabra, pausa, cue y sección.
2. **Bucle**: `ScrollEngine` usa un `Ticker` (VSync del compositor, 60/90/120 Hz). Cada tick integra `offset += v·dt`, con `dt` real acotado a 250 ms. La velocidad sigue a la objetivo con un filtro exponencial (τ = 0.22 s), así que play/pause tienen inercia y no saltan. Los saltos (±5 s, secciones) decaen exponencialmente (τ = 0.12 s). El Ticker se para en reposo (0 % de CPU).
3. **Pintado**: `CustomPaint(painter: PrompterPainter(repaint: engine))` dentro de un `RepaintBoundary`. El tick solo marca esa capa como sucia, sin `build()` ni re-maquetación. El pintor traslada el canvas, dibuja solo los bloques visibles (culling) y ajusta el offset al píxel físico para evitar el *shimmer* del texto.
4. **Mirroring**: `canvas.scale(-1, 1)` / `(1, -1)`. Es una transformación afín sin texturas intermedias y sin coste por frame.
5. **HUD**: se refresca a 4 Hz con su propio timer y no por frame.

Sin tearing: Flutter presenta en el VSync del compositor (Wayland/X11 vía GTK en Linux; SurfaceFlinger en Android).

Presupuesto por frame típico: avance del motor < 0.05 ms y pintado de 2–4 bloques visibles < 1 ms en el hilo de raster.

### Pausas, cues y tiempo restante
* `[PAUSE 2s]`: el motor se detiene **exactamente** sobre la marca, descuenta el tiempo y reanuda solo (`autoPaused`).
* `[PAUSE]`: se mantiene (`holding`) hasta Play.
* Tiempo restante = palabras restantes / WPM + pausas automáticas pendientes + pausa en curso.

## 4. Sincronización multi-dispositivo (Módulo C)

Ver `docs/PROTOCOL.md`. Resumen: el prompter (Linux, o Android en modo prompter) aloja el servidor WS mientras la vista está abierta. El mando Android descubre por UDP, se empareja por PIN y envía comandos. Recibe snapshots en **palabras** y extrapola entre ellos.

Pedales Bluetooth: llegan como teclado HID (PgUp/PgDn/Space/flechas/media keys) y se mapean en `input/pedal_shortcuts.dart`. Funcionan conectados al Linux o al teléfono que hace de mando, porque `PrompterShortcuts` envuelve las dos vistas.

## 5. Voz local (Módulo D)

```
Micro 16 kHz ─▶ VAD (Kaldi en Vosk) ─▶ STT streaming (parciales ~150 ms)
      ─▶ VoiceAligner (Levenshtein, ventana −12/+60 palabras, sesgo de cercanía)
      ─▶ ScrollEngine.followWord(i) ─▶ feed-forward de velocidad del habla + P (K = 2.5)
```

* **Motor elegido: Vosk** (Apache 2.0, offline, streaming con parciales, modelos pequeños de unos 40–50 MB por idioma, con bindings para Android y C). Whisper.cpp tiene mejor precisión, pero procesa por ventanas de varios segundos y su latencia o coste de CPU es demasiado alto para seguir palabra a palabra en ARM. Puede añadirse como `SpeechRecognizer` alternativo.
* **Control**: el motor estima la velocidad del habla (EMA entre reconocimientos) y la suma como feed-forward, así que el texto no va siempre detrás. El error se corrige con amortiguamiento crítico (4·τ·K = 1), sin sobrepaso. Una zona muerta impide que el texto retroceda por fluctuaciones; solo un retroceso real del orador (más de una línea) lo hace volver. Si no hay reconocimiento durante 1.5 s, el feed-forward se anula y el texto se detiene con el orador.
* **Gramática restringida**: al arrancar se pasa a Vosk la lista JSON de palabras del guion más `[unk]`. El modelo pequeño solo elige entre esas palabras, con más precisión y menos latencia.

### Contrato del canal

| Canal | Mensaje | Respuesta |
|---|---|---|
| `MethodChannel("promptflow/stt")` | `isAvailable {modelPath}` | `bool`: librería, audio y modelo presentes |
| | `start {modelPath, grammar?}` | `null` cuando el micro ya está abierto; error `stt_unavailable`, `stt_no_model` o `stt_start_failed` |
| | `stop` | `null` |
| `EventChannel("promptflow/stt/events")` | `{"raw": "<json de Vosk>", "final": bool}` | Errores del stream con código `stt_error` (p. ej. el micro se desconecta) |

### Linux (implementado): `linux/runner/vosk_stt_plugin.cc`
* `libvosk.so` (empaquetada en `bundle/lib/`, o del sistema) y `libpulse-simple.so.0` se cargan con **dlopen**. La app compila y arranca sin ellas: `isAvailable` devuelve `false` y se oculta el botón de voz.
* Captura con la API *simple* de PulseAudio, que en PipeWire funciona vía `pipewire-pulse`: 16 kHz, S16LE, mono, en bloques de 100 ms (`fragsize` = 3200 B) para que los parciales lleguen pronto.
* Un hilo de trabajo carga el modelo (se conserva entre `start`/`stop`), lee audio y llama a `accept_waveform`. Solo envía parciales cuando cambian. Los eventos se pasan al hilo principal con `g_idle_add`, porque GTK y Flutter no son *thread-safe*. `start` responde desde el hilo cuando todo está listo, así la carga del modelo no congela la UI.
* Instalación: `tool/setup_vosk_linux.sh` descarga `libvosk` 0.3.45 (x86_64/aarch64) en `linux/third_party/vosk/` (CMake la copia al bundle) y `vosk-model-small-es-0.42` en `<documentos>/PromptFlow/models/vosk-es`.
* Pruebas sin micrófono: con `PROMPTFLOW_STT_WAV=<wav 16 kHz mono>` el plugin lee el WAV a ritmo real. Lo usa `integration_test/vosk_linux_test.dart`.

Medido en desarrollo: el micrófono se abre y el modelo español carga en ~0,25 s; `stop` tarda ~80 ms. La transcripción del WAV de ejemplo de Vosk coincide palabra por palabra con `libvosk` usada directamente.

### Android (pendiente)
Plugin Kotlin con `com.alphacephei:vosk-android` y `SpeechService(recognizer, 16000f)`. Debe cumplir el mismo contrato: emitir `{"raw","final"}` desde `onPartialResult`/`onResult`.

## 6. Formato de guion

```markdown
# Título del programa
## Sección (destino de salto)
[CAM 1] Texto con **énfasis** y ==resaltado==. [PAUSE 2s]
[CUE Entrevista] Pausa manual hasta Play: [PAUSE]
<!-- comentario no visible -->
```
En `.txt` solo se interpretan las etiquetas entre corchetes.

## 7. Pendiente / siguientes pasos

* Plugin nativo Vosk para Android (el de Linux ya está), descrito en §5.
* Mantener la pantalla encendida: `wakelock_plus` en `PrompterScreen`.
* Rol `follower`: un segundo dispositivo que muestra el mismo guion siguiendo `state.snapshot` (el protocolo ya transmite posición en palabras).
* Empaquetado: Flatpak/AppImage (Linux) y AAB firmado (Android); `flutter build linux --target-platform linux-arm64` para ARM64.
* Persistir `PrompterSettings` por dispositivo.
