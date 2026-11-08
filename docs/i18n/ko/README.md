# PromptFlow

> [스페인어 원문](../../../README.md)에서 번역한 문서입니다. 내용이 다를 경우 원문이 우선합니다.

Linux와 Android용 텔레프롬프터: 화면 주사율에 맞춘 부드러운 스크롤, 좌우/상하 미러, 대본 안의 일시정지와 큐, LAN(WebSocket)을 통한 원격 제어, 블루투스 페달, 로컬 음성 추적(Vosk)을 지원합니다.

```bash
flutter pub get
flutter run -d linux          # 프롬프터 + 제어 서버
flutter run -d <android-id>   # 프롬프터 또는 리모컨
flutter test                  # 엔진, 파서, 프로토콜(실제 소켓), 음성
```

### 음성 추적 (선택 사항, 오프라인)

로컬 음성 인식 엔진인 [Vosk](https://alphacephei.com/vosk/) 덕분에 텍스트가 말하는 속도에 맞춰 진행됩니다. 11개 언어의 모델이 있습니다: es, en, pt, fr, de, it, ru, zh, ja, ko, hi.

- **Android:** 대본을 열고 **설정 → 음성**으로 이동합니다. 언어를 선택하고 *모델 다운로드*를 누른 다음 HUD의 마이크를 누릅니다. 처음 사용할 때 앱이 마이크 권한을 요청합니다.
- **Linux:** 엔진을 한 번 설치한 뒤, 앱에서 또는 스크립트로 모델을 다운로드합니다:
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + 스페인어 모델
  flutter run -d linux
  ```
  PulseAudio/PipeWire의 기본 마이크를 사용합니다.

* 아키텍처와 기술 스택 선택 근거: [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)
* WebSocket/UDP 프로토콜: [`docs/PROTOCOL.md`](../en/PROTOCOL.md)
* 스크롤 엔진: [`lib/engine/scroll_engine.dart`](../../../lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](../../../lib/engine/prompter_painter.dart)

## 단축키 (키보드와 페달)

| 키 | 동작 |
|---|---|
| Space / Enter / Play-Pause | 재생 / 일시정지 |
| Page Up / ← | 5초 뒤로 |
| Page Down / → | 5초 앞으로 |
| ↑ / ↓ | ±10 WPM |
| H / V | 좌우 / 상하 미러 |
| + / − | 글자 크기 |
| Home | 처음으로 돌아가기 |
| S | 설정 |
| Esc | 종료 |

터치스크린 제스처: 두 번 탭하면 재생 또는 일시정지, 세로로 드래그하면 대본 스크롤, 한 번 탭하면 HUD 표시.

## 기여하기

기여를 환영합니다! 코드, 실제 하드웨어 테스트, 문서, 번역, 아이디어 등 모든 것이 도움이 됩니다.

**먼저 [기여 가이드](CONTRIBUTING.md)를 읽어 주세요.** 핵심은 다음과 같습니다:

1. `develop`에서 `tipo/descripcion` 형식(`feat/…`, `fix/…`, `docs/…`, `i18n/…`)으로 새 브랜치를 만듭니다.
2. pull request는 **`develop`을 대상으로** 엽니다. `main`은 배포된 버전만 받습니다.
3. 보내기 전에: `flutter analyze`에 경고가 없고 `flutter test`가 모두 통과해야 합니다.

### 어디서부터 시작할까

- **음성 추적 다듬기**: 여러 언어의 실제 녹음으로 조정합니다(게인, 데드 존, 정렬기 윈도우).
- **아랍어 음성 모델**: 모바일에 적합한 작은 모델이 나온다면.
- **`follower` 역할**: 메인 프롬프터를 따라가며 대본을 표시하는 두 번째 기기.
- **읽는 동안 화면 항상 켜기** (`wakelock_plus`).
- **패키징**: Linux용 Flatpak 또는 AppImage, 그리고 Android 빌드.
- **실제 기기 테스트**: 블루투스 페달, 태블릿, Raspberry Pi(ARM64), 클라이언트 격리가 적용된 Wi‑Fi 네트워크.

버그를 발견했거나 아이디어가 있나요? [issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose)를 열어 주세요.

## 라이선스

[MIT](../../../LICENSE) © 2026 Arturo Cabrera. 기여하면 여러분의 기여물이 이와 동일한 라이선스로 공개되는 데 동의하는 것으로 간주합니다.
