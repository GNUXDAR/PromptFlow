# PromptFlow 기여 가이드

> [스페인어 원문](../../../CONTRIBUTING.md)에서 번역한 문서입니다. 내용이 다를 경우 원문이 우선합니다.

PromptFlow에 관심을 가져 주셔서 감사합니다! 이 가이드는 오타 수정부터 완전한 기능 추가까지, 변경 사항을 제안하는 방법을 설명합니다. 처음에는 처음부터 끝까지 읽고, 이후에는 필요한 섹션별로 참고하도록 구성했습니다.

> **참고:** 오픈 소스 프로젝트에 처음 기여하는 것이라면 모든 것을 완벽하게 하려고 걱정하지 마세요. 좋은 의도로 만든 작은 PR이 아무것도 없는 것보다 낫습니다. 나머지는 리뷰에서 도와드리겠습니다.

## 목차

1. [기여하는 방법](#기여하는-방법)
2. [시작하기 전에](#시작하기-전에)
3. [환경 준비](#환경-준비)
4. [브랜치 모델](#브랜치-모델)
5. [변경하기](#변경하기)
6. [커밋 메시지](#커밋-메시지)
7. [Pull Request 열기](#pull-request-열기)
8. [리뷰 과정](#리뷰-과정)
9. [머지 이후](#머지-이후)
10. [번역](#번역)
11. [에티켓과 행동 강령](#에티켓과-행동-강령)
12. [도움 받기](#도움-받기)

---

## 기여하는 방법

코드만 기여가 아닙니다. 다음은 모두 소중한 기여입니다:

| 유형 | 예시 |
|---|---|
| **오류 보고** | 무언가 동작하지 않거나, 이상하게 보이거나, 여러분의 기기에서 스크롤이 부드럽지 않음. |
| **아이디어 제안** | 새로운 기능, 단축키, 대본 형식. |
| **코드** | 수정, 기능, 성능, 테스트. |
| **문서** | 오타, 설명 보완, 예시, 다이어그램. |
| **번역** | 새로운 언어 또는 기존 언어 개선([아래 참고](#번역)). |
| **하드웨어 테스트** | 블루투스 페달, 태블릿, Raspberry Pi, 클라이언트 격리가 적용된 Wi‑Fi 네트워크. |
| **PR 리뷰** | 다른 사람의 PR을 테스트하고 확인한 내용을 코멘트로 남기기. |

## 시작하기 전에

### 이미 있는지 검색하기

issue를 열거나 코드를 작성하기 전에 열려 있는 [issues](https://github.com/GNUXDAR/PromptFlow/issues)와 [pull requests](https://github.com/GNUXDAR/PromptFlow/pulls)를 검색하세요. 누군가 이미 같은 작업을 하고 있다면, 노력이 중복되지 않도록 그곳에 코멘트를 남겨 주세요.

### 큰 변경은 issue를 먼저 열기

| 변경 규모 | 먼저 issue가 필요한가요? |
|---|---|
| 오타, 깨진 링크, 헷갈리는 문장 | 아니요: 바로 PR을 여세요. |
| 작고 명확한 버그 수정 | 권장하지만 필수는 아닙니다. |
| 새 기능, 동작 변경, 프로토콜 또는 아키텍처 변경 | **예.** 접근 방식을 미리 합의하면 설계상의 의견 차이로 작업이 거절되는 일을 막을 수 있습니다. |

> **팁:** 다른 사람이 같은 작업을 가져가지 않도록 issue에 "제가 맡겠습니다"라고 코멘트하세요. 나중에 계속할 수 없게 되면 알려 주세요. 괜찮습니다.

### 처음 시작하기 좋은 issue

`good first issue` 라벨이 붙은 issue는 범위가 한정되어 있고 처음 오는 사람을 위해 설명되어 있습니다. `help wanted` 라벨이 붙은 issue는 중요하며 자원봉사자를 찾고 있습니다.

## 환경 준비

### 요구 사항

- [Flutter](https://docs.flutter.dev/get-started/install) stable(Dart 3).
- Linux: Flutter 데스크톱 의존성(`clang`, `cmake`, `ninja-build`, `libgtk-3-dev`).
- Android(선택 사항): Android SDK와 기기 또는 에뮬레이터.

### 포크와 클론

```bash
# 1. GitHub에서 포크하고(「Fork」 버튼) 클론합니다
git clone https://github.com/<사용자-이름>/PromptFlow.git
cd PromptFlow

# 2. 원본 저장소를 「upstream」으로 추가합니다
git remote add upstream https://github.com/GNUXDAR/PromptFlow.git

# 3. 의존성을 설치하고 모든 것이 동작하는지 확인합니다
flutter pub get
flutter analyze
flutter test
```

### 음성 (선택 사항)

```bash
tool/setup_vosk_linux.sh      # libvosk + Linux용 스페인어 모델
```

## 브랜치 모델

| 브랜치 | 용도 | 누가 쓰나요? |
|---|---|---|
| `main` | 배포된 버전. 항상 안정적. | 메인테이너만, 버전을 배포할 때. |
| `develop` | 다음에 배포될 내용의 통합. **모든 PR의 대상.** | 아무도 직접 쓰지 않음: PR을 통해서만. |
| `tipo/descripcion` | 여러분의 작업. 주제마다 브랜치 하나. | 여러분. |

> **중요:** `main`이나 `develop`에 직접 커밋하지 말고, `main`을 대상으로 PR을 열지 마세요. 모든 변경은 `develop`으로 향하는 PR을 통해 들어갑니다.

### 브랜치 이름

`tipo/descripcion-corta` 형식을 소문자와 하이픈으로 사용하세요:

| 접두사 | 용도 | 예시 |
|---|---|---|
| `feat/` | 새 기능 | `feat/follower-mode` |
| `fix/` | 버그 수정 | `fix/pause-marker-skip` |
| `docs/` | 문서만 | `docs/protocol-examples` |
| `i18n/` | 번역 | `i18n/add-turkish` |
| `perf/` | 성능 | `perf/painter-culling` |
| `refactor/` | 동작 변경 없는 재구성 | `refactor/controller-commands` |
| `test/` | 테스트만 | `test/remote-reconnect` |
| `chore/` | 빌드, 의존성, CI | `chore/bump-flutter` |

```bash
git fetch upstream
git switch -c fix/pause-marker-skip upstream/develop
```

## 변경하기

### PR 하나에 주제 하나

PR은 **한 가지 일만** 해야 합니다. 버그를 고치다가 다른 버그를 발견했다면 PR을 두 개 여세요. 작은 PR일수록 더 빨리, 더 꼼꼼하게 리뷰됩니다.

| 규모 | 권장 사항 |
|---|---|
| < 200줄 | 이상적. |
| 200–600줄 | 허용됨. 설명에서 구조를 잘 설명해 주세요. |
| > 600줄 | 여러 PR로 나누거나, issue를 열어 나눌 부분을 계획하세요. |

### 아키텍처 준수

코드를 건드리기 전에 [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)를 읽어 주세요. 리뷰에서 가장 많이 확인하는 규칙은 다음과 같습니다:

- `domain/`은 Flutter 위젯, 소켓, 파일에 의존하지 않습니다.
- 모든 제어 동작은 `PrompterCommand`이며, 키보드·페달·리모컨·음성 중 어디에서 오든 `PrompterController.execute`를 거칩니다.
- 애니메이션 루프 안에서는 프레임마다 위젯을 다시 빌드하지 않습니다.
- 프로토콜을 변경하면 [`docs/PROTOCOL.md`](../en/PROTOCOL.md)를 업데이트하세요. 호환성을 깨는 변경이라면 `v` 필드를 올리세요.
- 사용자에게 보이는 텍스트는 `lib/l10n/`에 두고, 절대 코드에 직접 쓰지 않습니다([번역](#번역) 참고).

### 테스트

- 모든 버그 수정에는 그 수정이 없으면 실패하는 테스트가 있어야 합니다.
- 로직이 있는 모든 새 기능(엔진, 파서, 프로토콜, 음성)에는 테스트가 있어야 합니다.
- 스크롤 엔진에는 `ScrollEngine.manual()`과 `advance()`를 사용하세요: 테스트가 결정적이며 시계에 의존하지 않습니다.

### 푸시하기 전에

```bash
dart format lib test integration_test
flutter analyze        # 경고 없음
flutter test           # 모두 통과
```

## 커밋 메시지

[Conventional Commits](https://www.conventionalcommits.org/ko/v1.0.0/)를 사용합니다:

```
유형(범위): 명령형으로 쓴 요약, 끝에 마침표 없음

선택적 본문: 변경의 '어떻게'가 아니라 '왜'.
줄은 약 72자에서 줄바꿈합니다.

Fixes #123
```

- **유형**: `feat`, `fix`, `docs`, `i18n`, `perf`, `refactor`, `test`, `chore`.
- **범위**(선택 사항): `engine`, `parser`, `remote`, `voice`, `editor`, `android`, `linux`, `l10n`…

| ✅ 좋은 예 | ❌ 나쁜 예 |
|---|---|
| `fix(engine): stop exactly on pause markers at high WPM` | `arreglos` |
| `feat(remote): add follower role to the protocol` | `cambios varios en remote y engine y docs` |
| `docs(protocol): document cmd.goto payload` | `Update PROTOCOL.md` |

> **참고:** 머지할 때 브랜치의 커밋은 하나로 합쳐지므로(*squash*), 가장 중요한 것은 최종 커밋 메시지가 되는 **PR 제목**입니다.

## Pull Request 열기

### 1. 브랜치 업데이트

```bash
git fetch upstream
git rebase upstream/develop
git push origin fix/pause-marker-skip
```

### 2. `develop`을 대상으로 PR 만들기

GitHub에서 「Compare & pull request」를 누르고 다음을 확인하세요:

- **base repository:** `GNUXDAR/PromptFlow`, **base:** `develop`
- **head repository:** 여러분의 포크, **compare:** 여러분의 브랜치

### 3. 제목

커밋과 같은 형식을 따릅니다: `유형(범위): 요약`. 이것이 최종 커밋의 메시지가 됩니다.

### 4. 설명

PR 템플릿이 자동으로 채워집니다. 좋은 PR은 네 가지 질문에 답합니다:

1. **무엇이 바뀌나요?** 한두 문장으로 된 요약.
2. **왜인가요?** 해결하는 문제와 issue 링크: `Fixes #123`(머지 시 닫힘) 또는 `Refs #123`(언급만 함).
3. **어떻게 테스트하나요?** 리뷰어가 결과를 재현할 수 있는 구체적인 단계.
4. **무엇을 확인했나요?** 템플릿의 체크리스트를 정직하게 체크하세요. 테스트하지 못한 것이 있다면(예: Android 기기가 없는 경우) 그렇다고 적어 주세요.

시각적인 변경이라면 **변경 전과 후**의 스크린샷이나 짧은 동영상을 추가하세요.

> **좋은 설명의 예**
>
> 300 WPM을 넘는 속도에서 두 마커가 같은 줄에 있으면 엔진이 `[PAUSE 2s]` 마커를 건너뛰었습니다. 프레임마다 마커를 하나만 처리했기 때문입니다.
>
> Fixes #42
>
> **테스트 방법:** `test/fixtures/double_pause.md`를 350 WPM으로 엽니다. 두 번 멈춰야 합니다.
>
> - [x] 새 테스트 `pausa doble en la misma línea`(수정 없이는 실패)
> - [x] `flutter analyze` / `flutter test`
> - [ ] Android에서 테스트함(기기가 없음)

### 5. 초안 PR

완성되지 않은 작업에 대해 일찍 의견을 받고 싶다면 PR을 **Draft**로 여세요. 준비가 되면 「Ready for review」로 표시하세요.

### 6. 다른 PR에 의존하는 PR (스택)

여러분의 PR이 아직 머지되지 않은 다른 PR을 필요로 한다면, 그 PR의 브랜치를 base로 설정하고 설명에 "#12에 의존"이라고 적어 주세요. 첫 번째 PR이 머지되면 GitHub가 자동으로 base를 `develop`으로 바꿉니다.

## 리뷰 과정

### 예상할 수 있는 것

- **약 7일 이내**에 첫 응답이 있습니다. 2주 넘게 소식이 없다면 PR에 코멘트를 남겨 상기시켜 주세요. 환영합니다.
- 제안이 담긴 코멘트가 하나 이상 달립니다. 이는 정상이며 PR이 나쁘다는 뜻이 아닙니다.
- 자동 검사(분석과 테스트)를 통과해야 합니다.

### 코멘트에 응답하기

- 같은 브랜치에 **새 커밋**으로 변경하세요. 누군가 리뷰한 뒤에는 히스토리를 다시 쓰지 마세요(`push --force`): 그래야 리뷰어가 바뀐 부분만 볼 수 있습니다.
- 각 코멘트에 답하세요: "abc123에서 반영했습니다" 또는 다른 방안을 제안하는 이유를 설명합니다. 근거를 들어 반대 의견을 내는 것도 좋은 리뷰의 일부입니다.
- 대화를 시작한 사람이 그 대화를 해결됨으로 표시합니다.

### 승인 기준

PR은 다음 조건을 만족하면 머지됩니다:

- [ ] 한 가지 일만 하고, 설명에 무엇을 왜 하는지가 나와 있다.
- [ ] 이 가이드의 아키텍처와 규칙을 지킨다.
- [ ] 새 로직에 테스트가 있고 모든 검사를 통과한다.
- [ ] 인터페이스 텍스트가 `lib/l10n/`에 있다.
- [ ] 영향을 받는 문서가 업데이트되었다.
- [ ] 최소 한 명의 메인테이너가 승인했다.

머지는 메인테이너가 `develop`에 **Squash and merge**로 수행합니다.

## 머지 이후

- 브랜치를 삭제하세요(GitHub에 버튼이 있습니다).
- 포크를 동기화하세요:
  ```bash
  git switch develop
  git fetch upstream
  git merge --ff-only upstream/develop
  git push origin develop
  ```
- 여러분의 변경 사항은 다음 배포 버전에서 `main`에 들어갑니다.

## 번역

인터페이스 텍스트는 `lib/l10n/app_<언어>.arb`에 있습니다. 기준 파일은 `app_en.arb`입니다.

- **번역 수정:** 해당 언어의 `.arb`를 편집하고 `i18n/…` PR을 여세요.
- **언어 추가:** `app_en.arb`를 `app_<코드>.arb`로 복사하고, **값만** 번역한 뒤(키나 `{placeholders}`는 절대 번역하지 않음) `flutter gen-l10n`으로 확인하세요.
- **번역된 문서:** `docs/i18n/<언어>/`에 있습니다. 스페인어 원문이 우선합니다: 문서를 변경했다면 번역이 오래된 상태가 된다는 것을 PR에서 알리거나, 번역도 업데이트하세요.

## 에티켓과 행동 강령

이 프로젝트는 [Contributor Covenant 2.1](https://www.contributor-covenant.org/ko/version/2/1/code_of_conduct/)을 따릅니다. 요약하면:

- 친절하고 인내심을 가지세요: 모든 PR과 리뷰 뒤에는 자신의 여가 시간을 쓰는 사람이 있습니다.
- 사람이 아니라 코드를 비판하세요.
- 선의를 전제하고, 단정하기 전에 질문하세요.
- 스페인어나 영어 중 편한 언어로 작성하세요.

용납할 수 없는 행동은 기밀로 표시한 issue나 GitHub 다이렉트 메시지를 통해 메인테이너에게 비공개로 알릴 수 있습니다.

## 도움 받기

- **방법을 모르겠을 때:** `question` 라벨을 붙여 issue를 여세요.
- **PR에 관한 질문:** 해당 PR에서 질문하세요.
- **프로젝트 참고 자료:** [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)와 [`docs/PROTOCOL.md`](../en/PROTOCOL.md).

기여해 주셔서 감사합니다! 💛
