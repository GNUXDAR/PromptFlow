# PromptFlow

> Traduit de l'original en espagnol. En cas de divergence, l'[original](../../../README.md) fait foi.

Téléprompteur pour Linux et Android : défilement fluide à la fréquence de l'écran, miroir H/V, pauses et repères (cues) dans le script, télécommande via le réseau local (WebSocket), pédales Bluetooth et suivi vocal local (Vosk).

```bash
flutter pub get
flutter run -d linux          # prompteur + serveur de contrôle
flutter run -d <android-id>   # prompteur ou télécommande
flutter test                  # moteur, parser, protocole (sockets réels) et voix
```

### Suivi vocal (facultatif, hors ligne)

Le texte avance au rythme de votre voix grâce à [Vosk](https://alphacephei.com/vosk/), une reconnaissance vocale locale. Des modèles existent pour 11 langues : es, en, pt, fr, de, it, ru, zh, ja, ko et hi.

- **Android :** ouvrez un script et allez dans **Paramètres → Voix**. Choisissez la langue, appuyez sur *Télécharger le modèle* puis sur le micro du HUD. La première fois, l'application demande l'autorisation d'accéder au micro.
- **Linux :** installez le moteur une fois, puis téléchargez le modèle depuis l'application ou avec le script :
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + modèle espagnol
  flutter run -d linux
  ```
  Le micro par défaut de PulseAudio/PipeWire est utilisé.

* Architecture et justification de la stack : [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)
* Protocole WebSocket/UDP : [`docs/PROTOCOL.md`](../en/PROTOCOL.md)
* Moteur de défilement : [`lib/engine/scroll_engine.dart`](../../../lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](../../../lib/engine/prompter_painter.dart)

## Raccourcis (clavier et pédale)

| Touche | Action |
|---|---|
| Espace / Entrée / Lecture-Pause | Lire / mettre en pause |
| Page préc. / ← | Reculer de 5 s |
| Page suiv. / → | Avancer de 5 s |
| ↑ / ↓ | ±10 WPM |
| H / V | Miroir horizontal / vertical |
| + / − | Taille du texte |
| Origine | Revenir au début |
| S | Paramètres |
| Échap | Quitter |

Gestes sur l'écran tactile : double appui pour lire ou mettre en pause, glissement vertical pour parcourir le script et appui simple pour afficher le HUD.

## Contribuer

Les contributions sont les bienvenues ! Code, tests sur du matériel réel, documentation, traductions ou idées : tout compte.

**Lisez d'abord le [guide de contribution](CONTRIBUTING.md).** L'essentiel :

1. Créez une nouvelle branche à partir de `develop` au format `type/description` (`feat/…`, `fix/…`, `docs/…`, `i18n/…`).
2. Ouvrez la pull request **vers `develop`**. `main` ne reçoit que les versions publiées.
3. Avant de l'envoyer : `flutter analyze` sans avertissement et `flutter test` au vert.

### Par où commencer

- **Affiner le suivi vocal** avec de vrais enregistrements dans différentes langues (gain, zone morte, fenêtre de l'aligneur).
- **Modèle vocal en arabe** adapté au mobile, si un modèle léger apparaît.
- **Rôle `follower`** : un second appareil qui affiche le script en suivant le prompteur principal.
- **Écran toujours allumé** pendant la lecture (`wakelock_plus`).
- **Empaquetage** : Flatpak ou AppImage pour Linux et builds Android.
- **Tests sur appareils réels** : pédales Bluetooth, tablettes, Raspberry Pi (ARM64) et réseaux Wi‑Fi avec isolation.

Vous avez trouvé un bug ou vous avez une idée ? Ouvrez une [issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose).

## Licence

[MIT](../../../LICENSE) © 2026 Arturo Cabrera. En contribuant, vous acceptez que votre contribution soit publiée sous cette même licence.
