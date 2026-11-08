# PromptFlow

> Tradotto dall'originale in spagnolo. In caso di discrepanze, prevale l'[originale](../../../README.md).

Teleprompter per Linux e Android: scorrimento fluido alla frequenza di aggiornamento dello schermo, specchio H/V, pause e cue nel copione, controllo remoto via LAN (WebSocket), pedali Bluetooth e inseguimento vocale locale (Vosk).

```bash
flutter pub get
flutter run -d linux          # prompter + server di controllo
flutter run -d <android-id>   # prompter o telecomando
flutter test                  # motore, parser, protocollo (socket reali) e voce
```

### Inseguimento vocale (opzionale, offline)

Il testo avanza al ritmo della tua voce grazie a [Vosk](https://alphacephei.com/vosk/), un riconoscimento vocale locale. Ci sono modelli per 11 lingue: es, en, pt, fr, de, it, ru, zh, ja, ko e hi.

- **Android:** apri un copione e vai in **Impostazioni → Voce**. Scegli la lingua, tocca *Scarica modello* e poi il microfono dell'HUD. La prima volta l'app chiede il permesso di usare il microfono.
- **Linux:** installa il motore una volta e scarica il modello dall'app o con lo script:
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + modello spagnolo
  flutter run -d linux
  ```
  Viene usato il microfono predefinito di PulseAudio/PipeWire.

* Architettura e motivazione dello stack: [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)
* Protocollo WebSocket/UDP: [`docs/PROTOCOL.md`](../en/PROTOCOL.md)
* Motore di scorrimento: [`lib/engine/scroll_engine.dart`](../../../lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](../../../lib/engine/prompter_painter.dart)

## Scorciatoie (tastiera e pedale)

| Tasto | Azione |
|---|---|
| Spazio / Invio / Play-Pausa | Riproduci / metti in pausa |
| Pag↑ / ← | Indietro di 5 s |
| Pag↓ / → | Avanti di 5 s |
| ↑ / ↓ | ±10 WPM |
| H / V | Specchio orizzontale / verticale |
| + / − | Dimensione del testo |
| Inizio | Torna all'inizio |
| S | Impostazioni |
| Esc | Esci |

Gesti sul touchscreen: doppio tocco per riprodurre o mettere in pausa, trascinamento verticale per scorrere il copione e tocco singolo per mostrare l'HUD.

## Contribuire

I contributi sono benvenuti! Codice, test su hardware reale, documentazione, traduzioni o idee: tutto aiuta.

**Leggi prima la [guida per contribuire](CONTRIBUTING.md).** L'essenziale:

1. Crea un nuovo branch da `develop` nel formato `tipo/descrizione` (`feat/…`, `fix/…`, `docs/…`, `i18n/…`).
2. Apri la pull request **verso `develop`**. `main` riceve solo le versioni pubblicate.
3. Prima di inviarla: `flutter analyze` senza avvisi e `flutter test` tutto verde.

### Da dove iniziare

- **Rifinire l'inseguimento vocale** con registrazioni reali in diverse lingue (guadagno, zona morta, finestra dell'allineatore).
- **Modello vocale in arabo** adatto ai dispositivi mobili, se ne compare uno piccolo.
- **Ruolo `follower`**: un secondo dispositivo che mostri il copione seguendo il prompter principale.
- **Schermo sempre acceso** durante la lettura (`wakelock_plus`).
- **Pacchettizzazione**: Flatpak o AppImage per Linux e build per Android.
- **Test su dispositivi reali**: pedali Bluetooth, tablet, Raspberry Pi (ARM64) e reti Wi‑Fi con isolamento.

Hai trovato un bug o hai un'idea? Apri una [issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose).

## Licenza

[MIT](../../../LICENSE) © 2026 Arturo Cabrera. Contribuendo accetti che il tuo contributo venga pubblicato con questa stessa licenza.
