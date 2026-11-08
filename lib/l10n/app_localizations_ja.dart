// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String commonError(String message) {
    return 'エラー: $message';
  }

  @override
  String get homeImport => '.txt / .md をインポート';

  @override
  String get homeRemote => 'リモコン';

  @override
  String get homeNewScript => '新規原稿';

  @override
  String homeEditScript(String title) {
    return '$title を編集';
  }

  @override
  String get homeSampleFileName => 'sanpuru.md';

  @override
  String get homeSampleScript =>
      '# サンプル原稿\n\n## オープニング\n[CAM 1] こんにちは。PromptFlow へ**ようこそ**。このサンプル原稿では、\n使用できるマーカーを紹介します。[PAUSE 2s]\n\n強調したい言葉は**太字**に、大切な部分は\n==ハイライト==にできます。\n\n## デモ\n[CAM 2] [CUE Demo] ここでカメラを切り替えます。自動ポーズではテキストが\n数秒間止まり、その後自動的に再開します。[PAUSE 1.5s]\n\n時間指定のないポーズでは、再生を押すまでテキストが止まります。[PAUSE]\n\n## エンディング\n[CAM 1] ご覧いただきありがとうございました。プロンプターは**リモコン**モードでスマートフォンから、\nまたは Bluetooth ペダルで操作できます。\n';

  @override
  String get editorNameHint => 'name.md';

  @override
  String get editorSave => '保存 (Ctrl+S)';

  @override
  String get editorRehearse => 'プロンプターでリハーサル';

  @override
  String editorSavedTo(String path) {
    return '$path に保存しました';
  }

  @override
  String get editorUnsavedTitle => '未保存の変更';

  @override
  String get editorUnsavedBody => '保存せずに終了しますか？';

  @override
  String get editorLeave => '終了';

  @override
  String get editorBodyHint =>
      '# タイトル\n\n## セクション\n[CAM 1] **強調**を含む原稿テキスト。[PAUSE 2s]';

  @override
  String get editorBold => '太字';

  @override
  String get editorHighlight => 'ハイライト';

  @override
  String get editorSection => '## セクション';

  @override
  String get editorPause2s => 'ポーズ 2 秒';

  @override
  String get editorPauseManual => '手動ポーズ';

  @override
  String get editorCue => 'キュー';

  @override
  String get editorCueSnippet => '[CUE 名前] ';

  @override
  String editorStats(int words, int markers) {
    return '$words 語 · マーカー $markers 個';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return '$wpm WPM での所要時間: $duration';
  }

  @override
  String get editorTargetHint => '目標時間';

  @override
  String get editorNoTarget => '目標なし';

  @override
  String editorMinutes(int minutes) {
    return '$minutes 分';
  }

  @override
  String get editorPausesExceedTarget => 'ポーズの合計が目標時間を超えています';

  @override
  String editorNeededWpm(int wpm) {
    return '$wpm WPM が必要です';
  }

  @override
  String get prompterExit => '終了 (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'リモコン $count 台',
      zero: 'リモコンなし',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'サーバーを停止しました';

  @override
  String prompterServerPortError(int port, String message) {
    return 'ポート $port を開けませんでした: $message';
  }

  @override
  String get prompterBack5 => '5 秒戻る (Page Up)';

  @override
  String get prompterForward5 => '5 秒進む (Page Down)';

  @override
  String get prompterPlay => '再生 (Space)';

  @override
  String get prompterPause => '一時停止 (Space)';

  @override
  String get prompterSlower => '遅く (↓)';

  @override
  String get prompterFaster => '速く (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · 残り $remaining';
  }

  @override
  String get prompterVoiceOn => '音声に追従';

  @override
  String get prompterVoiceOff => '音声追従をオフ';

  @override
  String get prompterGoToSection => 'セクションへ移動';

  @override
  String get prompterSettings => '設定 (S)';

  @override
  String get statusPlaying => '再生中';

  @override
  String statusAutoPaused(String seconds) {
    return 'ポーズ $seconds 秒';
  }

  @override
  String get statusAutoPausedShort => '自動ポーズ';

  @override
  String get statusHolding => '一時停止中 — 再生を押してください';

  @override
  String get statusHoldingShort => '原稿内のポーズ';

  @override
  String get statusFinished => '終了';

  @override
  String get statusStopped => '停止中';

  @override
  String get settingsFontSize => 'フォントサイズ';

  @override
  String get settingsLineHeight => '行間';

  @override
  String get settingsMargin => '左右の余白';

  @override
  String get settingsFocusLine => 'フォーカスライン';

  @override
  String get settingsSpeed => '速度';

  @override
  String get settingsTextColor => '文字色';

  @override
  String get settingsWhite => '白';

  @override
  String get settingsYellow => '黄';

  @override
  String get settingsMirrorH => '左右反転 (H)';

  @override
  String get settingsMirrorV => '上下反転 (V)';

  @override
  String get settingsFocusGuide => 'フォーカスラインのガイド';

  @override
  String get voiceTitle => '音声追従';

  @override
  String get voiceLanguage => '音声の言語';

  @override
  String voiceStatusDownloading(int percent) {
    return 'ダウンロード中 $percent%';
  }

  @override
  String get voiceStatusInstalling => 'モデルをインストール中…';

  @override
  String get voiceStatusReady => '準備完了: HUD のマイクを押すと、テキストが音声に合わせて進みます';

  @override
  String get voiceStatusNoEngine =>
      'モデルはインストール済みですが、Vosk エンジンがありません（Linux: tool/setup_vosk_linux.sh）';

  @override
  String voiceStatusNoModel(int size) {
    return 'モデル未インストール（$size MB、ダウンロードは初回のみ）';
  }

  @override
  String voiceDownload(int size) {
    return 'モデルをダウンロード（$size MB）';
  }

  @override
  String voiceDownloadPrompt(String language, int size) {
    return '音声追従には$languageの音声モデル（$size MB）が必要です。ダウンロードは一度だけで、その後はオフラインで動作します。言語は「設定 → 音声」で変更できます。';
  }

  @override
  String get voiceErrorNoModel => '「設定 → 音声」で音声モデルをダウンロードしてください';

  @override
  String get voiceErrorNoEngine =>
      'Vosk がインストールされていません（tool/setup_vosk_linux.sh）';

  @override
  String get voiceErrorPermission =>
      'マイクの権限が拒否されました。音声追従を使うには、システム設定で許可してください。';

  @override
  String voiceErrorDownload(String message) {
    return 'モデルをダウンロードできませんでした: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return '音声認識エラー: $message';
  }

  @override
  String get remoteTitle => 'リモコン';

  @override
  String get remoteConnectTitle => 'プロンプターに接続';

  @override
  String get remoteReconnecting => '再接続中…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => '切断';

  @override
  String get remotePinRequired => 'プロンプターに表示されている 4 桁の PIN を入力してください';

  @override
  String get remoteBadPin => 'PIN が正しくありません';

  @override
  String remoteConnectFailed(String message) {
    return '接続できませんでした: $message';
  }

  @override
  String get remotePinLabel => 'プロンプターの PIN';

  @override
  String get remoteOnLan => 'ローカルネットワーク上';

  @override
  String get remoteSearch => '検索';

  @override
  String get remoteNoneFound =>
      'プロンプターが見つかりません。Linux パソコンで起動するか、IP を手動で入力してください。';

  @override
  String get remoteManualIp => 'IP を手動入力（例: 192.168.1.20）';

  @override
  String get remoteConnect => '接続';

  @override
  String get remotePosition => '原稿内の位置';

  @override
  String remoteRemaining(String remaining) {
    return '残り $remaining';
  }

  @override
  String get remoteBack5 => '5 秒戻る';

  @override
  String get remoteForward5 => '5 秒進む';

  @override
  String get remotePlay => '再生';

  @override
  String get remotePause => '一時停止';

  @override
  String get remoteSlower => '遅く';

  @override
  String get remoteFaster => '速く';

  @override
  String get remoteMirrorH => '左右反転';

  @override
  String get remoteMirrorV => '上下反転';

  @override
  String get remoteFollowVoice => '音声追従';

  @override
  String get remoteStart => '先頭へ';

  @override
  String get remoteSections => 'セクションとキュー';

  @override
  String get remoteChangeScript => '原稿を変更';

  @override
  String get aboutTitle => 'このアプリについて';

  @override
  String aboutVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get aboutTagline =>
      'Linux と Android 向けのプロンプター：滑らかなスクロール、ローカルネットワーク経由のリモコン、オフラインの音声追従。';

  @override
  String get aboutCreatedBy => '作者';

  @override
  String get aboutFollow => 'フォロー';

  @override
  String get aboutProject => 'プロジェクト';

  @override
  String get aboutSourceCode => 'ソースコード';

  @override
  String get aboutContribute => 'コントリビュート';

  @override
  String get aboutLicense => 'MIT ライセンス';

  @override
  String get aboutVoiceCredit => 'オフライン音声認識：Vosk（Apache 2.0）';

  @override
  String get aboutLicenses => 'オープンソースライセンス';

  @override
  String aboutOpenFailed(String url) {
    return '$url を開けませんでした';
  }
}
