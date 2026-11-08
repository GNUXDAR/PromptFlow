# PromptFlow

> Traduzido do original em espanhol. Em caso de divergência, prevalece o [original](../../../README.md).

Teleprompter para Linux e Android: rolagem suave na taxa de atualização da tela, espelhamento H/V, pausas e cues no roteiro, controle remoto pela LAN (WebSocket), pedais Bluetooth e acompanhamento por voz local (Vosk).

```bash
flutter pub get
flutter run -d linux          # prompter + servidor de controle
flutter run -d <android-id>   # prompter ou controle remoto
flutter test                  # motor, parser, protocolo (sockets reais) e voz
```

### Acompanhamento por voz (opcional, offline)

O texto avança no ritmo da sua voz graças ao [Vosk](https://alphacephei.com/vosk/), um reconhecimento de voz local. Há modelos para 11 idiomas: es, en, pt, fr, de, it, ru, zh, ja, ko e hi.

- **Android:** abra um roteiro e vá em **Configurações → Voz**. Escolha o idioma, toque em *Baixar modelo* e depois no microfone do HUD. Na primeira vez, o app pede permissão de microfone.
- **Linux:** instale o motor uma vez e baixe o modelo pelo app ou com o script:
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + modelo em espanhol
  flutter run -d linux
  ```
  É usado o microfone padrão do PulseAudio/PipeWire.

* Arquitetura e justificativa do stack: [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)
* Protocolo WebSocket/UDP: [`docs/PROTOCOL.md`](../en/PROTOCOL.md)
* Motor de rolagem: [`lib/engine/scroll_engine.dart`](../../../lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](../../../lib/engine/prompter_painter.dart)

## Atalhos (teclado e pedal)

| Tecla | Ação |
|---|---|
| Espaço / Enter / Play-Pause | Reproduzir / pausar |
| Page Up / ← | Voltar 5 s |
| Page Down / → | Avançar 5 s |
| ↑ / ↓ | ±10 WPM |
| H / V | Espelhamento horizontal / vertical |
| + / − | Tamanho da fonte |
| Home | Voltar ao início |
| S | Ajustes |
| Esc | Sair |

Gestos na tela sensível ao toque: toque duplo para reproduzir ou pausar, arrastar na vertical para percorrer o roteiro e toque simples para mostrar o HUD.

## Contribuir

Contribuições são bem-vindas! Código, testes em hardware real, documentação, traduções ou ideias: tudo ajuda.

**Leia primeiro o [guia de contribuição](CONTRIBUTING.md).** O essencial:

1. Crie uma branch nova a partir de `develop` no formato `tipo/descricao` (`feat/…`, `fix/…`, `docs/…`, `i18n/…`).
2. Abra o pull request **contra `develop`**. `main` só recebe versões publicadas.
3. Antes de enviar: `flutter analyze` sem avisos e `flutter test` passando.

### Por onde começar

- **Ajustar o acompanhamento por voz** com gravações reais em diferentes idiomas (ganho, zona morta, janela do alinhador).
- **Modelo de voz em árabe** adequado para celular, se surgir um pequeno.
- **Papel `follower`**: um segundo dispositivo que exiba o roteiro acompanhando o prompter principal.
- **Tela sempre ligada** durante a leitura (`wakelock_plus`).
- **Empacotamento**: Flatpak ou AppImage para Linux e builds de Android.
- **Testes em dispositivos reais**: pedais Bluetooth, tablets, Raspberry Pi (ARM64) e redes Wi‑Fi com isolamento.

Encontrou um bug ou tem uma ideia? Abra uma [issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose).

## Licença

[MIT](../../../LICENSE) © 2026 Arturo Cabrera. Ao contribuir, você aceita que sua contribuição seja publicada sob esta mesma licença.
