// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => '취소';

  @override
  String commonError(String message) {
    return '오류: $message';
  }

  @override
  String get homeImport => '.txt / .md 가져오기';

  @override
  String get homeRemote => '리모컨';

  @override
  String get homeNewScript => '새 대본';

  @override
  String homeEditScript(String title) {
    return '$title 편집';
  }

  @override
  String get homeSampleFileName => 'yeje.md';

  @override
  String get homeSampleScript =>
      '# 예제 대본\n\n## 오프닝\n[CAM 1] 안녕하세요. PromptFlow에 오신 것을 **환영합니다**. 이 예제 대본은\n사용할 수 있는 마커를 보여 줍니다. [PAUSE 2s]\n\n강조할 단어는 **굵게** 표시하고, 중요한 부분은\n==강조 표시==할 수 있습니다.\n\n## 데모\n[CAM 2] [CUE Demo] 이제 카메라를 전환합니다. 자동 일시정지는 텍스트를\n몇 초 동안 멈춘 뒤 저절로 다시 진행합니다. [PAUSE 1.5s]\n\n시간이 지정되지 않은 일시정지는 재생을 누를 때까지 텍스트를 멈춥니다. [PAUSE]\n\n## 마무리\n[CAM 1] 시청해 주셔서 감사합니다. **리모컨** 모드로 휴대폰에서 프롬프터를 제어하거나\n블루투스 페달을 사용해 보세요.\n';

  @override
  String get editorNameHint => 'name.md';

  @override
  String get editorSave => '저장 (Ctrl+S)';

  @override
  String get editorRehearse => '프롬프터에서 리허설';

  @override
  String editorSavedTo(String path) {
    return '$path에 저장됨';
  }

  @override
  String get editorUnsavedTitle => '저장되지 않은 변경사항';

  @override
  String get editorUnsavedBody => '저장하지 않고 나가시겠습니까?';

  @override
  String get editorLeave => '나가기';

  @override
  String get editorBodyHint =>
      '# 제목\n\n## 섹션\n[CAM 1] **강조**가 포함된 대본 텍스트. [PAUSE 2s]';

  @override
  String get editorBold => '굵게';

  @override
  String get editorHighlight => '강조 표시';

  @override
  String get editorSection => '## 섹션';

  @override
  String get editorPause2s => '2초 일시정지';

  @override
  String get editorPauseManual => '수동 일시정지';

  @override
  String get editorCue => '큐';

  @override
  String get editorCueSnippet => '[CUE 이름] ';

  @override
  String editorStats(int words, int markers) {
    return '단어 $words개 · 마커 $markers개';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return '$wpm WPM 기준 길이: $duration';
  }

  @override
  String get editorTargetHint => '목표 길이';

  @override
  String get editorNoTarget => '목표 없음';

  @override
  String editorMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get editorPausesExceedTarget => '일시정지 시간이 목표를 초과합니다';

  @override
  String editorNeededWpm(int wpm) {
    return '$wpm WPM이 필요합니다';
  }

  @override
  String get prompterExit => '나가기 (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '리모컨 $count대',
      zero: '리모컨 없음',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => '서버 중지됨';

  @override
  String prompterServerPortError(int port, String message) {
    return '$port 포트를 열 수 없음: $message';
  }

  @override
  String get prompterBack5 => '5초 뒤로 (Page Up)';

  @override
  String get prompterForward5 => '5초 앞으로 (Page Down)';

  @override
  String get prompterPlay => '재생 (Space)';

  @override
  String get prompterPause => '일시정지 (Space)';

  @override
  String get prompterSlower => '느리게 (↓)';

  @override
  String get prompterFaster => '빠르게 (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · $remaining 남음';
  }

  @override
  String get prompterVoiceOn => '내 음성 따라가기';

  @override
  String get prompterVoiceOff => '음성 따라가기 끄기';

  @override
  String get prompterGoToSection => '섹션으로 이동';

  @override
  String get prompterSettings => '설정 (S)';

  @override
  String get statusPlaying => '재생 중';

  @override
  String statusAutoPaused(String seconds) {
    return '$seconds초 일시정지';
  }

  @override
  String get statusAutoPausedShort => '자동 일시정지';

  @override
  String get statusHolding => '일시정지됨 — 재생을 누르세요';

  @override
  String get statusHoldingShort => '대본 일시정지';

  @override
  String get statusFinished => '끝';

  @override
  String get statusStopped => '중지됨';

  @override
  String get settingsFontSize => '글꼴 크기';

  @override
  String get settingsLineHeight => '줄 간격';

  @override
  String get settingsMargin => '좌우 여백';

  @override
  String get settingsFocusLine => '포커스 라인';

  @override
  String get settingsSpeed => '속도';

  @override
  String get settingsTextColor => '텍스트 색상';

  @override
  String get settingsWhite => '흰색';

  @override
  String get settingsYellow => '노란색';

  @override
  String get settingsMirrorH => '좌우 반전 (H)';

  @override
  String get settingsMirrorV => '상하 반전 (V)';

  @override
  String get settingsFocusGuide => '포커스 라인 가이드';

  @override
  String get voiceTitle => '음성 따라가기';

  @override
  String get voiceLanguage => '음성 언어';

  @override
  String voiceStatusDownloading(int percent) {
    return '다운로드 중 $percent%';
  }

  @override
  String get voiceStatusInstalling => '모델 설치 중…';

  @override
  String get voiceStatusReady => '준비됨: HUD의 마이크를 누르면 텍스트가 음성을 따라갑니다';

  @override
  String get voiceStatusNoEngine =>
      '모델은 설치되었지만 Vosk 엔진이 없습니다(Linux: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return '모델이 설치되지 않음($size MB, 한 번만 다운로드)';
  }

  @override
  String voiceDownload(int size) {
    return '모델 다운로드($size MB)';
  }

  @override
  String get voiceErrorNoModel => '설정 → 음성에서 음성 모델을 다운로드하세요';

  @override
  String get voiceErrorNoEngine =>
      'Vosk가 설치되어 있지 않습니다(tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      '마이크 권한이 거부되었습니다. 음성 따라가기를 사용하려면 시스템 설정에서 허용하세요.';

  @override
  String voiceErrorDownload(String message) {
    return '모델을 다운로드할 수 없음: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return '음성 인식 오류: $message';
  }

  @override
  String get remoteTitle => '리모컨';

  @override
  String get remoteConnectTitle => '프롬프터에 연결';

  @override
  String get remoteReconnecting => '다시 연결 중…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => '연결 끊기';

  @override
  String get remotePinRequired => '프롬프터에 표시된 4자리 PIN을 입력하세요';

  @override
  String get remoteBadPin => '잘못된 PIN';

  @override
  String remoteConnectFailed(String message) {
    return '연결할 수 없음: $message';
  }

  @override
  String get remotePinLabel => '프롬프터 PIN';

  @override
  String get remoteOnLan => '로컬 네트워크';

  @override
  String get remoteSearch => '검색';

  @override
  String get remoteNoneFound =>
      '프롬프터를 찾을 수 없습니다. Linux 컴퓨터에서 실행하거나 IP를 직접 입력하세요.';

  @override
  String get remoteManualIp => 'IP 직접 입력(예: 192.168.1.20)';

  @override
  String get remoteConnect => '연결';

  @override
  String get remotePosition => '대본 내 위치';

  @override
  String remoteRemaining(String remaining) {
    return '$remaining 남음';
  }

  @override
  String get remoteBack5 => '5초 뒤로';

  @override
  String get remoteForward5 => '5초 앞으로';

  @override
  String get remotePlay => '재생';

  @override
  String get remotePause => '일시정지';

  @override
  String get remoteSlower => '느리게';

  @override
  String get remoteFaster => '빠르게';

  @override
  String get remoteMirrorH => '좌우 반전';

  @override
  String get remoteMirrorV => '상하 반전';

  @override
  String get remoteFollowVoice => '음성 따라가기';

  @override
  String get remoteStart => '처음으로';

  @override
  String get remoteSections => '섹션 및 큐';

  @override
  String get remoteChangeScript => '대본 변경';

  @override
  String get aboutTitle => '정보';

  @override
  String aboutVersion(String version) {
    return '버전 $version';
  }

  @override
  String get aboutTagline =>
      'Linux와 Android용 프롬프터: 부드러운 스크롤, 로컬 네트워크 리모컨, 오프라인 음성 추적.';

  @override
  String get aboutCreatedBy => '만든 사람';

  @override
  String get aboutFollow => '팔로우';

  @override
  String get aboutProject => '프로젝트';

  @override
  String get aboutSourceCode => '소스 코드';

  @override
  String get aboutContribute => '기여하기';

  @override
  String get aboutLicense => 'MIT 라이선스';

  @override
  String get aboutVoiceCredit => '오프라인 음성 인식: Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => '오픈 소스 라이선스';

  @override
  String aboutOpenFailed(String url) {
    return '$url을(를) 열 수 없습니다';
  }
}
