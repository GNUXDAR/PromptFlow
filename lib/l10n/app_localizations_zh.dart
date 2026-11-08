// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => '取消';

  @override
  String commonError(String message) {
    return '错误：$message';
  }

  @override
  String get homeImport => '导入 .txt / .md';

  @override
  String get homeRemote => '遥控器';

  @override
  String get homeNewScript => '新建脚本';

  @override
  String homeEditScript(String title) {
    return '编辑 $title';
  }

  @override
  String get homeSampleFileName => 'shili.md';

  @override
  String get homeSampleScript =>
      '# 示例脚本\n\n## 开场\n[CAM 1] 你好，**欢迎**使用 PromptFlow。这个示例脚本展示了\n可用的各种标记。[PAUSE 2s]\n\n你可以将词语设为**粗体**以示强调，或在重要之处\n将其==高亮==。\n\n## 演示\n[CAM 2] [CUE Demo] 现在我们切换机位。自动暂停会让文字停留\n几秒钟，然后自动继续。[PAUSE 1.5s]\n\n不带时长的暂停会让文字一直停住，直到你按下播放。[PAUSE]\n\n## 结尾\n[CAM 1] 感谢观看。你可以通过**遥控器**模式用手机控制提词器，\n也可以使用蓝牙踏板。\n';

  @override
  String get editorNameHint => 'name.md';

  @override
  String get editorSave => '保存 (Ctrl+S)';

  @override
  String get editorRehearse => '在提词器中排练';

  @override
  String editorSavedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String get editorUnsavedTitle => '未保存的更改';

  @override
  String get editorUnsavedBody => '不保存就离开？';

  @override
  String get editorLeave => '离开';

  @override
  String get editorBodyHint =>
      '# 标题\n\n## 章节\n[CAM 1] 带有**强调**的脚本文字。[PAUSE 2s]';

  @override
  String get editorBold => '粗体';

  @override
  String get editorHighlight => '高亮';

  @override
  String get editorSection => '## 章节';

  @override
  String get editorPause2s => '暂停 2 秒';

  @override
  String get editorPauseManual => '手动暂停';

  @override
  String get editorCue => '提示点';

  @override
  String get editorCueSnippet => '[CUE 名称] ';

  @override
  String editorStats(int words, int markers) {
    return '$words 个词 · $markers 个标记';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return '按 $wpm WPM 计算时长：$duration';
  }

  @override
  String get editorTargetHint => '目标时长';

  @override
  String get editorNoTarget => '无目标';

  @override
  String editorMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get editorPausesExceedTarget => '暂停时间超过了目标时长';

  @override
  String editorNeededWpm(int wpm) {
    return '需要 $wpm WPM';
  }

  @override
  String get prompterExit => '退出 (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个遥控器',
      zero: '无遥控器',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => '服务器已停止';

  @override
  String prompterServerPortError(int port, String message) {
    return '无法打开端口 $port：$message';
  }

  @override
  String get prompterBack5 => '后退 5 秒 (Page Up)';

  @override
  String get prompterForward5 => '前进 5 秒 (Page Down)';

  @override
  String get prompterPlay => '播放 (Space)';

  @override
  String get prompterPause => '暂停 (Space)';

  @override
  String get prompterSlower => '减速 (↓)';

  @override
  String get prompterFaster => '加速 (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · 剩余 $remaining';
  }

  @override
  String get prompterVoiceOn => '跟随我的语音';

  @override
  String get prompterVoiceOff => '关闭语音跟随';

  @override
  String get prompterGoToSection => '转到章节';

  @override
  String get prompterSettings => '设置 (S)';

  @override
  String get statusPlaying => '正在播放';

  @override
  String statusAutoPaused(String seconds) {
    return '暂停 $seconds 秒';
  }

  @override
  String get statusAutoPausedShort => '自动暂停';

  @override
  String get statusHolding => '已暂停 — 请按播放';

  @override
  String get statusHoldingShort => '脚本暂停';

  @override
  String get statusFinished => '结束';

  @override
  String get statusStopped => '已停止';

  @override
  String get settingsFontSize => '字号';

  @override
  String get settingsLineHeight => '行距';

  @override
  String get settingsMargin => '左右边距';

  @override
  String get settingsFocusLine => '焦点线';

  @override
  String get settingsSpeed => '速度';

  @override
  String get settingsTextColor => '文字颜色';

  @override
  String get settingsWhite => '白色';

  @override
  String get settingsYellow => '黄色';

  @override
  String get settingsMirrorH => '水平镜像 (H)';

  @override
  String get settingsMirrorV => '垂直镜像 (V)';

  @override
  String get settingsFocusGuide => '焦点线指示';

  @override
  String get voiceTitle => '语音跟随';

  @override
  String get voiceLanguage => '语音语言';

  @override
  String voiceStatusDownloading(int percent) {
    return '正在下载 $percent%';
  }

  @override
  String get voiceStatusInstalling => '正在安装模型…';

  @override
  String get voiceStatusReady => '就绪：按下 HUD 中的麦克风，文字将跟随你的语音';

  @override
  String get voiceStatusNoEngine =>
      '模型已安装，但缺少 Vosk 引擎（Linux：tool/setup_vosk_linux.sh）';

  @override
  String voiceStatusNoModel(int size) {
    return '模型未安装（$size MB，只需下载一次）';
  }

  @override
  String voiceDownload(int size) {
    return '下载模型（$size MB）';
  }

  @override
  String get voiceErrorNoModel => '请在“设置 → 语音”中下载语音模型';

  @override
  String get voiceErrorNoEngine => '未安装 Vosk（tool/setup_vosk_linux.sh）';

  @override
  String get voiceErrorPermission => '麦克风权限被拒绝。请在系统设置中允许，以使用语音跟随。';

  @override
  String voiceErrorDownload(String message) {
    return '无法下载模型：$message';
  }

  @override
  String voiceErrorEngine(String message) {
    return '语音识别错误：$message';
  }

  @override
  String get remoteTitle => '遥控器';

  @override
  String get remoteConnectTitle => '连接到提词器';

  @override
  String get remoteReconnecting => '正在重新连接…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => '断开连接';

  @override
  String get remotePinRequired => '请输入提词器上显示的 4 位 PIN';

  @override
  String get remoteBadPin => 'PIN 错误';

  @override
  String remoteConnectFailed(String message) {
    return '无法连接：$message';
  }

  @override
  String get remotePinLabel => '提词器 PIN';

  @override
  String get remoteOnLan => '局域网中';

  @override
  String get remoteSearch => '搜索';

  @override
  String get remoteNoneFound => '未找到提词器。请在 Linux 电脑上打开它，或手动输入 IP。';

  @override
  String get remoteManualIp => '手动输入 IP（例如 192.168.1.20）';

  @override
  String get remoteConnect => '连接';

  @override
  String get remotePosition => '脚本中的位置';

  @override
  String remoteRemaining(String remaining) {
    return '剩余 $remaining';
  }

  @override
  String get remoteBack5 => '后退 5 秒';

  @override
  String get remoteForward5 => '前进 5 秒';

  @override
  String get remotePlay => '播放';

  @override
  String get remotePause => '暂停';

  @override
  String get remoteSlower => '减速';

  @override
  String get remoteFaster => '加速';

  @override
  String get remoteMirrorH => '水平镜像';

  @override
  String get remoteMirrorV => '垂直镜像';

  @override
  String get remoteFollowVoice => '语音跟随';

  @override
  String get remoteStart => '开头';

  @override
  String get remoteSections => '章节和提示点';

  @override
  String get remoteChangeScript => '更换脚本';

  @override
  String get aboutTitle => '关于';

  @override
  String aboutVersion(String version) {
    return '版本 $version';
  }

  @override
  String get aboutTagline => '适用于 Linux 和 Android 的提词器：流畅滚动、局域网遥控和离线语音跟随。';

  @override
  String get aboutCreatedBy => '作者';

  @override
  String get aboutFollow => '关注';

  @override
  String get aboutProject => '项目';

  @override
  String get aboutSourceCode => '源代码';

  @override
  String get aboutContribute => '参与贡献';

  @override
  String get aboutLicense => 'MIT 许可证';

  @override
  String get aboutVoiceCredit => '离线语音识别：Vosk（Apache 2.0）';

  @override
  String get aboutLicenses => '开源许可证';

  @override
  String aboutOpenFailed(String url) {
    return '无法打开 $url';
  }
}
