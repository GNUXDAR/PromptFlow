// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String commonError(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String get homeImport => '.txt / .md आयात करें';

  @override
  String get homeRemote => 'रिमोट कंट्रोल';

  @override
  String get homeNewScript => 'नई स्क्रिप्ट';

  @override
  String homeEditScript(String title) {
    return '$title संपादित करें';
  }

  @override
  String get homeSampleFileName => 'udaharan.md';

  @override
  String get homeSampleScript =>
      '# नमूना स्क्रिप्ट\n\n## शुरुआत\n[CAM 1] नमस्ते, PromptFlow में आपका **स्वागत** है। यह नमूना स्क्रिप्ट\nउपलब्ध मार्कर दिखाती है। [PAUSE 2s]\n\nज़ोर देने के लिए आप शब्दों को **बोल्ड** कर सकते हैं, या ज़रूरी होने पर\nउन्हें ==हाइलाइट== कर सकते हैं।\n\n## डेमो\n[CAM 2] [CUE Demo] अब हम कैमरा बदलते हैं। स्वचालित विराम टेक्स्ट को\nकुछ सेकंड के लिए रोकते हैं और फिर अपने-आप आगे बढ़ते हैं। [PAUSE 1.5s]\n\nबिना अवधि वाला विराम टेक्स्ट को तब तक रोके रखता है, जब तक आप ‘चलाएँ’ नहीं दबाते। [PAUSE]\n\n## समापन\n[CAM 1] देखने के लिए धन्यवाद। **रिमोट कंट्रोल** मोड से अपने फ़ोन से प्रॉम्प्टर नियंत्रित करें,\nया Bluetooth पेडल का उपयोग करें।\n';

  @override
  String get editorNameHint => 'name.md';

  @override
  String get editorSave => 'सहेजें (Ctrl+S)';

  @override
  String get editorRehearse => 'प्रॉम्प्टर में रिहर्सल करें';

  @override
  String editorSavedTo(String path) {
    return '$path में सहेजा गया';
  }

  @override
  String get editorUnsavedTitle => 'बिना सहेजे बदलाव';

  @override
  String get editorUnsavedBody => 'बिना सहेजे बाहर निकलें?';

  @override
  String get editorLeave => 'बाहर निकलें';

  @override
  String get editorBodyHint =>
      '# शीर्षक\n\n## अनुभाग\n[CAM 1] **ज़ोर** के साथ स्क्रिप्ट का टेक्स्ट। [PAUSE 2s]';

  @override
  String get editorBold => 'बोल्ड';

  @override
  String get editorHighlight => 'हाइलाइट';

  @override
  String get editorSection => '## अनुभाग';

  @override
  String get editorPause2s => '2 सेकंड का विराम';

  @override
  String get editorPauseManual => 'मैनुअल विराम';

  @override
  String get editorCue => 'क्यू';

  @override
  String get editorCueSnippet => '[CUE नाम] ';

  @override
  String editorStats(int words, int markers) {
    return '$words शब्द · $markers मार्कर';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return '$wpm WPM पर अवधि: $duration';
  }

  @override
  String get editorTargetHint => 'लक्ष्य अवधि';

  @override
  String get editorNoTarget => 'कोई लक्ष्य नहीं';

  @override
  String editorMinutes(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get editorPausesExceedTarget => 'विराम लक्ष्य अवधि से अधिक हैं';

  @override
  String editorNeededWpm(int wpm) {
    return 'आपको $wpm WPM चाहिए';
  }

  @override
  String get prompterExit => 'बाहर निकलें (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिमोट',
      one: '$count रिमोट',
      zero: 'कोई रिमोट नहीं',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'सर्वर बंद हो गया';

  @override
  String prompterServerPortError(int port, String message) {
    return 'पोर्ट $port नहीं खुल सका: $message';
  }

  @override
  String get prompterBack5 => '5 सेकंड पीछे (Page Up)';

  @override
  String get prompterForward5 => '5 सेकंड आगे (Page Down)';

  @override
  String get prompterPlay => 'चलाएँ (Space)';

  @override
  String get prompterPause => 'रोकें (Space)';

  @override
  String get prompterSlower => 'धीमा (↓)';

  @override
  String get prompterFaster => 'तेज़ (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · $remaining शेष';
  }

  @override
  String get prompterVoiceOn => 'मेरी आवाज़ का अनुसरण करें';

  @override
  String get prompterVoiceOff => 'आवाज़ अनुसरण बंद करें';

  @override
  String get prompterGoToSection => 'अनुभाग पर जाएँ';

  @override
  String get prompterSettings => 'सेटिंग्स (S)';

  @override
  String get statusPlaying => 'चल रहा है';

  @override
  String statusAutoPaused(String seconds) {
    return 'विराम $seconds सेकंड';
  }

  @override
  String get statusAutoPausedShort => 'स्वचालित विराम';

  @override
  String get statusHolding => 'रुका हुआ — ‘चलाएँ’ दबाएँ';

  @override
  String get statusHoldingShort => 'स्क्रिप्ट विराम';

  @override
  String get statusFinished => 'समाप्त';

  @override
  String get statusStopped => 'रुका हुआ';

  @override
  String get settingsFontSize => 'फ़ॉन्ट आकार';

  @override
  String get settingsLineHeight => 'पंक्ति अंतराल';

  @override
  String get settingsMargin => 'किनारे का मार्जिन';

  @override
  String get settingsFocusLine => 'फ़ोकस लाइन';

  @override
  String get settingsSpeed => 'गति';

  @override
  String get settingsTextColor => 'टेक्स्ट का रंग';

  @override
  String get settingsWhite => 'सफ़ेद';

  @override
  String get settingsYellow => 'पीला';

  @override
  String get settingsMirrorH => 'क्षैतिज मिरर (H)';

  @override
  String get settingsMirrorV => 'लंबवत मिरर (V)';

  @override
  String get settingsFocusGuide => 'फ़ोकस लाइन गाइड';

  @override
  String get voiceTitle => 'आवाज़ अनुसरण';

  @override
  String get voiceLanguage => 'आवाज़ की भाषा';

  @override
  String voiceStatusDownloading(int percent) {
    return 'डाउनलोड हो रहा है $percent%';
  }

  @override
  String get voiceStatusInstalling => 'मॉडल इंस्टॉल हो रहा है…';

  @override
  String get voiceStatusReady =>
      'तैयार: HUD का माइक्रोफ़ोन दबाएँ, टेक्स्ट आपकी आवाज़ के साथ चलेगा';

  @override
  String get voiceStatusNoEngine =>
      'मॉडल इंस्टॉल है, लेकिन Vosk इंजन नहीं है (Linux पर: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'मॉडल इंस्टॉल नहीं है ($size MB, केवल एक बार डाउनलोड होगा)';
  }

  @override
  String voiceDownload(int size) {
    return 'मॉडल डाउनलोड करें ($size MB)';
  }

  @override
  String voiceDownloadPrompt(String language, int size) {
    return 'आवाज़ ट्रैकिंग के लिए $language वॉइस मॉडल ($size MB) चाहिए। यह सिर्फ़ एक बार डाउनलोड होता है और फिर ऑफ़लाइन काम करता है। भाषा सेटिंग्स → आवाज़ में बदली जा सकती है।';
  }

  @override
  String get voiceErrorNoModel =>
      'सेटिंग्स → आवाज़ में आवाज़ मॉडल डाउनलोड करें';

  @override
  String get voiceErrorNoEngine =>
      'Vosk इंस्टॉल नहीं है (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'माइक्रोफ़ोन की अनुमति नहीं दी गई। आवाज़ अनुसरण का उपयोग करने के लिए सिस्टम सेटिंग्स में इसकी अनुमति दें।';

  @override
  String voiceErrorDownload(String message) {
    return 'मॉडल डाउनलोड नहीं हो सका: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'आवाज़ पहचान त्रुटि: $message';
  }

  @override
  String get remoteTitle => 'रिमोट कंट्रोल';

  @override
  String get remoteConnectTitle => 'प्रॉम्प्टर से कनेक्ट करें';

  @override
  String get remoteReconnecting => 'फिर से कनेक्ट हो रहा है…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => 'डिस्कनेक्ट करें';

  @override
  String get remotePinRequired =>
      'प्रॉम्प्टर पर दिखाया गया 4 अंकों का PIN डालें';

  @override
  String get remoteBadPin => 'गलत PIN';

  @override
  String remoteConnectFailed(String message) {
    return 'कनेक्ट नहीं हो सका: $message';
  }

  @override
  String get remotePinLabel => 'प्रॉम्प्टर PIN';

  @override
  String get remoteOnLan => 'लोकल नेटवर्क पर';

  @override
  String get remoteSearch => 'खोजें';

  @override
  String get remoteNoneFound =>
      'कोई प्रॉम्प्टर नहीं मिला। इसे Linux कंप्यूटर पर खोलें या मैनुअल IP का उपयोग करें।';

  @override
  String get remoteManualIp => 'मैनुअल IP (जैसे 192.168.1.20)';

  @override
  String get remoteConnect => 'कनेक्ट करें';

  @override
  String get remotePosition => 'स्क्रिप्ट में स्थिति';

  @override
  String remoteRemaining(String remaining) {
    return '$remaining शेष';
  }

  @override
  String get remoteBack5 => '5 सेकंड पीछे';

  @override
  String get remoteForward5 => '5 सेकंड आगे';

  @override
  String get remotePlay => 'चलाएँ';

  @override
  String get remotePause => 'रोकें';

  @override
  String get remoteSlower => 'धीमा';

  @override
  String get remoteFaster => 'तेज़';

  @override
  String get remoteMirrorH => 'मिरर H';

  @override
  String get remoteMirrorV => 'मिरर V';

  @override
  String get remoteFollowVoice => 'आवाज़ का अनुसरण';

  @override
  String get remoteStart => 'शुरुआत';

  @override
  String get remoteSections => 'अनुभाग और क्यू';

  @override
  String get remoteChangeScript => 'स्क्रिप्ट बदलें';

  @override
  String get aboutTitle => 'परिचय';

  @override
  String aboutVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get aboutTagline =>
      'Linux और Android के लिए टेलीप्रॉम्प्टर: स्मूद स्क्रॉल, लोकल नेटवर्क से रिमोट कंट्रोल और ऑफ़लाइन आवाज़ ट्रैकिंग।';

  @override
  String get aboutCreatedBy => 'निर्माता';

  @override
  String get aboutFollow => 'फ़ॉलो करें';

  @override
  String get aboutProject => 'प्रोजेक्ट';

  @override
  String get aboutSourceCode => 'सोर्स कोड';

  @override
  String get aboutContribute => 'योगदान दें';

  @override
  String get aboutLicense => 'MIT लाइसेंस';

  @override
  String get aboutVoiceCredit => 'ऑफ़लाइन वाक् पहचान: Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => 'ओपन-सोर्स लाइसेंस';

  @override
  String aboutOpenFailed(String url) {
    return '$url नहीं खोला जा सका';
  }
}
